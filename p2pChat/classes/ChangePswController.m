//
//  ChangePswController.m
//  p2pChat
//
//  Created by admin on 16/4/6.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "ChangePswController.h"
#import "MyXMPP.h"

@interface ChangePswController ()

@end

@implementation ChangePswController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveItem;
    self.navigationItem.title = @"请输入新密码";
    self.Pswnew.borderStyle = UITextBorderStyleRoundedRect;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) save{
    
    [[MyXMPP shareInstance] changeMyPassword:_Pswnew.text];
    
    
}

@end
