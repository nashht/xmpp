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

// 对message的操作
- (NSFetchedResultsController *)getMessageByUsername:(NSString *)username;
- (void)saveMessageWithUsername:(NSString *)username time:(NSDate *)time body:(NSString *)body isOut:(BOOL)isOut;//isOut真为发出，假为收到
- (void)saveRecordWithUsername:(NSString *)username time:(NSDate *)time path:(NSString *)path length:(NSString *)length isOut:(BOOL)isOut;
- (void)savePhotoWithUsername:(NSString *)username time:(NSDate *)time path:(NSString *)path thumbnail:(NSString *)thumbnailPath isOut:(BOOL)isOut;
- (void)saveFileWithUsername:(NSString *)username time:(NSDate *)time path:(NSString *)path fileName:(NSString *)name isOut:(BOOL)isOut;

// 对last message的操作
- (NSFetchedResultsController *)getRecent;
- (void)addRecentUsername:(NSString *)username time:(NSDate *)time body:(NSString *)body isOut:(BOOL)isOut;
- (void)updateUsername:(NSString *)username;//已读
- (void)deleteRecentUsername:(NSString *)username;

@end
