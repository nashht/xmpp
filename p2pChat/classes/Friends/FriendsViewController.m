//
//  FriendsGroupTableViewController.m
//  p2pChat
//
//  Created by nashht on 16/3/24.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "FriendsViewController.h"
#import "FriendCell.h"
#import "FriendsGroup.h"
#import "FriendHeaderView.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "XMPPGroupCoreDataStorageObject.h"
#import "MyXMPP.h"
#import "FriendInfoController.h"

@interface FriendsViewController ()<FriendHeaderViewDelegate,UITableViewDelegate>

@property (nonatomic, strong) NSArray *groups;
@property (nonatomic,strong) FriendsGroup *group;
@property (strong, nonatomic) NSFetchedResultsController *friendsController;

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.navigationItem.title = @"通讯录";
    
    // 假数据
    FriendsGroup *group1 = [[FriendsGroup alloc] init];
    group1.name = @"group1";
    group1.opened = NO;
    group1.friends = [NSArray array];
    _groups = [NSArray arrayWithObjects:group1,nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FriendCell" bundle:nil] forCellReuseIdentifier:@"friendCell"];
    
    self.tableView.rowHeight = 50;
    self.tableView.sectionHeaderHeight = 44;
    
    _friendsController = [[MyXMPP shareInstance]getFriends];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return YES;
}

- (FriendsGroup *)group{
    FriendsGroup *group = [[FriendsGroup alloc]init];
    group.opened = NO;
    _group = group;
    return _group;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_friendsController sections].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionObj = [[_friendsController sections]objectAtIndex:section];
    return [sectionObj numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"friendCell";

    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FriendCell" owner:nil options:nil] firstObject];
    }
    
    XMPPUserCoreDataStorageObject *obj = (XMPPUserCoreDataStorageObject *) [_friendsController objectAtIndexPath:indexPath];
    XMPPGroupCoreDataStorageObject *groupInfo = obj.groups.allObjects[0];
    
    cell.nameLabel.text = obj.jid.user;
    
//    [cell awakeFromNib];
    cell.iconView.image = [UIImage imageNamed:@"0"];
    cell.departmentLabel.text = groupInfo.name;

    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    FriendHeaderView *header = [FriendHeaderView friendHeaderViewWithTableView:tableView];
    header.delegate = self;
    
    header.group = self.groups[section];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    FriendInfoController *vc = (FriendInfoController *)[storyBoard instantiateViewControllerWithIdentifier:@"friendsInfo"];
    vc.title = @"个人资料";
    vc.userObj =  ( XMPPUserCoreDataStorageObject *) [_friendsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)headerViewDidClickedNameView:(FriendHeaderView *)headerView{
    [self.tableView reloadData];
}

@end
