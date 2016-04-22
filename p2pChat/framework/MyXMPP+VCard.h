//
//  MyXMPP+VCard.h
//  p2pChat
//
//  Created by xiaokun on 16/4/21.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MyXMPP.h"
#import "XMPPvCardTemp.h"

#define MyXmppUpdatevCardSuccessNotification @"MyXmppUpdatevCardSuccessNotification"
#define MyXmppUpdatevCardFailedNotification @"MyXmppUpdatevCardFailedNotification"

@interface MyXMPP (VCard)

- (XMPPvCardTemp *)fetchFriend:(XMPPJID *)userJid;

- (void)updateMyEmail:(NSString *)email;
- (void)updateMyTel:(NSString *)tel;
- (void)updateMyPhone:(NSString *)phone;
- (void)updateMyAddress:(NSString *)address;
- (void)updataeMyPhoto:(NSData *)photoData;
- (void)updateMyTitle:(NSString *)title;

- (void)changeMyPassword:(NSString *)newpassword;

@end
