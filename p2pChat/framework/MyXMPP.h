//
//  MyXMPP.h
//  p2pChat
//
//  Created by xiaokun on 16/3/4.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "XMPPJID.h"
@class XMPPvCardTemp;

#define MyXmppDidLoginNotification @"MyXmppDidLoginNotification"
#define MyXmppLoginFailedNotification @"MyXmppLoginFailedNotification"
#define MyXmppConnectFailedNotification @"MyXmppConnectFailedNotification"
#define MyXmppAuthenticateFailedNotification @"MyXmppAuthenticateFailedNotification"

typedef NS_ENUM (char, MessageType) {
    MessageTypeMessage = 0,
    MessageTypeRecord,
    MessageTypePicture,
    MessageTypeFile,
    MessageTypeAudio,
    MessageTypeVideo,
};

@interface MyXMPP : NSObject

+ (instancetype)shareInstance;

- (void)loginWithName:(NSString *)user Password:(NSString *)password;

- (void)sendMessage:(NSString *)text ToUser:(NSString *) user;
- (void)sendAudio:(NSString *)path ToUser:(NSString *)user;
- (void)sendPicture:(NSString *)path ToUser:(NSString *)user;

- (void)updateFriendsList;
- (void)fetchFriend:(NSString *)user;

- (void)updateMyEmail:(NSArray *)email;
- (void)updateMyNote:(NSString *)note;
- (void)updateMyTel:(NSString *)tel;
- (void)changeMyPassword:(NSString *)newpassword;

- (NSFetchedResultsController *)getFriends;

@end
