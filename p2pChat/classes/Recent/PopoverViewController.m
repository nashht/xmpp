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

@property (strong, nonatomic) void (^createGroupBlock)(void);
@property (strong, nonatomic) void (^showGroupsBlock)(void);

@end

@implementation PopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setCreateGroupBlock:(void (^)(void))createGroup showGroupBlock:(void (^)(void))showGroups {
    _createGroupBlock = createGroup;
    _showGroupsBlock = showGroups;
}

- (IBAction)creatGroup:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    _createGroupBlock();
}

- (IBAction)showGroups:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    _showGroupsBlock();
}
@end
