//
//  MessageBean.m
//  p2pChat
//
//  Created by xiaokun on 16/4/24.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MessageBean.h"
#import "MyXMPP+VCard.h"

@interface MessageBean ()

@property (nonatomic, assign) BOOL isP2P;

@end

@implementation MessageBean

- (instancetype)initWithUsername:(NSString *)username type:(NSNumber *)type body:(NSString *)body time:(NSNumber *)time isOut:(NSNumber *)isOut isP2P:(BOOL)isP2P {
    if (self = [super init]) {
        _username = username;
        _type = type;
        _body = body;
        _time = time;
        if (isP2P) {
            _isOut = isOut;
        } else {
            NSString *myName = [[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
            if ([username isEqualToString:myName]) {
                _isOut = [NSNumber numberWithBool:YES];
            } else {
                _isOut = [NSNumber numberWithBool:NO];
            }
        }
    }
    return self;
}

@end
