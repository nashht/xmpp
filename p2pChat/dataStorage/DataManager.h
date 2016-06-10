//
//  DataManager.h
//  ZXKChat_2
//
//  Created by xiaokun on 15/12/16.
//  Copyright © 2015年 xiaokun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *context;

@property (assign, nonatomic) NSInteger totalUnreadNumber;

+ (instancetype)shareManager;
- (void)clearAll;//删除最近联系人、所有聊天记录、群聊天记录

@end

// 对message的操作
@interface DataManager (Message)

- (NSFetchedResultsController *)getMessageByUsername:(NSString *)username;
- (void)saveMessageWithUsername:(NSString *)username time:(NSNumber *)time body:(NSString *)body isOut:(BOOL)isOut;//isOut真为发出，假为收到
- (void)saveRecordWithUsername:(NSString *)username time:(NSNumber *)time path:(NSString *)path length:(NSString *)length isOut:(BOOL)isOut;
- (void)savePhotoWithUsername:(NSString *)username time:(NSNumber *)time filename:(NSString *)filename thumbnail:(NSString *)thumbnailPath isOut:(BOOL)isOut;
- (void)saveFileWithUsername:(NSString *)username time:(NSNumber *)time filename:(NSString *)filename fileSize:(NSString *)fileSize isOut:(BOOL)isOut;
- (void)clearMessageByUsername:(NSString *)username;

@end

// 对last message的操作
@interface DataManager (LastMessage)

- (NSFetchedResultsController *)getRecent;
- (void)addRecentUsername:(NSString *)username time:(NSNumber *)time body:(NSString *)body isOut:(BOOL)isOut isP2P:(BOOL)isP2P;
- (void)updateUsername:(NSString *)username;//已读
- (void)deleteRecentUsername:(NSString *)username isP2P:(BOOL) isP2P;

@end

// 对group message的操作
@interface DataManager (GroupMessage)

- (NSFetchedResultsController *)getMessageByGroupname:(NSString *)groupname;
- (void)saveMessageWithGroupname:(NSString *)groupname username:(NSString *)username time:(NSNumber *)time body:(NSString *)body;
- (void)saveRecordWithGroupname:(NSString *)groupname username:(NSString *)username time:(NSNumber *)time path:(NSString *)path length:(NSString *)length;

@end
