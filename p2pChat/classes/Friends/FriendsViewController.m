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
#import "XMPPvCardTemp.h"
#import "MyXMPP.h"
#import "FriendInfoController.h"

@interface FriendsViewController ()<FriendHeaderViewDelegate,UITableViewDelegate>

@property (nonatomic, strong) NSArray *groups;
@property (nonatomic,strong) FriendsGroup *group;
@property (strong, nonatomic) NSArray<XMPPGroupCoreDataStorageObject *> *groupCoreDataStorageObjects;

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
    
    _groupCoreDataStorageObjects = [[MyXMPP shareInstance]getFriends];
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
    return _groupCoreDataStorageObjects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    XMPPGroupCoreDataStorageObject *group = _groupCoreDataStorageObjects[section];
    return group.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *friendCell = @"friendCell";
    
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:friendCell];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FriendCell" owner:nil options:nil] firstObject];
    }
    
    XMPPGroupCoreDataStorageObject *groupInfo = _groupCoreDataStorageObjects[indexPath.section];
    XMPPUserCoreDataStorageObject *obj = groupInfo.users.allObjects[indexPath.row];
    XMPPvCardTemp *vCard = [[MyXMPP shareInstance]fetchFriend:obj.jid];
    
    [cell setLabel:obj.jid.user];
    if (vCard.photo != nil) {
        [cell setIcon:[UIImage imageWithData:vCard.photo]];
    } else {
        [cell setIcon:[UIImage imageNamed:@"0"]];
    }
    [cell setDepartment:@"职位"];
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    FriendHeaderView *header = [FriendHeaderView friendHeaderViewWithTableView:tableView];
    header.delegate = self;
    
    XMPPGroupCoreDataStorageObject *groupObj = _groupCoreDataStorageObjects[section];
    
    FriendsGroup *group = [[FriendsGroup alloc]init];
    group.opened = NO;
    group.name = groupObj.name;
    group.friends = groupObj.users.allObjects;
    
    header.group = group;
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    FriendInfoController *vc = (FriendInfoController *)[storyBoard instantiateViewControllerWithIdentifier:@"friendsInfo"];
    vc.title = @"个人资料";
    XMPPGroupCoreDataStorageObject *group = _groupCoreDataStorageObjects[indexPath.section];
    vc.userObj = group.users.allObjects[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)headerViewDidClickedNameView:(FriendHeaderView *)headerView{
    [self.tableView reloadData];
}

@end
