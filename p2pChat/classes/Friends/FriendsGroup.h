//
//  FriendsGroup.h
//  p2pChat
//
//  Created by nashht on 16/3/24.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendsGroup : NSObject
//    好友
@property (nonatomic, strong) NSArray *friends;
//    组名
@property (nonatomic, copy) NSString *name;
//    在线人数
@property (nonatomic, assign) int online;
//    是否展开
@property (nonatomic,assign,getter = isOpened)BOOL opened;
@end
