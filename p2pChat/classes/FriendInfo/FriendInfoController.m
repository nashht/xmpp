//
//  FriendInfoController.m
//  p2pChat
//
//  Created by nashht on 16/3/31.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "FriendInfoController.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "ChatViewController.h"
#import "MyXMPP.h"
#import "XMPPvCardTemp.h"

@interface FriendInfoController ()

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation FriendInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    XMPPvCardTemp *friendVCard = [[MyXMPP shareInstance]fetchFriend:_userObj.jid];
    if (friendVCard.photo == nil) {
        [_photoImageView setImage:[UIImage imageNamed:@"0"]];
    } else {
        [_photoImageView setImage:[UIImage imageWithData:friendVCard.photo]];
    }
    _nameLabel.text = friendVCard.name;
    _departmentLabel.text = _userObj.sectionName;
    _phoneLabel.text = friendVCard.note;
    _emailLabel.text = friendVCard.emailAddresses[0];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ChatViewController *chatVc = (ChatViewController *)segue.destinationViewController;
    chatVc.userJid = _userObj.jid;
}

@end
