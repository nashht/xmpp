//
//  EditTelController.m
//  p2pChat
//
//  Created by admin on 16/4/6.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "EditTelController.h"
#import "MyXMPP.h"


@interface EditTelController ()

@end

@implementation EditTelController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _telText.text = @"12345678901";

    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveItem;
    self.navigationItem.title = @"请输入电话";
    self.telText.borderStyle = UITextBorderStyleRoundedRect;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)save {

    [[MyXMPP shareInstance] updateMyTel:_telText.text];
    
}

@end
