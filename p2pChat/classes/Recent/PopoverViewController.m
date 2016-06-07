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

@property (strong, nonatomic) popViewBlock createGroupBlock;
@property (strong, nonatomic) popViewBlock showGroupsBlock;
@property (strong, nonatomic) popViewBlock showAllGroupsBlock;

@end

@implementation PopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setCreateGroupBlock:(popViewBlock)createGroup showGroupBlock:(popViewBlock)showGroups showAllGroupsBlock:(popViewBlock)showAllGroups {
    _createGroupBlock = createGroup;
    _showGroupsBlock = showGroups;
    _showAllGroupsBlock = showAllGroups;
}

- (IBAction)creatGroup:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    _createGroupBlock();
}

- (IBAction)showGroups:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    _showGroupsBlock();
}

- (IBAction)showAllGroups:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    _showAllGroupsBlock();
}
@end
