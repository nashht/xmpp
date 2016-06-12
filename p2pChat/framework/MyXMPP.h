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
#import "XMPPMUC.h"
@class XMPPStream;
@class XMPPvCardTemp;
@class XMPPGroupCoreDataStorageObject;
@class XMPPUserCoreDataStorageObject;
@class XMPPRoster;
@class XMPPvCardTempModule;
@class XMPPRoom;
@class XMPPRoomCoreDataStorage;
@class DataManager;
@class PhotoLibraryCenter;
@class XMPPRoomOccupantCoreDataStorageObject;

typedef NS_ENUM (char, MessageType) {
    MessageTypeMessage = 0,
    MessageTypeRecord,
    MessageTypePicture,
    MessageTypeFile,
    MessageTypeAudio,
    MessageTypeVideo,
};

typedef NS_ENUM(int, MyXMPPStatus) {
    MyXMPPStatusOnline = 0,
    MyXMPPStatusBusy,
    MyXMPPStatusOffline
};

static NSString *myDomain = @"xmpp.test";

extern NSString *MyXmppDidLoginNotification;
extern NSString *MyXmppConnectFailedNotification;
extern NSString *MyXmppAuthenticateFailedNotification;
extern NSString *MyXmppUserStatusChangedNotification;
extern NSString *MyXmppRoomDidConfigurationNotification;

@interface MyXMPP : NSObject

+ (instancetype)shareInstance;

@property (strong, nonatomic) XMPPStream *stream;
@property (strong, nonatomic, readonly) XMPPvCardTemp *myVCardTemp;
@property (strong, nonatomic, readonly) XMPPUserCoreDataStorageObject *myCoreData;
@property (strong, nonatomic, readonly) XMPPRoster *roster;
@property (strong, nonatomic, readonly) XMPPvCardTempModule *vCardModule;
@property (strong, nonatomic, readonly) XMPPJID *myjid;
@property (strong, nonatomic) XMPPRoom *chatroom;
@property (strong, nonatomic) XMPPRoomCoreDataStorage *roomStorage;
@property (strong, nonatomic) XMPPMUC *muc;//用于处理好友邀请
@property (strong, nonatomic) XMPPRoomOccupantCoreDataStorageObject *roomOccupant;
@property (assign, nonatomic, readonly) MyXMPPStatus myStatus;

@property (strong, nonatomic, readonly) DataManager *dataManager;
@property (strong, nonatomic, readonly) PhotoLibraryCenter *photoLibraryCenter;

@property (copy, nonatomic) void (^fetchGroupMemberBlock)(NSArray *members);

- (void)loginWithName:(NSString *)user Password:(NSString *)password;
- (void)loginout;
- (void)reconnect;

- (void)online;
- (void)busy;
- (void)offline;

@end
