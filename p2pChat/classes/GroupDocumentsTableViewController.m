//
//  GroupDocumentsTableViewController.m
//  XMPP
//
//  Created by admin on 16/5/16.
//  Copyright © 2016年 xiaokun. All rights reserved.
//
#define CachePath(a) ([NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:(a)])

#import "GroupDocumentsTableViewController.h"
#import "AFNetworking.h"
#import "MyXMPP.h"
#import "MyXMPP+P2PChat.h"
#import "Tool.h"

@interface GroupDocumentsTableViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic)NSArray *arr;

@end

@implementation GroupDocumentsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arr =[self readFile];
    
   
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_arr.count==0) {
        return 1;
    }else{
        return _arr.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    if (_arr.count==0) {
        cell.textLabel.text = @"无群文件";
    }else{
        [cell.imageView setContentMode:UIViewContentModeScaleToFill];
        cell.imageView.image = [UIImage imageNamed:@"word.png"];
        cell.textLabel.text = _arr[indexPath.section];
    }
    
    return cell;
}

-(NSArray *)readFile{
    NSString *documentsPath =[Tool getDocumentsUrl];//document路径
//    NSString *testDirectory = [documentsPath stringByAppendingPathComponent:filename];:(NSString *)filename
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSArray *file = [fileManage subpathsOfDirectoryAtPath: documentsPath error:nil];
    return file;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"cell.textLabel.text :  %@",cell.textLabel.text);
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filepath = [path stringByAppendingPathComponent:cell.textLabel.text];
    NSLog( @" path = %@",filepath);
    NSData *fileData = [NSData dataWithContentsOfFile:filepath];
    NSString *filename = [@"file_" stringByAppendingString:cell.textLabel.text];
    
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:filepath]){
        
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:filepath error:nil];
        
        // file size
        NSNumber *theFileSize;
        NSString *size;
        if ((theFileSize = [attributes objectForKey:NSFileSize])){
            size = [NSString stringWithFormat:@"%i kb",[theFileSize intValue]];
        }
            [self sendFile:fileData filename:filename fileSize:size];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendFile:(NSData *)fileData filename:(NSString *)filename fileSize:(NSString *)fileSize{
    [[MyXMPP shareInstance] sendFile:filename ToUser:_chatObjectString fileSize:fileSize];
    [self uploadFile:fileData filename:filename];
    
}

- (void)uploadFile:(NSData *)fileData filename:(NSString *)filename{
    NSLog(@"send file 2 Server");
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"method"] = @"upload";
    param[@"filename"] = filename;
    
    // 参数para:{method:"upload"/"download",filename:"xxx"}(filename格式：username_timestamp
    [manager POST: @"http://10.108.136.59:8080/FileServer/file" parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        // 拼接文件参数
        [formData appendPartWithFileData:fileData name:@"file" fileName:filename mimeType:@"application/octet-stream"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
//        NSLog(@"uploadProgress%@",uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"success%@",json);
       
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed------error:   %@",error);
    }];
}


@end
