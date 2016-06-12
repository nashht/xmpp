//
//  PopoverViewController.h
//  p2pChat
//
//  Created by nashht on 16/4/15.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ popViewBlock)();

@interface PopoverViewController : UIViewController

- (void)setCreateGroupBlock:(void (^)(void))createGroup showMyGroupBlock:(void (^)(void))showMyGroups showAllGroupBlock:(void (^)(void))showAllGroups;

@end
