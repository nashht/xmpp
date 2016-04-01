//
//  LoginViewController.m
//  p2pChat
//
//  Created by xiaokun on 16/1/4.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "LoginViewController.h"
#import "MyXMPP.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(myXmppDidLogin) name:MyXmppDidLoginNotification object:nil];
}

- (IBAction)login:(id)sender {
    NSString *name = _nameTF.text;
    NSString *password = _passwordTF.text;
    [[NSUserDefaults standardUserDefaults]setValue:name forKey:@"name"];
    [[NSUserDefaults standardUserDefaults]setValue:password forKey:@"password"];
    [[MyXMPP shareInstance]loginWithName:name Password:password];
}

- (void)myXmppDidLogin {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[NSUserDefaults standardUserDefaults]setObject:_nameTF.text forKey:@"name"];
    [[NSUserDefaults standardUserDefaults]setObject:_passwordTF.text forKey:@"password"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
