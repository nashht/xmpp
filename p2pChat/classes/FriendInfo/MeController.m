//
//  MeController.m
//  p2pChat
//
//  Created by nashht on 16/4/1.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MeController.h"
#import "MyXMPP.h"

@interface MeController ()

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation MeController 

- (void)viewDidLoad {
    
    self.navigationItem.title = @"我";
    [_photoView.layer setCornerRadius:CGRectGetHeight([_photoView bounds])/2];
    _photoView.layer.masksToBounds = true;
    _nameLabel.text = [[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
    _groupLabel.text = @"nmrc1";
    _phoneLabel.text = @"12345678901";
    _emailLabel.text = @"ios@nmrc.com";
    
    [[MyXMPP shareInstance] creatGroupName:@"123" withpassword:nil andsubject:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(invitenewfriends) name:MyXmppRoomDidConfigurationNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
}

- (void)invitenewfriends{
   [[MyXMPP shareInstance] inviteFriends:@"ht_test" withMessage:@"wewe"];

}

- (IBAction)updatePassword:(id)sender {
    
}

- (IBAction)loginOut:(id)sender {
    [[MyXMPP shareInstance] loginout];
}

@end
