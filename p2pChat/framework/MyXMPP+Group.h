//
//  MyXMPP+Group.h
//  p2pChat
//
//  Created by xiaokun on 16/4/21.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MyXMPP.h"
#import "XMPPRoomCoreDataStorage.h"


@interface MyXMPP (Group)<XMPPRoomStorage, XMPPRoomDelegate>

- (void)creatGroupName:(NSString *)groupName withpassword:(NSString *)rommpwd andsubject:(NSString *)subject;//只有创建者调用
- (void)inviteFriends:(NSString *)friendname withMessage:(NSString *)text;
- (void)fetchMembersFromGroup;
- (void)sendMessage:(NSString *)text ToGroup:(NSString *)groupname;
//- (void)sendPicture:(NSString *)path ToGroup:(NSString *)groupname;
- (void)sendAudio:(NSString *)path ToGroup:(NSString *)groupname withlength:(NSString *)length;
- (void)destroyChatRoom;

@end
