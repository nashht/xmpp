//
//  PopoverViewController.m
//  p2pChat
//
//  Created by nashht on 16/4/15.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "PopoverViewController.h"
#import "CreateGroupsViewController.h"
#import "RecentViewController.h"

@interface PopoverViewController ()

@property (strong, nonatomic) CreateGroupsViewController *createGroupVC;
@property (strong, nonatomic) RecentViewController *baseVC;

@property (strong, nonatomic) void (^createGroupBlock)(void);
@property (strong, nonatomic) void (^showMyGroupsBlock)(void);
@property (strong, nonatomic) void (^showAllGroupsBlock)(void);

@end

@implementation PopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setCreateGroupBlock:(void (^)(void))createGroup showMyGroupBlock:(void (^)(void))showMyGroups showAllGroupBlock:(void (^)(void))showAllGroups{
    _createGroupBlock = createGroup;
    _showMyGroupsBlock = showMyGroups;
    _showAllGroupsBlock = showAllGroups;
}

- (IBAction)creatGroup:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    _createGroupBlock();
}

- (IBAction)showMyGroups:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    _showMyGroupsBlock();
}

- (IBAction)showAllGroups:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    _showAllGroupsBlock();
}

@end
