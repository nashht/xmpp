//
//  MyXMPP+Roster.h
//  p2pChat
//
//  Created by xiaokun on 16/4/21.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MyXMPP.h"
#import "XMPPRosterCoreDataStorage.h"

@interface MyXMPP (Roster)<XMPPRosterStorage, XMPPRosterDelegate>

- (void)updateFriendsList;
- (NSArray<XMPPGroupCoreDataStorageObject *> *)getFriendsGroup;
- (XMPPUserCoreDataStorageObject *)fetchUserWithUsername:(NSString *)username;

@end
