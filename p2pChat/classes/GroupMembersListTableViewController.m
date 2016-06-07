//
//  GroupMembersListTableViewController.m
//  XMPP
//
//  Created by admin on 16/6/5.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "GroupMembersListTableViewController.h"
#import "MyXMPP.h"
#import "MyXMPP+Group.h"
#import "MyXMPP+VCard.h"
#import "GroupMembersInfoTableViewController.h"

@interface GroupMembersListTableViewController ()

@property (nonatomic,assign) NSString *count;
@property (nonatomic,strong) NSMutableArray *array;
@property (strong, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation GroupMembersListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[MyXMPP shareInstance] fetchMembersFromGroup:_laterGroupName withCompletion:^(NSArray *members) {
        
        XMPPJID *myjid = [[MyXMPP shareInstance]myjid];
        NSInteger m = [_count intValue];
        m++;
        _array = [[NSMutableArray alloc]initWithCapacity:m];
        for (int i = 0; i<[members count]; i++) {
            [_array insertObject:[members objectAtIndex:i] atIndex:i];
        }
        [_array insertObject:myjid.user atIndex:[members count]];
        
        _tableview = [[UITableView alloc]init];
        [self.tableView reloadData];
    }];
    
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSInteger m = [_count intValue];
    return m;
    
 
//      return _array.count;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    NSInteger row = [indexPath row];
    XMPPJID *memberjid = [XMPPJID jidWithUser:[_array objectAtIndex:row] domain:myDomain resource:@"iphone"];
    XMPPvCardTemp *friendVCard = [[MyXMPP shareInstance]fetchFriend:memberjid];
    [cell.imageView setContentMode:UIViewContentModeScaleToFill];
    cell.imageView.image = [UIImage imageWithData:friendVCard.photo];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",memberjid.user];

  

    return cell;
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
