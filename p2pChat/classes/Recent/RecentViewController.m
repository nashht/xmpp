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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (strong, nonatomic) DataManager *dataManager;
@property (strong, nonatomic) NSFetchedResultsController *recentController;
@property (strong, nonatomic) MyFetchedResultsControllerDelegate *resultsControllerDelegate;

@end

@implementation RecentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[NSUserDefaults standardUserDefaults]stringForKey:@"name"] == nil) {
        [self performSegueWithIdentifier:@"login" sender:nil];
    } else {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(myXmppDidLogin) name:MyXmppDidLoginNotification object:nil];
        [_activityView startAnimating];
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
    [_activityView stopAnimating];
    [_activityView removeFromSuperview];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
    cell.userimage.image = [UIImage imageNamed:@"1"];
    cell.lastmessagetime.text = [Tool stringFromDate:lastMessage.time];
    
    return cell;
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LastMessage *lastMessage = [_recentController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"chat" sender:lastMessage.username];//跳转到chat界面，并传参数，即当前聊天对象名称
}//当点击一个tableview时会调用以上代理，触发跳转到聊天界面

@end
