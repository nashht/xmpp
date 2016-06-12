//
//  UITableView+GenerateMyXMPPCell.h
//  XMPP
//
//  Created by xiaokun on 16/6/11.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MessageBean;
#import "MessageFrameModel.h"
#import "MessageViewCell.h"
#import "RecordFrameModel.h"
#import "RecordViewCell.h"
#import "PicFrameModel.h"
#import "PicViewCell.h"
#import "FileFrameModel.h"
#import "FileCell.h"

extern NSString *textReuseIdentifier;
extern NSString *audioReuseIdentifier;
extern NSString *pictureReuseIdentifier;
extern NSString *fileReuseIdentifier;

@interface UITableView (GenerateMyXMPPCell)

- (UITableViewCell *)dequeueMyXMPPCellFromMessage:(MessageBean *)message;
- (CGFloat)heightOfMessage:(MessageBean *)message;

@end
