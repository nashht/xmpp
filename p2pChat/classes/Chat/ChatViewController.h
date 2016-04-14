//
//  ChatViewController.h
//  p2pChat
//
//  Created by xiaokun on 16/1/4.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XMPPJID;

@interface ChatViewController : UIViewController

@property (strong, nonatomic) XMPPJID *userJid;

- (void)showMoreView;

@end
