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
    
    //链接服务器失败
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(myXmppDidNotConnect) name:MyXmppConnectFailedNotification object:nil];
    
    //认证密码失败
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(myXmppDidNotAuthenticate) name:MyXmppAuthenticateFailedNotification object:nil];
    
    
    [_login.layer setCornerRadius:CGRectGetHeight([_login bounds])/4];
    _login.layer.masksToBounds = true;
    _login.frame = CGRectMake(199, 269, 400, 32);
    
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

- (void)myXmppDidNotConnect{
   [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    //添加服务器链接失败弹窗
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"连接失败" message:@"服务器连接失败，请检查网络。" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)myXmppDidNotAuthenticate{
   [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    //添加密码错误弹窗
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"登录失败" message:@"帐号或密码错误，请重新输入。" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
