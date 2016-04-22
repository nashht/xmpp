//
//  CreatGroupsTableViewController.m
//  p2pChat
//
//  Created by nashht on 16/4/15.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#define screenSize ([UIScreen mainScreen].bounds.size)
#import "FriendsGroup.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "XMPPGroupCoreDataStorageObject.h"
#import "XMPPvCardTemp.h"
#import "MyXMPP.h"
#import "MyXMPP+Roster.h"
#import "MyXMPP+VCard.h"
#import "MyXMPP+Group.h"
#import "HeaderView.h"
#import "CreatGroupsViewController.h"

@interface CreatGroupsViewController ()<UITableViewDelegate,UITableViewDataSource,HeaderViewDelegate>

@property (nonatomic, strong) NSMutableArray<FriendsGroup *> *groups;
@property (strong, nonatomic) NSArray<XMPPGroupCoreDataStorageObject *> *groupCoreDataStorageObjects;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *selectedFriends;

@end

@implementation CreatGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"发起群聊";
    UITableView *tableView = [[UITableView alloc] init];
    CGRect frame = self.view.bounds;
    frame.origin.y = 65;
    frame.size.height = self.view.bounds.size.height - 65;
    tableView.frame = frame;
    _tableView = tableView;
    [self.view addSubview:tableView];
    tableView.backgroundColor = [UIColor orangeColor];
    
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    
    [_tableView setEditing:YES animated:YES];
    _groupCoreDataStorageObjects = [[MyXMPP shareInstance]getFriendsGroup];
    [self initGroup];
    
    _selectedFriends = [NSMutableArray array];
    
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return YES;
}


- (IBAction)cancelBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectBtnClick:(UIButton *)sender {
    [[MyXMPP shareInstance] creatGroupName:@"12121" withpassword:nil andsubject:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(invitenewfriends) name:MyXmppRoomDidConfigurationNotification object:nil];
    
    NSLog(@"selected__-----------%@",_selectedFriends);
}

- (void)invitenewfriends{
//    [[MyXMPP shareInstance] inviteFriends:@"cxh" withMessage:@"wewe"];
//    [[MyXMPP shareInstance] inviteFriends:@"ht_test" withMessage:@"wewe"];
    
    for (NSString *users in _selectedFriends) {
        [[MyXMPP shareInstance] inviteFriends:users withMessage:@"welcome"];
    }
}

- (void)initGroup{
    _groups = [[NSMutableArray alloc]init];
    for (XMPPGroupCoreDataStorageObject *groupObj in _groupCoreDataStorageObjects) {
        @autoreleasepool {
            FriendsGroup *group = [[FriendsGroup alloc]init];
            group.opened = NO;
            group.name = groupObj.name;
            group.friends = groupObj.users.allObjects;
            [_groups addObject:group];
        }
    }
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
    static NSString *ID = @"group";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ID];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.selected = NO;
    
    XMPPGroupCoreDataStorageObject *groupInfo = _groupCoreDataStorageObjects[indexPath.section];
    XMPPUserCoreDataStorageObject *obj = groupInfo.users.allObjects[indexPath.row];
    XMPPvCardTemp *vCard = [[MyXMPP shareInstance]fetchFriend:obj.jid];

    if (vCard.photo != nil) {
        cell.imageView.image = [UIImage imageWithData:vCard.photo];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"0"];
    }
//    cell.selectedBackgroundView = [[UIView alloc]initWithFrame:CGRectZero];
    cell.backgroundColor = [UIColor yellowColor];
    cell.textLabel.text = obj.jid.user;
    cell.selected = YES;
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    记录选中的行
    //获取选中的UITableViewCell
 
    XMPPGroupCoreDataStorageObject *groupInfo = _groupCoreDataStorageObjects[indexPath.section];
    XMPPUserCoreDataStorageObject *obj = groupInfo.users.allObjects[indexPath.row];
    
    NSLog(@"name______%@",obj.jidStr);
    NSLog(@"section,%ld,row%ld",indexPath.section,indexPath.row);
    
    if (![_selectedFriends containsObject:obj.jid.user]) {
        [_selectedFriends addObject:obj.jid.user];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
//      记录选中的行
    XMPPGroupCoreDataStorageObject *groupInfo = _groupCoreDataStorageObjects[indexPath.section];
    XMPPUserCoreDataStorageObject *obj = groupInfo.users.allObjects[indexPath.row];
    
    [_selectedFriends removeObject:obj.jid.user];
    
//    HeaderView *view = (HeaderView *)[_tableView headerViewForSection:indexPath.section];
//    view.allSelected = NO;
//    [view Image:[UIImage imageNamed:@"1"]];

}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return _groupCoreDataStorageObjects[section].name;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSLog(@"viewForHeaderInSection");

    HeaderView *view =  [HeaderView headerView];
    view.delegate = self;
    view.section = section;
    
    NSString *name = _groupCoreDataStorageObjects[section].name;
    [view Name:name];
    return view;
}


#pragma mark - HeaderViewDelegate
- (void)headerViewDidClicked:(HeaderView *)headerView{
    NSLog(@"headerViewDidClicked___");
    
    NSUInteger section = headerView.section;
    NSUInteger row = [_tableView numberOfRowsInSection:section];
    
    if (!headerView.allSelected) {
        
      for (NSUInteger i = 0; i < row; i++) {
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section] animated:NO scrollPosition:UITableViewScrollPositionNone];
      }
        
        headerView.allSelected = YES;
        [headerView Image:[UIImage imageNamed:@"tabbar_mine_f"]];
        [headerView Name:@"seleted__"];
        
    }else{
        for (NSUInteger i = 0; i < row; i++) {
            [_tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section] animated:NO];
        }
        
        headerView.allSelected = NO;
        [headerView Name:_groups[section].name];
        [headerView Image:[UIImage imageNamed:@"chat_bottom_up_nor"]];
    }
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
