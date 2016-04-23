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

@property (copy, nonatomic) NSString *chatObjectString;//可以是user，也可以是group
@property (assign, nonatomic, getter=isP2PChat) BOOL P2PChat;

- (void)showMoreView;

@end
