//
//  RecordFrameModel.h
//  p2pChat
//
//  Created by nashht on 16/3/15.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UiKit/UiKit.h>
#import "Message.h"
#import "Message+CoreDataProperties.h"

@class MessageModel;

@interface RecordFrameModel : NSObject
@property(nonatomic,assign,readonly) CGRect timeFrame;
@property(nonatomic,assign,readonly) CGRect bodyFrame;
@property(nonatomic,assign,readonly) CGRect photoFrame;
@property(nonatomic,assign,readonly) CGFloat cellHeight;

@property(nonatomic,strong) Message *message;

@end

