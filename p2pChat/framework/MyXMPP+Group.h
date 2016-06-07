//
//  MyXMPP+Group.h
//  p2pChat
//
//  Created by xiaokun on 16/4/21.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MyXMPP.h"
#import "XMPPRoomCoreDataStorage.h"

typedef void (^fetchedBlock) (NSArray *members);

@interface MyXMPP (Group)<XMPPRoomStorage, XMPPRoomDelegate>

- (void)creatGroupName:(NSString *)groupName withpassword:(NSString *)rommpwd andsubject:(NSString *)subject;//只有创建者调用
- (void)inviteFriends:(NSString *)friendname withMessage:(NSString *)text;
- (void)fetchMembersFromGroup:(NSString *)groupName withCompletion:(fetchedBlock) block;
- (void)fetchAllRoomsWithCompletion:(fetchedBlock) block;
- (void)fetchMyRoomsWithCompletion:(fetchedBlock) block;

- (void)sendMessage:(NSString *)text ToGroup:(NSString *)groupname;
//- (void)sendPicture:(NSString *)path ToGroup:(NSString *)groupname;
- (void)sendAudio:(NSString *)path ToGroup:(NSString *)groupname withlength:(NSString *)length;

- (void)destroyChatRoom;//删除聊天室
- (void)leaveChatRoom;//退出聊天室
- (void)setGroupSubject:(NSString *)subject;//设置群聊主题
- (void)deleteMember:(NSString *)member FromGroup:(NSString *)group;
- (void)getJoinedRooms;

@end
