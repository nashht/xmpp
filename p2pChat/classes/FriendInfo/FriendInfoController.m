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

@end

@implementation FriendInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    XMPPvCardTemp *friendVCard = [[MyXMPP shareInstance]fetchFriend:_userObj.jid];
    [_photoImageView.layer setCornerRadius:CGRectGetHeight([_photoImageView bounds])/2];
    _photoImageView.layer.masksToBounds = true;
    if (friendVCard.photo == nil) {//好友头像
        [_photoImageView setImage:[UIImage imageNamed:@"0"]];
    } else {
        [_photoImageView setImage:[UIImage imageWithData:friendVCard.photo]];
    }
    _nameLabel.text = _userObj.jid.user;//好友名称
    XMPPGroupCoreDataStorageObject *groupInfo = (XMPPGroupCoreDataStorageObject *)_userObj.groups.allObjects[0];
    _departmentLabel.text = groupInfo.name;//好友所属部门
    if (friendVCard.note == nil) {//电话
        _telephone.text = @"空";
    }else {
        _telephone.text = friendVCard.note;
    }
    
    if (friendVCard.title == nil) {//职务
        _position.text = @"空";
    }else {
        _position.text = friendVCard.title;
    }
    if (friendVCard.mailer == nil){//邮箱
        _emailLabel.text = @"空";
    }else{
        _emailLabel.text = friendVCard.mailer;
    }
    if (friendVCard.telecomsAddresses == nil) {//座机
        _phoneLabel.text = @"空";
    }else{
        _phoneLabel.text = friendVCard.telecomsAddresses[0];
    }
    if (friendVCard.addresses == nil) {//办公地址
        _address.text = @"空";
    }else{
        _address.text = friendVCard.addresses[0];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ChatViewController *chatVc = (ChatViewController *)segue.destinationViewController;
    chatVc.title = _userObj.jid.user;
    chatVc.userJid = _userObj.jid;
}

@end
