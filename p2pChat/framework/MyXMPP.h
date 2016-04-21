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
@class XMPPStream;
@class XMPPvCardTemp;
@class XMPPGroupCoreDataStorageObject;
@class XMPPRoster;
@class XMPPvCardTempModule;
@class XMPPRoom;
@class XMPPRoomCoreDataStorage;
@class DataManager;

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

static NSString *myDomain = @"xmpp.test";

@interface MyXMPP : NSObject

+ (instancetype)shareInstance;

@property (strong, nonatomic) XMPPStream *stream;
@property (strong, nonatomic, readonly) XMPPvCardTemp *myVCardTemp;
@property (strong, nonatomic, readonly) XMPPRoster *roster;
@property (strong, nonatomic, readonly) XMPPvCardTempModule *vCardModule;
@property (strong, nonatomic, readonly) XMPPJID *myjid;
@property (strong, nonatomic) XMPPRoom *chatroom;
@property (strong, nonatomic) XMPPRoomCoreDataStorage *roomStorage;

@property (strong, nonatomic, readonly) DataManager *dataManager;

- (void)loginWithName:(NSString *)user Password:(NSString *)password;
- (void)loginout;

@end
