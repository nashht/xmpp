//
//  DataManager.m
//  ZXKChat_2
//
//  Created by xiaokun on 15/12/16.
//  Copyright © 2015年 xiaokun. All rights reserved.
//

#import "DataManager.h"
#import "AppDelegate.h"
#import "Message.h"
#import "LastMessage.h"
#import "GroupMessage.h"

@interface DataManager ()

@end

@implementation DataManager

+ (instancetype)shareManager {
    DataManager *manager = nil;
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    manager = delegate.dataManager;
    manager.context = delegate.managedObjectContext;

    return manager;
}

- (id)init {
    if (self = [super init]) {
        _totalUnreadNumber = 0;
        [self addObserver:self forKeyPath:@"totalUnreadNumber" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (NSFetchedResultsController *)fetchWithEntityName:(NSString *)name predicate:(NSPredicate *)predicate sortKey:(NSString *)key ascending:(BOOL)ascending error:(NSError **)error {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:name];
    request.predicate = predicate;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending];
    request.sortDescriptors = @[sort];
    NSFetchedResultsController *resultController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:_context sectionNameKeyPath:nil cacheName:nil];
    [resultController performFetch:error];

    return resultController;
}

- (void)saveMessageWithUsername:(NSString *)username time:(NSNumber *)time type:(NSNumber *)type body:(NSString *)body more:(NSString *)more error:(NSError **)err isOut:(BOOL)isOut {
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:_context];
    message.username = username;
    message.time = time;
    message.type = type;
    message.body = body;
    message.more = more;
    message.isOut = [NSNumber numberWithBool:isOut];
    [_context save:err];
}

- (void)deleteDataByEntityName:(NSString *)name {
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSError *err = nil;
    NSEntityDescription *entity = [NSEntityDescription entityForName:name inManagedObjectContext:_context];
    request.entity = entity;
    NSArray *array = [_context executeFetchRequest:request error:&err];
    if (err == nil && array.count > 0) {
        for (NSManagedObject *obj in array) {
            [_context deleteObject:obj];
        }
    }
    if (![_context save:&err]) {
        NSLog(@"DataManager clear failed: %@", err);
    }
}

- (void)clearAll {
    [self deleteDataByEntityName:@"Message"];
    [self deleteDataByEntityName:@"LastMessage"];
    [self deleteDataByEntityName:@"GroupMessage"];
}

#pragma mark - message
- (NSFetchedResultsController *)getMessageByUsername:(NSString *)username {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username = %@", username];
    NSError *err = nil;
    NSFetchedResultsController *resultController = [self fetchWithEntityName:@"Message" predicate:predicate sortKey:@"time" ascending:YES error:&err];
    if (err) {
        NSLog(@"DataManager fetch message failed: %@", err);
    }
    
    return resultController;
}

- (void)clearMessageByUsername:(NSString *)username {
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:_context];
    request.entity = entityDescription;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username = %@", username];
    request.predicate = predicate;
    NSError *err = nil;
    NSArray *messageArray = [_context executeFetchRequest:request error:&err];
    if (err == nil && messageArray.count > 0) {
        for (NSManagedObject *messageObj in messageArray) {
            [_context deleteObject:messageObj];
        }
    }
    if (![_context save:&err]) {
        NSLog(@"DataManager clear history message failed: %@", err);
    }
}

- (void)saveMessageWithUsername:(NSString *)username time:(NSNumber *)time body:(NSString *)body isOut:(BOOL)isOut{
    NSError *err = nil;
    [self saveMessageWithUsername:username time:time type:@0 body:body more:nil error:&err isOut:isOut];
    if (err) {
        NSLog(@"DataManager save message failed: %@", err);
    }
}

- (void)saveRecordWithUsername:(NSString *)username time:(NSNumber *)time path:(NSString *)path length:(NSString *)length isOut:(BOOL)isOut {
    NSError *err = nil;
    [self saveMessageWithUsername:username time:time type:@1 body:path more:length error:&err isOut:isOut];
    if (err) {
        NSLog(@"DataManager save message failed: %@", err);
    }
}

- (void)savePhotoWithUsername:(NSString *)username time:(NSNumber *)time filename:(NSString *)filename thumbnail:(NSString *)thumbnailName isOut:(BOOL)isOut{
    NSError *err = nil;
    [self saveMessageWithUsername:username time:time type:@2 body:filename more:thumbnailName error:&err isOut:isOut];
    if (err) {
        NSLog(@"DataManager save message failed: %@", err);
    }
}

- (void)saveFileWithUsername:(NSString *)username time:(NSNumber *)time filename:(NSString *)filename fileSize:(NSString *)size isOut:(BOOL)isOut {
    NSError *err = nil;
    [self saveMessageWithUsername:username time:time type:@3 body:filename more:size error:&err isOut:isOut];
    if (err) {
        NSLog(@"DataManager save message failed: %@", err);
    }
}

#pragma mark - last message
- (NSFetchedResultsController *)getRecent {
    NSError *err = nil;
    NSFetchedResultsController *resultController = [self fetchWithEntityName:@"LastMessage" predicate:nil sortKey:@"time" ascending:NO error:&err];
    if (err) {
        NSLog(@"DataManager fetch recent failed: %@", err);
    }
    return resultController;
}

