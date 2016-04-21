//
//  EditTelController.m
//  p2pChat
//
//  Created by admin on 16/4/6.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "EditTelController.h"
#import "MyXMPP+VCard.h"

@interface EditTelController ()<UITextFieldDelegate>

@end

@implementation EditTelController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _telText.text = @"12345678901";
    _telText.delegate = self;

    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveItem;
    self.navigationItem.title = @"请输入电话";
    self.telText.borderStyle = UITextBorderStyleRoundedRect;
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [_telText becomeFirstResponder];
}

- (void)save {
#warning 检查合法性
    [[MyXMPP shareInstance] updateMyTel:_telText.text];
}

#pragma mark text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self save];
    return YES;
}

@end
