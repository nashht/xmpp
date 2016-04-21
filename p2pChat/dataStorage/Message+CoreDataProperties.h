//
//  Message+CoreDataProperties.h
//  p2pChat
//
//  Created by admin on 16/4/21.
//  Copyright © 2016年 xiaokun. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@interface Message (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *body;
@property (nullable, nonatomic, retain) NSNumber *isOut;
@property (nullable, nonatomic, retain) NSString *more;
@property (nullable, nonatomic, retain) NSNumber *time;
@property (nullable, nonatomic, retain) NSNumber *type;
@property (nullable, nonatomic, retain) NSString *username;

@end

NS_ASSUME_NONNULL_END
