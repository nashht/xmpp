//
//  MessageModel.h
//  p2pChat
//
//  Created by nashht on 16/3/10.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UiKit/UiKit.h>
#import "Message+CoreDataProperties.h"
#import "MyXMPP.h"
#import "XMPPvCardTemp.h"
@class MessageModel;
@class MessageBean;

@interface MessageFrameModel : NSObject

@property(nonatomic,assign,readonly) CGRect timeFrame;
@property(nonatomic,assign,readonly) CGRect bodyFrame;
@property(nonatomic,assign,readonly) CGRect photoFrame;
@property(nonatomic,assign,readonly) CGFloat cellHeight;
//@property(nonatomic,strong) XMPPvCardTemp *vCard;

@property(nonatomic,strong) MessageBean *message;//可能是个人消息，也可能是群消息

@end
