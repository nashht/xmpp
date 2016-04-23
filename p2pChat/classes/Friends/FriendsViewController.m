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
#import "MyXMPP+Roster.h"
#import "XMPPvCardTemp.h"
#import "MyXMPP.h"
#import "MyXMPP+VCard.h"
#import "FriendInfoController.h"

@interface FriendsViewController ()<FriendHeaderViewDelegate,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray<FriendsGroup *> *groups;
@property (strong, nonatomic) NSArray<XMPPGroupCoreDataStorageObject *> *groupCoreDataStorageObjects;
@property (strong, nonatomic) FriendsGroup *group;

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"通讯录";
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FriendCell" bundle:nil] forCellReuseIdentifier:@"friendCell"];
    
    self.tableView.rowHeight = 50;
    self.tableView.sectionHeaderHeight = 44;
    
    _groupCoreDataStorageObjects = [[MyXMPP shareInstance]getFriendsGroup];
    [self initGroup];
    
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return YES;
}

- (void)initGroup{
    _groups = [[NSMutableArray alloc]init];
    for (XMPPGroupCoreDataStorageObject *groupObj in _groupCoreDataStorageObjects) {
        @autoreleasepool {
            _group = [[FriendsGroup alloc]init];
            _group.opened = NO;
            _group.name = groupObj.name;
            _group.friends = groupObj.users.allObjects;
            int count = 0;
            for (int i=0;i<_group.friends.count;i++) {
                XMPPUserCoreDataStorageObject *userobj = groupObj.users.allObjects[i];
                if ([userobj isOnline] ==YES) {
                    count++;
                };
            }
            _group.online = count;
            [_groups addObject:_group];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _groupCoreDataStorageObjects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    XMPPGroupCoreDataStorageObject *group = _groupCoreDataStorageObjects[section];
    return _groups[section].opened ? group.users.count : 0;
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
    
    [cell setLabel:obj.jid.user];//设置好友名称
    if (vCard.photo != nil) {//设置好友默认头像
        [cell setIcon:[UIImage imageWithData:vCard.photo]];
    } else {
        [cell setIcon:[UIImage imageNamed:@"0"]];
    }
    
    if (vCard.title == nil) {//设置好友职务
        [cell setDepartment:@"职务"];
    }else{
        [cell setDepartment:vCard.title];
    }
    
    switch (obj.section) {
        case 0:
            [cell setStatus:@"[在线]"];
            break;
        case 1:
            [cell setStatus:@"[离开]"];
            break;
        case 2:
            [cell setStatus:@"[离线]"];
            break;
        default:
            break;
    }
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    FriendHeaderView *header = [FriendHeaderView friendHeaderViewWithTableView:tableView];
    header.delegate = self;
    header.group = _groups[section];
    
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
