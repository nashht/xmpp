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
#import "HeaderView.h"
#import "CreatGroupsViewController.h"

@interface CreatGroupsViewController ()<UITableViewDelegate,UITableViewDataSource,HeaderViewDelegate>

@property (nonatomic, strong) NSMutableArray<FriendsGroup *> *groups;
@property (strong, nonatomic) NSArray<XMPPGroupCoreDataStorageObject *> *groupCoreDataStorageObjects;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CreatGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect frame = CGRectMake(30, 120, screenSize.width, screenSize.height - 120);
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    tableView.frame = self.view.bounds;
    [self.view addSubview:tableView];
    tableView.backgroundColor = [UIColor orangeColor];
    
    _tableView = tableView;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    
    [_tableView setEditing:YES animated:YES];
    _groupCoreDataStorageObjects = [[MyXMPP shareInstance]getFriendsGroup];
    [self initGroup];
    
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return YES;
}

- (IBAction)cancelBtnClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectBtnClick:(UIButton *)sender {
//    [[MyXMPP shareInstance] creatGroupName:@"123" withpassword:nil andsubject:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(invitenewfriends) name:MyXmppRoomDidConfigurationNotification object:nil];
}

//- (void)invitenewfriends{
//    [[MyXMPP shareInstance] inviteFriends:@"cxh" withMessage:@"wewe"];
//    [[MyXMPP shareInstance] inviteFriends:@"ht_test" withMessage:@"wewe"];
//}

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
    
    XMPPGroupCoreDataStorageObject *groupInfo = _groupCoreDataStorageObjects[indexPath.section];
    XMPPUserCoreDataStorageObject *obj = groupInfo.users.allObjects[indexPath.row];
    XMPPvCardTemp *vCard = [[MyXMPP shareInstance]fetchFriend:obj.jid];

    if (vCard.photo != nil) {
        cell.imageView.image = [UIImage imageWithData:vCard.photo];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"0"];
    }
    cell.textLabel.text = obj.jid.user;
    cell.selected = YES;
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    记录选中的行
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
//      记录选中的行
}


-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.editing)//仅仅在编辑状态的时候需要自己处理选中效果
    {
        if (selected){
            //选中时的效果
        }
        else {
            //非选中时的效果
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return _groupCoreDataStorageObjects[section].name;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSLog(@"viewForHeaderInSection");

    HeaderView *view =  [HeaderView headerView];
    view.delegate = self;
    NSString *name = _groupCoreDataStorageObjects[section].name;
    [view Name:name];
    return view;
}

#pragma mark - HeaderViewDelegate
- (void)headerViewDidClicked:(HeaderView *)headerView{
    NSLog(@"headerViewDidClicked___");
    [headerView Name:@"seleted__delegate"];
    
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
