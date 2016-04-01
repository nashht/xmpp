//
//  FriendInfoController.h
//  p2pChat
//
//  Created by nashht on 16/3/31.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XMPPUserCoreDataStorageObject;

@interface FriendInfoController : UITableViewController

@property (strong,  nonatomic) XMPPUserCoreDataStorageObject *userObj;

@end
