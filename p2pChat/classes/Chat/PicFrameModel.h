//
//  PicFrameMode.h
//  p2pChat
//
//  Created by nashht on 16/3/15.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UiKit/UiKit.h>
@class MessageModel;
@class MessageBean;

@interface PicFrameModel : NSObject

@property (nonatomic,assign,readonly) CGRect timeFrame;
@property (nonatomic,assign,readonly) CGRect bodyFrame;
@property (nonatomic,assign,readonly) CGRect photoFrame;
@property (nonatomic,assign,readonly) CGFloat cellHeight;

@property (nonatomic,strong) MessageBean *message;
@property (nonatomic, strong, readonly) UIImage *image;

- (void)setMessage:(MessageBean *)message withCompletionHandler:(void (^)(PicFrameModel *model))handler;

@end