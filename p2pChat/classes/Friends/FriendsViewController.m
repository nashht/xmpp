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

@interface FriendsViewController ()<FriendHeaderViewDelegate,UITableViewDelegate,NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic,strong) FriendsGroup *group;
@property (strong, nonatomic) NSFetchedResultsController *friendsController;

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    self.navigationItem.title = @"通讯录";
    
    // 假数据
    FriendsGroup *group1 = [[FriendsGroup alloc] init];
    group1.name = @"group1";
    group1.opened = NO;
    group1.friends = [NSArray array];
    _groups = [NSMutableArray arrayWithObjects:self.group,nil];
    [_groups addObject:self.group];
    [self.tableView registerNib:[UINib nibWithNibName:@"FriendCell" bundle:nil] forCellReuseIdentifier:@"friendCell"];
    
    self.tableView.rowHeight = 50;
    self.tableView.sectionHeaderHeight = 44;
    
    _friendsController = [[MyXMPP shareInstance] getFriends];
    
    NSLog(@"组数%ld",[_friendsController sections].count);
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return YES;
}

- (FriendsGroup *)group{
    if (_group == nil) {
        FriendsGroup *group = [[FriendsGroup alloc]init];
        group.opened = NO;
        group.name = @"group1";
        self.group = group;
    }
    return _group;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_friendsController sections].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionObj = [[_friendsController sections]objectAtIndex:section];
    NSLog(@"sectionObj%@",sectionObj.name);
    
    return (_group.isOpened ? [sectionObj numberOfObjects] : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"friendCell";

    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FriendCell" owner:nil options:nil] firstObject];
    }
//    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    
    XMPPUserCoreDataStorageObject *obj = ( XMPPUserCoreDataStorageObject *) [_friendsController objectAtIndexPath:indexPath];
    NSArray <XMPPGroupCoreDataStorageObject *> *groups = obj.groups.allObjects;
    if (groups.count != 0) {
        XMPPGroupCoreDataStorageObject *groupInfo = groups[0];
        [cell setDepartment:groupInfo.name];
    } else {
        [cell setDepartment:@"null"];
    }
    
//    NSLog(@"sectionName%@",obj.sectionNum);    //首字母
//        NSLog(@"sectionName%ld",obj.section);    //首字母
    [cell setLabel:obj.nickname];
    [cell setIcon:@"0"];
    
    switch (obj.section) {
        case 0:
            [cell setStatus:@"online"];
            break;
        case 1:
            [cell setStatus:@"away"];
            break;
        case 2:
            [cell setStatus:@"offline"];
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
    vc.userObj =  ( XMPPUserCoreDataStorageObject *)[_friendsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:vc animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - headerView的代理方法
- (void)headerViewDidClickedNameView:(FriendHeaderView *)headerView{
//    NSLog(@"headerViewDidClickedNameView");

    [self.tableView reloadData];
}

#pragma mark 当数据的内容发生改变后，会调用 这个方法
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    NSLog(@"数据发生改变");
    //刷新表格
    [self.tableView reloadData];
}
@end
