//
//  MyXMPP+Roster.m
//  p2pChat
//
//  Created by xiaokun on 16/4/21.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MyXMPP+Roster.h"

@implementation MyXMPP (Roster)

- (void)updateFriendsList {
    //获取 roster 列表，获取好友列表
    if ([self.roster autoFetchRoster]){
        [self.roster fetchRoster];//获取好友列表，之后自动调用xmppRosterDidEndPopulating和xmppRosterDidPopulate
    }
}

- (NSArray<XMPPGroupCoreDataStorageObject *> *)getFriendsGroup {
    NSManagedObjectContext *context = [[XMPPRosterCoreDataStorage sharedInstance] mainThreadManagedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPGroupCoreDataStorageObject"];
    //排序
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];//jidStr
    request.sortDescriptors = @[sort];
    
    NSError *err = nil;
    NSArray<XMPPGroupCoreDataStorageObject *> *friendGroups = [context executeFetchRequest:request error:&err];
    if (err != nil) {
        NSLog(@"myxmpp fetch friend failed: %@", err);
    }
    
    //XMPPUserCoreDataStorageObject  *obj类型的
    //名称为 obj.displayName
    return friendGroups;
}

@end
