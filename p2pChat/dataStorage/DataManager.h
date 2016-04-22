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

+ (instancetype)shareManager;

@end

// 对message的操作
@interface DataManager (Message)

- (NSFetchedResultsController *)getMessageByUsername:(NSString *)username;
- (void)saveMessageWithUsername:(NSString *)username time:(NSNumber *)time body:(NSString *)body isOut:(BOOL)isOut;//isOut真为发出，假为收到
- (void)saveRecordWithUsername:(NSString *)username time:(NSNumber *)time path:(NSString *)path length:(NSString *)length isOut:(BOOL)isOut;
- (void)savePhotoWithUsername:(NSString *)username time:(NSNumber *)time path:(NSString *)path thumbnail:(NSString *)thumbnailPath isOut:(BOOL)isOut;
- (void)saveFileWithUsername:(NSString *)username time:(NSNumber *)time path:(NSString *)path fileName:(NSString *)name isOut:(BOOL)isOut;

@end

// 对last message的操作
@interface DataManager (LastMessage)

- (NSFetchedResultsController *)getRecent;
- (void)addRecentUsername:(NSString *)username time:(NSNumber *)time body:(NSString *)body isOut:(BOOL)isOut;
- (void)updateUsername:(NSString *)username;//已读
- (void)deleteRecentUsername:(NSString *)username;

@end

// 对group message的操作
@interface DataManager (GroupMessage)

- (NSFetchedResultsController *)getMessageByGroupname:(NSString *)groupname;
- (void)saveMessageWithGroupname:(NSString *)groupname username:(NSString *)username time:(NSNumber *)time body:(NSString *)body;
- (void)saveRecordWithGroupname:(NSString *)groupname username:(NSString *)username time:(NSNumber *)time path:(NSString *)path length:(NSString *)length;

@end
