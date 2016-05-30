//
//  FileCell.m
//  XMPP
//
//  Created by nashht on 16/5/27.
//  Copyright © 2016年 xiaokun. All rights reserved.
//
#define DocumentsPath(a) ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:(a)])
#define bodyPadding 15

#import "FileCell.h"
#import "FileFrameModel.h"
#import "AFNetworking.h"
#import "Tool.h"
#import "MessageBean.h"
#import "MyXmpp+VCard.h"
#import "UIImage+Category.h"

@interface FileCell()

@property(nonatomic,weak)UILabel *timeLable;
@property(nonatomic,weak)UIImageView *photoImage;
@property(nonatomic,weak)UIButton *bodyBtn;
@property (nonatomic,weak) NSString *filename;

@end

@implementation FileCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //        1.时间
        UILabel *timeLable = [[UILabel alloc] init];
        timeLable.textAlignment = NSTextAlignmentCenter;
        timeLable.font = [UIFont systemFontOfSize:13.0f];
        [self.contentView addSubview:timeLable];
        _timeLable = timeLable;
        
        //        2.头像
        UIImageView *photoImage = [[UIImageView alloc] init];
        [self.contentView addSubview:photoImage];
        _photoImage = photoImage;
        
        //        3.正文
        UIButton *btn = [[UIButton alloc] init];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        btn.titleLabel.numberOfLines = 0;   //自动换行；
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.contentEdgeInsets = UIEdgeInsetsMake(bodyPadding, bodyPadding, bodyPadding, bodyPadding);
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, bodyPadding * 0.5, 0, 0);
        btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *fileImage = [[UIImage imageNamed:@"add_file_n"] transformWidth:65 height:65];
        [btn setImage:fileImage forState:UIControlStateNormal];
        
        [self.contentView addSubview:btn];
        _bodyBtn = btn;
        [btn addTarget:self action:@selector(downloadFile) forControlEvents:UIControlEventTouchUpInside];

        self.backgroundColor = [UIColor grayColor];
    }
    
    return self;
}

- (void) setFileFrame:(FileFrameModel *)fileFrame{
    _fileFrame = fileFrame;
    MessageBean *message = fileFrame.message;
    
    XMPPvCardTemp *vCard;
    if ([message.isOut boolValue]) {
        vCard = [MyXMPP shareInstance].myVCardTemp;
    }else{
        vCard = [[MyXMPP shareInstance]fetchFriend:[XMPPJID jidWithUser:message.username domain:myDomain resource:nil]];
    }
    
    //    数据模型
    _timeLable.text = [Tool stringFromDate:[NSDate dateWithTimeIntervalSince1970:message.time.doubleValue]];
    _timeLable.frame = fileFrame.timeFrame;
    
    if (vCard.photo != nil) {
        _photoImage.image = [UIImage imageWithData:vCard.photo];
    } else {
        _photoImage.image = [UIImage imageNamed:@"0"];
    }
    
    _photoImage.frame = fileFrame.photoFrame;
    [_photoImage.layer setCornerRadius:10];
    _photoImage.layer.masksToBounds = true;
    
    _filename = message.body;
    NSString *title = [NSString stringWithFormat:@"filename: %@",_filename];
    [_bodyBtn setTitle:title forState:UIControlStateNormal];
    _bodyBtn.frame = fileFrame.bodyFrame;
//    _bodyBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    
    //    文字背景
    if ([message.isOut boolValue]) {
        [_bodyBtn setBackgroundImage: [self resizeImageWithName:@"chat_send_nor"] forState:UIControlStateNormal];
    }else{
        [_bodyBtn setBackgroundImage:[self resizeImageWithName:@"chat_recive_nor"] forState:UIControlStateNormal];
    }
    
}

- (void)downloadFile{
    if ([_fileFrame.message.isOut boolValue]) {
        NSLog(@"发送出去的文件");
    }else{
        NSLog(@"接收到的文件");
        [self downloadFileWithFilename:_filename withCompletionHandler:^(NSData *fileData) {
            NSLog(@"file down success");
        }];
    }
}


- (UIImage *)resizeImageWithName:(NSString *)name
{
    UIImage *normal = [UIImage imageNamed:name];
    
    CGFloat w = normal.size.width * 0.5f - 1;
    CGFloat h = normal.size.height* 0.5f - 1;
    
    return [normal resizableImageWithCapInsets:UIEdgeInsetsMake(h, w, h, w)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)downloadFileWithFilename:(NSString *)filename withCompletionHandler:(void(^)(NSData *fileData))completionHandler{
    NSString *url =  [NSString stringWithFormat:@"http://10.108.136.59:8080/FileServer/file?method=download&filename=%@",filename];
    
    AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLSessionDownloadTask *task = [sessionManager downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"downloadProgress---------- : %@",downloadProgress);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        // 将下载文件保存在缓存路径中
        // URLWithString返回的是网络的URL,如果使用本地URL,需要注意
        //        NSURL *fileURL1 = [NSURL URLWithString:path];
        NSURL *fileURL = [NSURL fileURLWithPath:DocumentsPath(filename)];
        return fileURL;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"save file success : -----filePath -----  %@",filePath);
        
    }];
    
    [task resume];
}


@end