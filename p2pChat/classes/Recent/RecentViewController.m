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
#import "LastMessage.h"
#import "RecentCell.h"
#import "ChatViewController.h"
#import "Tool.h"

@interface RecentViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *recentTableView;

@property (strong, nonatomic) DataManager *dataManager;
@property (strong, nonatomic) NSFetchedResultsController *recentController;
@property (strong, nonatomic) MyFetchedResultsControllerDelegate *resultsControllerDelegate;

@end

@implementation RecentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"最近联系人";
    
    if ([[NSUserDefaults standardUserDefaults]stringForKey:@"name"] == nil) {
        [self performSegueWithIdentifier:@"login" sender:nil];
    } else {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(myXmppDidLogin) name:MyXmppDidLoginNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(myXmppConnectFailed) name:MyXmppConnectFailedNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(myXmppAuthenticateFailed) name:MyXmppAuthenticateFailedNotification object:nil];
    }
    _recentTableView.dataSource = self;
    _recentTableView.delegate = self;
    _dataManager = [DataManager shareManager];
    _recentController = [_dataManager getRecent];
    _resultsControllerDelegate = [[MyFetchedResultsControllerDelegate alloc]initWithTableView:_recentTableView];
    _recentController.delegate = _resultsControllerDelegate;
    [_recentTableView registerNib:[UINib nibWithNibName:@"RecentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"recentCell"];//注册nib
    
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.tabBarController.tabBar.hidden == YES) {
        self.tabBarController.tabBar.hidden = NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"chat"]) {
        ChatViewController *destinationVC = segue.destinationViewController;
        XMPPJID *jid = [XMPPJID jidWithUser:sender domain:@"xmpp.test" resource:@"iphone"];
        destinationVC.title = sender;
        destinationVC.userJid = jid;
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
//    UIAlertController
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
    cell.usernamelabel.text = lastMessage.username;
    cell.lastmessagelabel.text = lastMessage.body;
    [cell awakeFromNib];
    cell.userimage.image = [UIImage imageNamed:@"1"];
    cell.lastmessagetime.text = [Tool stringFromDate:lastMessage.time];

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
    [self performSegueWithIdentifier:@"chat" sender:lastMessage.username];//跳转到chat界面，并传参数，即当前聊天对象名称
    [_dataManager updateUsername:lastMessage.username];
}//当点击一个tableview时会调用以上代理，触发跳转到聊天界面

@end
