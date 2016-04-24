//
//  MessageBean.h
//  p2pChat
//
//  Created by xiaokun on 16/4/24.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageBean : NSObject

@property (nonatomic,readonly, strong) NSNumber *isOut;
@property (nonatomic, readonly, copy) NSString *body;
@property (nonatomic, readonly, strong) NSNumber *type;
@property (nonatomic, readonly, strong) NSNumber *time;
@property (nonatomic, readonly, copy) NSString *username;

- (instancetype)initWithUsername:(NSString *)username type:(NSNumber *)type body:(NSString *)body time:(NSNumber *)time isOut:(NSNumber *)isOut isP2P:(BOOL)isP2P;

@end
