//
//  MessageViewCell.h
//  p2pChat
//
//  Created by nashht on 16/3/14.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessageFrameModel;
@interface MessageViewCell : UITableViewCell

@property(nonatomic,strong) MessageFrameModel* messageFrame;
@end
