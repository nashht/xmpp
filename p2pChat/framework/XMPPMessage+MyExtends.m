//
//  XMPPMessage+MyExtends.m
//  p2pChat
//
//  Created by admin on 16/4/21.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "XMPPMessage+MyExtends.h"

@implementation XMPPMessage (MyExtends)

- (NSString *)nmrcGetAttr:(NSString *)attr {
    NSArray *bodyArr = [self elementsForName:@"body"];
    DDXMLElement *body = bodyArr[0];
    return [[body attributeForName:attr]stringValue];
}

- (NSString *)getSubtype {
    return [self nmrcGetAttr:@"subtype"];
}

- (NSString *)getTime {
    return [self nmrcGetAttr:@"time"];
}

- (NSString *)getMore {
    return [self nmrcGetAttr:@"more"];
}

@end
