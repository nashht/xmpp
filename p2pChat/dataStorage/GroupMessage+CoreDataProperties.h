//
//  GroupMessage+CoreDataProperties.h
//  p2pChat
//
//  Created by admin on 16/4/21.
//  Copyright © 2016年 xiaokun. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GroupMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupMessage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *groupname;
@property (nullable, nonatomic, retain) NSString *username;
@property (nullable, nonatomic, retain) NSNumber *type;
@property (nullable, nonatomic, retain) NSString *body;
@property (nullable, nonatomic, retain) NSString *more;
@property (nullable, nonatomic, retain) NSNumber *time;

@end

NS_ASSUME_NONNULL_END
