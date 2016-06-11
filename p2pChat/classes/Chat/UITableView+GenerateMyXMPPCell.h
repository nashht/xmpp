//
//  UITableView+GenerateMyXMPPCell.h
//  XMPP
//
//  Created by xiaokun on 16/6/11.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MessageBean;

extern NSString *textReuseIdentifier;
extern NSString *audioReuseIdentifier;
extern NSString *pictureReuseIdentifier;
extern NSString *fileReuseIdentifier;

@interface UITableView (GenerateMyXMPPCell)

- (UITableViewCell *)dequeueMyXMPPCellFromMessage:(MessageBean *)message;

@end
