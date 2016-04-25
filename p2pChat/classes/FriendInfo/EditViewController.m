//
//  EditViewController.m
//  p2pChat
//
//  Created by xiaokun on 16/4/24.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "EditViewController.h"

@interface EditViewController ()

@property (weak, nonatomic) IBOutlet UITextField *infoTextField;

@property (strong, nonatomic) XMPPvCardTemp *myvCard;

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _myvCard = [MyXMPP shareInstance].myVCardTemp;
    
    switch (_type) {
        case MyXmppUpdateTypeMobilePhone:
            _infoTextField.text = _myvCard.note;
            self.navigationItem.title = @"请输入新手机号";
            break;
        case MyXmppUpdateTypeAddress:
            _infoTextField.text = _myvCard.addresses[0];
            self.navigationItem.title = @"请输入新地址";
            break;
        case MyXmppUpdateTypeEmail:
            _infoTextField.text = _myvCard.emailAddresses[0];
            self.navigationItem.title = @"请输入新邮箱";
            break;
        case MyXmppUpdateTypePhone:
            _infoTextField.text = _myvCard.telecomsAddresses[0];
            self.navigationItem.title = @"请输入新电话";
            break;
        case MyXmppUpdateTypeTitle:
            _infoTextField.text = _myvCard.title;
            self.navigationItem.title = @"请输入新部门（待修改）";
            break;
    }
    [_infoTextField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didUpdate) name:MyXmppUpdatevCardSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didNotUpdate) name:MyXmppUpdatevCardFailedNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
}

- (IBAction)save:(id)sender {
    [[MyXMPP shareInstance]updateMyInfo:_infoTextField.text withType:_type];
    [_infoTextField resignFirstResponder];
}

- (void)didUpdate {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didNotUpdate {
    UIAlertController *alert = [[UIAlertController alloc]init];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^ (UIAlertAction *action) {
        //do what?
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
