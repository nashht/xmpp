//
//  FriendInfoController.m
//  p2pChat
//
//  Created by nashht on 16/3/31.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "FriendInfoController.h"
#import "InfoHeader.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "ChatViewController.h"

@interface FriendInfoController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation FriendInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableHeaderView = [InfoHeader headerViewWithName:_userObj.nickname];
    
    UIView *footer = [[UIView alloc] init];
    self.tableView.tableFooterView = footer;
    footer.userInteractionEnabled = YES;

    footer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0, 0, 320, 50);
    imageView.center = footer.center;
    imageView.image = [UIImage imageNamed:@"bg_show_count.png"];
    
    
    UILabel *sendMsg = [[UILabel alloc] init];
    sendMsg.frame = CGRectMake(0, 0, 320, 50);
    sendMsg.center = footer.center;
    sendMsg.textAlignment = NSTextAlignmentCenter;
    sendMsg.text = @"发送消息";

    sendMsg.textColor = [UIColor whiteColor];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendMsgClick)];
    [footer addGestureRecognizer:singleTap];
    
    [footer addSubview:imageView];
    [footer addSubview:sendMsg];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
}

- (void)sendMsgClick{
//    NSLog(@"发送消息");
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ChatViewController *chatVc = (ChatViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"chat"];
    chatVc.title = _userObj.nickname;
    chatVc.userJid = _userObj.jid;
    [self.navigationController pushViewController:chatVc animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *friendInfoCellIdentifier = @"cell";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:friendInfoCellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:friendInfoCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:friendInfoCellIdentifier];
    }
    cell.textLabel.text = @"aa";
    
    return cell;
}

@end
