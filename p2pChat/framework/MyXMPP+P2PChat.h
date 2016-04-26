//
//  MyXMPP+P2PChat.h
//  p2pChat
//
//  Created by xiaokun on 16/4/21.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MyXMPP.h"

@interface MyXMPP (P2PChat)

- (void)sendMessage:(NSString *)text ToUser:(NSString *) user;
- (void)sendAudio:(NSString *)path ToUser:(NSString *)user length:(NSString *)length;
- (void)sendPictureIdentifier:(NSString *)identifier data:(NSData *)imageData ToUser:(NSString *)user;//发送的是缩略后的图

@end
