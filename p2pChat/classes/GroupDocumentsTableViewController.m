//
//  GroupDocumentsTableViewController.m
//  XMPP
//
//  Created by admin on 16/5/16.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "GroupDocumentsTableViewController.h"
#import "Tool.h"

@interface GroupDocumentsTableViewController ()

@property (strong, nonatomic)NSArray *arr;

@end

@implementation GroupDocumentsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arr =[self readFile:@"test"];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return _arr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    [cell.imageView setContentMode:UIViewContentModeScaleToFill];
    cell.imageView.image = [UIImage imageNamed:@"word.png"];

    cell.textLabel.text = _arr[indexPath.section];
    cell.detailTextLabel.text = @"2.1M";
    
    return cell;
}

-(NSArray *)readFile:(NSString *)filename{
    NSString *documentsPath =[Tool getDocumentsUrl];
    NSString *testDirectory = [documentsPath stringByAppendingPathComponent:filename];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSArray *file = [fileManage subpathsOfDirectoryAtPath: testDirectory error:nil];
    return file;
//    NSLog(@"%@",file);
  
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
