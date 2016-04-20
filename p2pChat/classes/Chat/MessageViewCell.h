//
//  MessageViewCell.h
//  p2pChat
//
//  Created by nashht on 16/3/14.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyXMPP.h"
#import "XMPPvCardTemp.h"

@class MessageFrameModel;
@interface MessageViewCell : UITableViewCell

@property(nonatomic,strong) MessageFrameModel* messageFrame;
@property(nonatomic,strong) XMPPvCardTemp *vCard;
@end
