//
//  ViewController.m
//  p2pChat
//
//  Created by xiaokun on 16/1/4.
//  Copyright © 2016年 xiaokun. All rights reserved.
//
#import "RecentViewController.h"
#import "DataManager.h"
#import "MyFetchedResultsControllerDelegate.h"
#import "MyXMPP.h"
#import "RegularExpressionTool.h"
#import "MyXMPP+VCard.h"
#import "LastMessage.h"
#import "RecentCell.h"
#import "ChatViewController.h"
#import "Tool.h"
#import "PopoverViewController.h"
#import "CreateGroupsViewController.h"

@interface RecentViewController ()<UITableViewDataSource, UITableViewDelegate,UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UITableView *recentTableView;
//@property (weak, nonatomic)  UIRefreshControl *refreshControl;

@property (strong, nonatomic) DataManager *dataManager;
@property (strong, nonatomic) NSFetchedResultsController *recentController;
@property (strong, nonatomic) PopoverViewController *popoverVc;
@property (strong, nonatomic) MyFetchedResultsControllerDelegate *resultsControllerDelegate;

@end

@implementation RecentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"最近联系人";
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = back;
    
    if ([[NSUserDefaults standardUserDefaults]stringForKey:@"name"] == nil) {
        [self performSegueWithIdentifier:@"login" sender:nil];
    } else {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(myXmppDidLogin) name:MyXmppDidLoginNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(myXmppConnectFailed) name:MyXmppConnectFailedNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(myXmppAuthenticateFailed) name:MyXmppAuthenticateFailedNotification object:nil];
    }
    _recentTableView.dataSource = self;
    _recentTableView.delegate = self;
    _recentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _dataManager = [DataManager shareManager];
    _recentController = [_dataManager getRecent];
    _resultsControllerDelegate = [[MyFetchedResultsControllerDelegate alloc]initWithTableView:_recentTableView withScrolling:NO];
    _recentController.delegate = _resultsControllerDelegate;
    [_recentTableView registerNib:[UINib nibWithNibName:@"RecentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"recentCell"];//注册nib
    
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.tabBarController.tabBar.hidden == YES) {
        self.tabBarController.tabBar.hidden = NO;
    }
    if ([[MyXMPP shareInstance].stream isConnecting]) {
        self.navigationItem.title = @"最近联系人(连接中)";
    } else if ([[MyXMPP shareInstance].stream isDisconnected]) {
        self.navigationItem.title = @"最近联系人(未连接)";
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"chat"]) {//sender为数组，第一个为name，第二个用于指示是否p2p
        ChatViewController *destinationVC = segue.destinationViewController;
        NSArray *options = sender;
        destinationVC.title = options[0];
        destinationVC.chatObjectString = options[0];
        NSNumber *isP2P = options[1];
        destinationVC.p2pChat = isP2P.boolValue;
    } else if ([segue.identifier isEqualToString:@"createGroup"]) {
        UINavigationController *destinationNavigationController = segue.destinationViewController;
        CreateGroupsViewController *createGroupVC = destinationNavigationController.childViewControllers[0];
        createGroupVC.fatherVC = self;
    }
}

- (void)myXmppDidLogin {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MyXmppDidLoginNotification object:nil];
    self.navigationItem.title = @"最近联系人";
}

- (void)myXmppConnectFailed {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MyXmppConnectFailedNotification object:nil];
    self.navigationItem.title = @"最近联系人（未连接）";
}

- (void)myXmppAuthenticateFailed {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"登录失败" message:@"密码已修改，请重新登录。" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];

}

#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = _recentController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *recentIdentifier = @"recentCell";
    RecentCell *cell = [tableView dequeueReusableCellWithIdentifier:recentIdentifier forIndexPath:indexPath];//在此之前需要对nib 的cell进行注册
    LastMessage *lastMessage = [_recentController objectAtIndexPath:indexPath];
    XMPPvCardTemp *vCardTemp = [[MyXMPP shareInstance]fetchFriend:[XMPPJID jidWithUser:lastMessage.username domain:myDomain resource:nil]];
    
    cell.usernamelabel.text = lastMessage.username;
    cell.lastmessagelabel.attributedText = [RegularExpressionTool stringTranslation2FaceView:lastMessage.body];
    
    if (vCardTemp.photo != nil) {
        cell.userimage.image = [UIImage imageWithData:vCardTemp.photo];
    } else {
        cell.userimage.image = [UIImage imageNamed:@"1"];
    }

    cell.lastmessagetime.text = [Tool stringFromDate:[NSDate dateWithTimeIntervalSince1970:lastMessage.time.doubleValue]];

    NSNumber *num = lastMessage.unread;
    cell.nonreadmessagenum.text = [num stringValue];
    [cell setUnread:num];
       
    return cell;
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LastMessage *lastMessage = [_recentController objectAtIndexPath:indexPath];
    NSArray *options = nil;
    if (lastMessage.isP2P.boolValue) {
        options = @[lastMessage.username, @1];
    } else {
        options = @[lastMessage.username, @0];
    }
    [self performSegueWithIdentifier:@"chat" sender:options];//跳转到chat界面，并传参数，即当前聊天对象名称
    
    [_dataManager updateUsername:lastMessage.username];
}//当点击一个tableview时会调用以上代理，触发跳转到聊天界面

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    LastMessage *message = [_recentController objectAtIndexPath:indexPath];
    [_dataManager deleteRecentUsername:message.username isP2P:message.isP2P.boolValue];
}

#pragma mark - popover view
- (IBAction)PopoverBtnClick:(UIButton *)sender {
    PopoverViewController *popoverVc = [[PopoverViewController alloc] init];
    [popoverVc setCreateGroupBlock:^{//不会引起循环引用
        [self performSegueWithIdentifier:@"createGroup" sender:nil];
    } showGroupBlock:^{
//        [self sendPic2Server];
    }];
    popoverVc.preferredContentSize = CGSizeMake(100, 150);
    popoverVc.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *pop = popoverVc.popoverPresentationController;
    pop.sourceView = _addBtn;
    pop.sourceRect = _addBtn.bounds;
    pop.permittedArrowDirections = UIPopoverArrowDirectionUnknown; //箭头方向,如果是baritem不设置方向，会默认up，up的效果也是最理想的
    pop.delegate = self;

    [self presentViewController:popoverVc animated:YES completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}


@end
