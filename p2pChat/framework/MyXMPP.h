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
@class XMPPGroupCoreDataStorageObject;



#define MyXmppDidLoginNotification @"MyXmppDidLoginNotification"
#define MyXmppConnectFailedNotification @"MyXmppConnectFailedNotification"
#define MyXmppAuthenticateFailedNotification @"MyXmppAuthenticateFailedNotification"

#define MyXmppRoomDidConfigurationNotification @"MyXmppRoomDidConfigurationNotification"


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

@property (strong, nonatomic, readonly) XMPPvCardTemp *myVCardTemp;

- (void)loginWithName:(NSString *)user Password:(NSString *)password;
- (void)loginout;

- (void)sendMessage:(NSString *)text ToUser:(NSString *) user;
- (void)sendAudio:(NSString *)path ToUser:(NSString *)user length:(NSString *)length;
- (void)sendPicture:(NSString *)path ToUser:(NSString *)user;

- (void)updateFriendsList;
- (XMPPvCardTemp *)fetchFriend:(XMPPJID *)userJid;

- (void)updateMyEmail:(NSString *)email;
- (void)updateMyNote:(NSString *)note;
- (void)updateMyTel:(NSString *)tel;
- (void)changeMyPassword:(NSString *)newpassword;

- (NSArray<XMPPGroupCoreDataStorageObject *> *)getFriendsGroup;

- (void)creatGroupName:(NSString *)groupName withpassword:(NSString *)rommpwd andsubject:(NSString *)subject;//只有创建者调用
- (void)inviteFriends:(NSString *)friendname withMessage:(NSString *)text;
- (void)fetchMembersFromGroup;
- (void)sendGroupMessage:(NSString *)text;
//- (void)sendGroupPicture:(NSString *)path;
//- (void)sendGroupAudio:(NSString *)path length:(NSString *)length;
- (void)destroyChatRoom;


@end
