//
//  MyXMPP+VCard.h
//  p2pChat
//
//  Created by xiaokun on 16/4/21.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MyXMPP.h"

@interface MyXMPP (VCard)

- (XMPPvCardTemp *)fetchFriend:(XMPPJID *)userJid;

- (void)updateMyEmail:(NSString *)email;
- (void)updateMyNote:(NSString *)note;
- (void)updateMyTel:(NSString *)tel;
- (void)changeMyPassword:(NSString *)newpassword;

@end