- (void)addRecentUsername:(NSString *)username time:(NSNumber *)time body:(NSString *)body isOut:(BOOL)isOut isP2P:(BOOL)isP2P {
    LastMessage *lastMessage = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username = %@", username];
    NSError *err = nil;
    NSFetchedResultsController *resultController = [self fetchWithEntityName:@"LastMessage" predicate:predicate sortKey:@"time" ascending:YES error:&err];
    if (err) {
        NSLog(@"DataManager fetch recent failed: %@", err);
    }
    if ([resultController fetchedObjects].count == 0) {
        lastMessage = [NSEntityDescription insertNewObjectForEntityForName:@"LastMessage" inManagedObjectContext:_context];
        lastMessage.username = username;
    } else {
        lastMessage = [resultController fetchedObjects].firstObject;
    }
    lastMessage.time = time;
    if (!isOut) {
        lastMessage.unread = @(lastMessage.unread.intValue + 1);
        self.totalUnreadNumber++;
    }
    lastMessage.body = body;
    lastMessage.isOut = [NSNumber numberWithBool:isOut];
    lastMessage.isP2P = [NSNumber numberWithBool:isP2P];
    NSError *err2 = nil;
    [_context save:&err2];
    if (err2) {
        NSLog(@"DataManager save recent failed: %@", err2);
    }
}

- (void)updateUsername:(NSString *)username {//已读
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username = %@", username];
    NSError *err = nil;
    NSFetchedResultsController *resultController = [self fetchWithEntityName:@"LastMessage" predicate:predicate sortKey:@"time" ascending:YES error:&err];
    if (err) {
        NSLog(@"DataManager fetch recent failed: %@", err);
    }
    LastMessage *lastMessage = [resultController fetchedObjects].firstObject;
    self.totalUnreadNumber -= lastMessage.unread.intValue;
    lastMessage.unread = [NSNumber numberWithUnsignedShort:0];
    NSError *err2 = nil;
    [_context save:&err2];
    if (err2) {
        NSLog(@"DataManager save flag failed: %@", err2);
    }
}

- (void)deleteRecentUsername:(NSString *)username isP2P:(BOOL) isP2P {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username = %@", username];
    NSError *err = nil;
    NSFetchedResultsController *resultController = [self fetchWithEntityName:@"LastMessage" predicate:predicate sortKey:@"time" ascending:YES error:&err];
    if (err) {
        NSLog(@"DataManager fetch recent failed: %@", err);
    }
    NSManagedObject *obj = [resultController fetchedObjects].firstObject;
    [_context deleteObject:obj];
    NSError *err2 = nil;
    [_context save:&err2];
    if (err2) {
        NSLog(@"DataManager delete recent failed: %@", err2);
    }
    if (isP2P) {
        [self clearMessageByUsername:username];
    } else {
        [self clearMessageByGroupname:username];
    }    
}

#pragma mark - group message
- (void)saveGroupMessageWithGroupname:(NSString *)groupname username:(NSString *)username type:(NSNumber *)type time:(NSNumber *)time body:(NSString *)body more:(NSString *)more WithError:(NSError **)error {
    GroupMessage *groupmessage = [NSEntityDescription insertNewObjectForEntityForName:@"GroupMessage" inManagedObjectContext:_context];
    groupmessage.groupname = groupname;
    groupmessage.username = username;
    groupmessage.type = type;
    groupmessage.time = time;
    groupmessage.body = body;
    groupmessage.more = more;
    [_context save:error];
}

- (void)clearMessageByGroupname:(NSString *)groupname {
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"GroupMessage" inManagedObjectContext:_context];
    request.entity = entityDescription;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupname = %@", groupname];
    request.predicate = predicate;
    NSError *err = nil;
    NSArray *messageArray = [_context executeFetchRequest:request error:&err];
    if (err == nil && messageArray.count > 0) {
        for (NSManagedObject *messageObj in messageArray) {
            [_context deleteObject:messageObj];
        }
    }
    if (![_context save:&err]) {
        NSLog(@"DataManager clear group history message failed: %@", err);
    }
}

- (NSFetchedResultsController *)getMessageByGroupname:(NSString *)groupname {
    NSPredicate *predicatae = [NSPredicate predicateWithFormat:@"groupname = %@", groupname];
    NSError *err = nil;
    NSFetchedResultsController *resultsController = [self fetchWithEntityName:@"GroupMessage" predicate:predicatae sortKey:@"time" ascending:YES error:&err];
    if (err != nil) {
        NSLog(@"DataManager fetch group message failed: %@", err);
    }
    return resultsController;
}

- (void)saveMessageWithGroupname:(NSString *)groupname username:(NSString *)username time:(NSNumber *)time body:(NSString *)body {
    NSError *error = nil;
    [self saveGroupMessageWithGroupname:groupname username:username type:@0 time:time body:body more:nil WithError:&error];
    if (error != nil) {
        NSLog(@"DataManager save group message failed: %@", error);
    }
}

- (void)saveRecordWithGroupname:(NSString *)groupname username:(NSString *)username time:(NSNumber *)time path:(NSString *)path length:(NSString *)length{
    NSError *err1 = nil;
    [self saveGroupMessageWithGroupname:groupname username:username type:@1 time:time body:path more:length WithError:&err1];
    if (err1 != nil) {
        NSLog(@"DataManager save group record failed: %@", err1);
    }

}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"totalUnreadNumber"]) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = _totalUnreadNumber;
    }
}
@end
