//
//  PopoverViewController.m
//  p2pChat
//
//  Created by nashht on 16/4/15.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "PopoverViewController.h"
#import "CreatGroupsViewController.h"
#import "RecentViewController.h"

@interface PopoverViewController ()

@property (strong, nonatomic) CreatGroupsViewController *createGroupVC;
@property (strong, nonatomic) RecentViewController *baseVC;

@end

@implementation PopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)creatGroup:(id)sender {
    _createGroupVC = [[CreatGroupsViewController alloc]init];
    [self presentViewController:_createGroupVC animated:YES completion:nil];
}

- (IBAction)showGroups:(id)sender {
}
@end
