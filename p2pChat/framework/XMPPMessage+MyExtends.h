//
//  XMPPMessage+MyExtends.h
//  p2pChat
//
//  Created by admin on 16/4/21.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "XMPPMessage.h"

@interface XMPPMessage (MyExtends)

- (NSString *)getSubtype;
- (NSString *)getTime;
- (NSString *)getMore;

@end
