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

typedef NS_ENUM (NSInteger, MyXmppUpdateType) {
    MyXmppUpdateTypeMobilePhone = 0,
    MyXmppUpdateTypeEmail,
    MyXmppUpdateTypePhone,
    MyXmppUpdateTypeTitle,
    MyXmppUpdateTypeAddress
};

@interface MyXMPP (VCard)

- (XMPPvCardTemp *)fetchFriend:(XMPPJID *)userJid;

- (void)updataeMyPhoto:(NSData *)photoData;
- (void)updateMyInfo:(NSString *)newValue withType:(MyXmppUpdateType)type;

- (void)changeMyPassword:(NSString *)newpassword;

@end
