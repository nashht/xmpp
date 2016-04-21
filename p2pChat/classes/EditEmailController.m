//
//  EditEmailController.m
//  p2pChat
//
//  Created by admin on 16/4/6.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "EditEmailController.h"
#import "LastMessage.h"
#import "MyXMPP+VCard.h"

@interface EditEmailController ()<UITextFieldDelegate>

@end

@implementation EditEmailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _emailText.text = @"ios@nmrc.com";
    _emailText.delegate = self;
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveItem;
    self.navigationItem.title = @"请输入邮箱";
    self.emailText.borderStyle = UITextBorderStyleRoundedRect;
}

- (void)viewDidAppear:(BOOL)animated {
    [_emailText becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
}

- (void)save {
#warning 检查合法性
    [[MyXMPP shareInstance] updateMyEmail:_emailText.text];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self save];
    return YES;
}

@end
