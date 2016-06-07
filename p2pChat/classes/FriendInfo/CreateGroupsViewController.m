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
#import "CreateGroupsViewController.h"

static NSString *defaultGroupName = @"11111111";

@interface CreateGroupsViewController ()<UITableViewDelegate,UITableViewDataSource,HeaderViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray<FriendsGroup *> *groups;
@property (strong, nonatomic) NSArray<XMPPGroupCoreDataStorageObject *> *groupCoreDataStorageObjects;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *selectedFriends;
@property (strong, nonatomic) NSString *groupName;

@end

@implementation CreateGroupsViewController

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
    if (_selectedFriends.count == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"没有选择好友，请选择好友。" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入群名:" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.textColor = [UIColor redColor];
            textField.placeholder = @"GroupName";
        }];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            _groupName = alert.textFields.firstObject.text;
            [[MyXMPP shareInstance] creatGroupName:_groupName withpassword:nil andsubject:nil];
        }];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alert addAction:okAction];
        [alert addAction:cancleAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(inviteNewFriends) name:MyXmppRoomDidConfigurationNotification object:nil];
//    NSLog(@"selected__-----------%@",_selectedFriends);
    }
}

- (void)inviteNewFriends{
    [self dismissViewControllerAnimated:YES completion: ^{
        NSArray *option = @[_groupName,  @0];
        [_fatherVC performSegueWithIdentifier:@"chat" sender:option];//进入聊天的界面
    }];
    for (NSString *users in _selectedFriends) {
        [[MyXMPP shareInstance] inviteFriends:users withMessage:[NSString stringWithFormat:@"Hi,%@! Welcome to join group chat",users]];
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MyXmppRoomDidConfigurationNotification object:nil];

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
    
    XMPPGroupCoreDataStorageObject *groupInfo = _groupCoreDataStorageObjects[indexPath.section];
    XMPPUserCoreDataStorageObject *obj = groupInfo.users.allObjects[indexPath.row];
    XMPPvCardTemp *vCard = [[MyXMPP shareInstance]fetchFriend:obj.jid];
    
    if (vCard.photo) {
        cell.imageView.image = [UIImage imageWithData:vCard.photo];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"0"];
    }
    cell.textLabel.text = obj.jid.user;
    cell.selected = [_didSelectedUsers containsObject:obj.jid.user];
    cell.userInteractionEnabled = ![_didSelectedUsers containsObject:obj.jid.user];
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
    
    if (![_selectedFriends containsObject:obj.jid.user]) {
        [_selectedFriends addObject:obj.jid.user];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
//      记录选中的行
    XMPPGroupCoreDataStorageObject *groupInfo = _groupCoreDataStorageObjects[indexPath.section];
    XMPPUserCoreDataStorageObject *obj = groupInfo.users.allObjects[indexPath.row];
    
    [_selectedFriends removeObject:obj.jid.user];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return _groupCoreDataStorageObjects[section].name;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    HeaderView *view =  [HeaderView headerView];
    view.delegate = self;
    view.section = section;
    
    NSString *name = _groupCoreDataStorageObjects[section].name;
    [view Name:name];
    return view;
}

#pragma mark - HeaderViewDelegate
- (void)headerViewDidClicked:(HeaderView *)headerView{
    
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

@end
