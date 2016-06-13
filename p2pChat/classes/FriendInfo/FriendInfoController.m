//
//  FriendInfoController.m
//  p2pChat
//
//  Created by nashht on 16/3/31.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "FriendInfoController.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "XMPPGroupCoreDataStorageObject.h"
#import "ChatViewController.h"
#import "MyXMPP.h"
#import "MyXMPP+VCard.h"
#import "XMPPvCardTemp.h"

@interface FriendInfoController ()

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *telephone;
@property (weak, nonatomic) IBOutlet UILabel *position;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@end

@implementation FriendInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"消息" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = back;
    
    XMPPvCardTemp *friendVCard = [[MyXMPP shareInstance]fetchFriend:_userObj.jid];

    [_photoImageView.layer setCornerRadius:10];
    _photoImageView.layer.masksToBounds = true;
    if (friendVCard.photo == nil) {//好友头像
        [_photoImageView setImage:[UIImage imageNamed:@"1"]];
    } else {
        [_photoImageView setImage:[UIImage imageWithData:friendVCard.photo]];
    }
    _nameLabel.text = _userObj.jid.user;//好友名称
    XMPPGroupCoreDataStorageObject *groupInfo = (XMPPGroupCoreDataStorageObject *)_userObj.groups.allObjects[0];
    _departmentLabel.text = groupInfo.name;//好友所属部门
    
    _telephone.text = friendVCard.note ? : @"未设置";//手机
    _position.text = friendVCard.title ? : @"未设置";//职位
    _emailLabel.text = friendVCard.mailer ? : @"未设置";//邮箱
    _phoneLabel.text = friendVCard.uid ? : @"未设置";//座机
    _address.text = friendVCard.url ? : @"未设置";//地址
    if (!self.canSendMessage) {
        [_sendButton removeFromSuperview];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ChatViewController *chatVc = (ChatViewController *)segue.destinationViewController;
    chatVc.p2pChat = YES;
    chatVc.title = _userObj.jid.user;
    chatVc.chatObjectString = _userObj.jid.user;
}

#pragma mark data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.canSendMessage ? 3 : 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
