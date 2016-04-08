//
//  EditEmailController.m
//  p2pChat
//
//  Created by admin on 16/4/6.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "EditEmailController.h"
#import "LastMessage.h"
#import "MyXMPP.h"

@interface EditEmailController ()

@end

@implementation EditEmailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _emailText.text = @"ios@nmrc.com";
    
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveItem;
    self.navigationItem.title = @"请输入邮箱";
    self.emailText.borderStyle = UITextBorderStyleRoundedRect;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)save {
    
    [[MyXMPP shareInstance] updateMyEmail:@[_emailText.text]];
    
}



@end
