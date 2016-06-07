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

@interface GroupMembersListTableViewController ()

@property (nonatomic,assign) NSInteger *count;
@property (nonatomic,strong) NSMutableArray *array;

@end

@implementation GroupMembersListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    XMPPJID *myjid = [[MyXMPP shareInstance]myjid];
//    [[MyXMPP shareInstance] fetchMembersFromGroupWithCompletion:^(NSArray *members) {
//          NSInteger *m = members.count+1;
//          _array = [[NSMutableArray alloc]initWithCapacity:m];
//          for (int i = 0; i<[members count]; i++) {
//              [_array insertObject:[members objectAtIndex:i] atIndex:i];
//          }
//         [_array insertObject:myjid.user atIndex:[members count]];
//
//    }];
   
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    XMPPJID *myjid = [[MyXMPP shareInstance]myjid];
    [[MyXMPP shareInstance] fetchMembersFromGroupWithCompletion:^(NSArray *members) {
        NSInteger *m = members.count+1;
        _array = [[NSMutableArray alloc]initWithCapacity:m];
        for (int i = 0; i<[members count]; i++) {
            [_array insertObject:[members objectAtIndex:i] atIndex:i];
        }
        [_array insertObject:myjid.user atIndex:[members count]];
        _count = [members count];
        _count++;
    }];
    return _count;
 
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
