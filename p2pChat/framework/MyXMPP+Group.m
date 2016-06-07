//
//  MyXMPP+Group.m
//  p2pChat
//
//  Created by xiaokun on 16/4/21.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MyXMPP+Group.h"
#import "DataManager.h"
#import "Tool.h"
#import "XMPPMessage+MyExtends.h"
#import "MyXMPP.h"
#import "AFNetworking/AFHTTPSessionManager.h"

static NSString *myRoomDomain = @"conference.xmpp.test";
static NSString *voiceType = @"[语音]";
static NSString *pictureType = @"[图片]";

@implementation MyXMPP (Group)

- (void)creatGroupName:(NSString *)groupname withpassword:(NSString *)roompwd andsubject:(NSString *)subject{//创建聊天室
    if (self.roomStorage==nil) {
        NSLog(@"nil");
        self.roomStorage = [[XMPPRoomCoreDataStorage alloc]init];
    }
    NSString* roomID = [NSString stringWithFormat:@"%@@%@",groupname,myRoomDomain];
    XMPPJID * roomJID = [XMPPJID jidWithString:roomID];
    self.chatroom = [[XMPPRoom alloc] initWithRoomStorage:self.roomStorage jid:roomJID dispatchQueue:dispatch_get_main_queue()];
    [self.chatroom changeRoomSubject:subject];
    [self.chatroom activate:self.stream];
    [self.chatroom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.chatroom joinRoomUsingNickname:self.stream.myJID.user history:nil password:roompwd];//创建聊天室必须将自己加入聊天室，否则不会创建成功！
}

- (void)inviteFriends:(NSString *)friendname withMessage:(NSString *)text{
    [self.chatroom inviteUser:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@xmpp.test",friendname ]]withMessage:text];
    [self.chatroom editRoomPrivileges:@[[XMPPRoom itemWithAffiliation:@"member" jid:[XMPPJID jidWithString:friendname]]]];
}

- (void)fetchWithParameters:(NSDictionary *)parameters withCompletionBlock:(fetchedBlock) block {
    AFHTTPSessionManager *httpManager = [AFHTTPSessionManager manager];
    httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    [httpManager GET:@"http://10.108.136.59:8080/FileServer/room" parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *resultArr = responseObject;
        block(resultArr);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"XMPPGroup http get fail: %@", error);
    }];
}

- (void)fetchAllRoomsWithCompletion:(fetchedBlock) block {
    [self fetchWithParameters:@{@"methed":@"allroom"} withCompletionBlock:block];
}

- (void)fetchMembersFromGroup:(NSString *)groupName withCompletion:(fetchedBlock) block {
    [self fetchWithParameters:@{@"methed":@"getmember", @"roomname":groupName} withCompletionBlock:block];
}

- (void)fetchMyRoomsWithCompletion:(fetchedBlock) block {
    NSString *myName = [[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
    [self fetchWithParameters:@{@"methed":@"getroom", @"membername":myName} withCompletionBlock:block];
}

- (void)sendMessageWithSubtype:(NSString *)subtype time:(double)time body:(NSString *)body more:(NSString *)more toGroup:(NSString *)groupname {
    NSXMLElement *bodyElement = [NSXMLElement elementWithName:@"body"];
    [bodyElement addAttributeWithName:@"subtype" stringValue:subtype];
    
    [bodyElement addAttributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%f", time]];
    if (more != nil) {
        [bodyElement addAttributeWithName:@"more" stringValue:more];
    }
    [bodyElement setStringValue:body];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"groupchat"];
    
    NSString *to = [NSString stringWithFormat:@"%@@%@", groupname, myRoomDomain];
    [message addAttributeWithName:@"to" stringValue:to];
    
    [message addChild:bodyElement];
    [self.stream sendElement:message];
    NSLog(@"message : %@", message);
}


- (void)sendMessage:(NSString *)text ToGroup:(NSString *)groupname{

    NSDate *date = [NSDate date];
    NSTimeInterval t = [date timeIntervalSince1970];
    int time = (int)t;
    
    [self sendMessageWithSubtype:@"text" time:time body:text more:nil toGroup:groupname];
    
    [self.dataManager saveMessageWithGroupname:groupname username:self.myjid.user time:[NSNumber numberWithDouble:time] body:text];
    [self.dataManager addRecentUsername:groupname time:[NSNumber numberWithDouble:time] body:text isOut:YES isP2P:NO];
}

- (void)sendAudio:(NSString *)path ToGroup:(NSString *)groupname withlength:(NSString *)length{
    NSFileManager *filemnanager=[NSFileManager defaultManager];
    NSData *p = [filemnanager contentsAtPath:path];
    NSLog(@"MyXmpp: audio file length :%lu", (unsigned long)p.length);
    NSString *audiomsg = [p base64EncodedStringWithOptions:0];
    
    NSDate *date = [Tool transferDate:[NSDate date]];
    double time = [[NSDate date] timeIntervalSince1970];
    double ltime = [date timeIntervalSince1970];
    
    [self sendMessageWithSubtype:@"audio" time:time body:audiomsg more:length toGroup:groupname];
    
    [self.dataManager saveRecordWithGroupname:groupname username:self.myjid.user time:[NSNumber numberWithDouble:time] path:path length:length];
    [self.dataManager addRecentUsername:groupname time:[NSNumber numberWithInt:ltime] body:voiceType isOut:YES isP2P:NO];
}

- (void)destroyChatRoom{
    [self.chatroom destroyRoom];
}

- (void)leaveChatRoom{
    [self.chatroom leaveRoom];
}

- (void)setGroupSubject:(NSString *)subject{
    [self.chatroom changeRoomSubject:subject];

}

//只有owner拥有删除权限
- (void)deleteMember:(NSString *)member FromGroup:(NSString *)group{
    
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    NSXMLElement *deleteMember = [NSXMLElement elementWithName:@"deleteMember"];
//    NSXMLElement *reason = [NSXMLElement elementWithName:@"reason"];
    
    [iq addAttributeWithName:@"id" stringValue:@"del"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@",self.myjid]];
    [iq addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@",group,myRoomDomain]];
    
    [deleteMember addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:search"];
    
    NSXMLElement *reason = [NSXMLElement elementWithName:@"reason" stringValue:@"delete"];
    
    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    [item addAttributeWithName:@"role" stringValue:@"participant"];
    [item addAttributeWithName:@"nickname" stringValue:[NSString stringWithFormat:@"%@",member]];
    [item addChild:reason];
    
    
    [deleteMember addChild:item];

    [iq addChild:deleteMember];
    
    [self.stream sendElement:iq];
    
    [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSLog(@"did use delete method!");
}

-(void)getMembersFromGroup{
//    self.roomOccupant = [self.roomStorage occupantForJID:self.myjid stream:self.stream inContext:<#(NSManagedObjectContext *)#> ];
//    NSLog(@"%@",self.roomOccupant.roomJIDStr);
//    XMPPRoomOccupantMemoryStorageObject
}

- (void)getJoinedRooms{
    
}

#pragma mark - room delegate
- (void)xmppRoomDidCreate:(XMPPRoom *)sender {
    NSLog(@"did creat chat room");
    //    [self sendDefaultRoomConfig];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    NSLog(@"did join chat room");
    [sender fetchConfigurationForm];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm {
    NSLog(@"didFetchConfigurationForm");
    NSXMLElement *newConfig = [configForm copy];
    NSLog(@"BEFORE Config for the room %@",newConfig);
    NSArray *fields = [newConfig elementsForName:@"field"];
    for (NSXMLElement *field in fields) {
        NSString *var = [field attributeStringValueForName:@"var"];
        // 使房间变成永久的
        if ([var isEqualToString:@"muc#roomconfig_persistentroom"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
    }
    NSLog(@"AFTER Config for the room %@",newConfig);
    [sender configureRoomUsingOptions:newConfig];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:MyXmppRoomDidConfigurationNotification object:nil];
    
    NSLog(@"didFetchConfigurationForm");
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items{
    NSLog(@"did fetch members list");
//    NSLog(@"memberlist:%@",items);
    int i= 0;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[items count]];
    for (DDXMLElement *obj  in items) {
        NSString *membername = [[obj attributeForName:@"jid"] stringValue];//获取属性为jid的值
        i++;
        [array addObject:membername];
        NSLog(@"第%i个 member 成员：%@",i,membername);
    }
    self.fetchGroupMemberBlock(array);
//    NSMutableArray *array = self.roomMembers;
//    NSLog(@"%@",array);
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items{
    NSLog(@"did fetch ban list");
    NSLog(@"banlist:%@",items);
    int i= 0;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[items count]];
    for (DDXMLElement *obj  in items) {
        NSString *banmembername = [[obj attributeForName:@"jid"] stringValue];//获取属性为jid的值
        i++;
        [array addObject:banmembername];
        NSLog(@"第%i个 ban 成员：%@",i,banmembername);
    }
}

- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID{
    NSString *user = occupantJID.resource;
    NSString *myName = [[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
    if (![user isEqualToString:myName]) {
        if ([message.type isEqualToString:@"groupchat"]) {
            NSDate *date = [NSDate date];
            NSNumber *timeNumber = [NSNumber numberWithDouble:[date timeIntervalSince1970]];//聊天记录中消息的时间
            
            NSDate *d = [Tool transferDate:date];
            NSNumber *time= [NSNumber numberWithDouble:[d timeIntervalSince1970]];//最后一条消息的时间
            
            NSLog(@"recieve time:%@",date);
            NSString *text = [message body];
            NSString *subtype = [message getSubtype];
            NSLog(@"group subtype:%@",subtype);
            
            NSString *messageBody = [[message elementForName:@"body"] stringValue];
            
            char firstLetter = [subtype characterAtIndex:0];
            switch (firstLetter) {
                case 't':{//text
                    [[DataManager shareManager]saveMessageWithGroupname:occupantJID.user username:user time:timeNumber body:text];
                    [[DataManager shareManager]addRecentUsername:sender.roomJID.user time:time body:message.body isOut:NO isP2P:NO];
                    NSLog(@"群组『%@』有来自%@的新消息：%@",sender.roomJID.user,occupantJID.resource,[message body]);
                    break;
                }
                case 'a':{//audio
                    NSString *during = [message getMore];
                    NSData *data = [[NSData alloc] initWithBase64EncodedString:messageBody options:0];
                    NSString *path = [Tool getFileName:@"receive" extension:@"wav"];
                    [data writeToFile:path atomically:YES];
                    [self.dataManager saveRecordWithGroupname:occupantJID.user username:occupantJID.resource time:timeNumber path:path length:during];
                    [self.dataManager addRecentUsername:occupantJID.user time:time body:voiceType isOut:NO isP2P:NO];
                    NSLog(@"群组『%@』有来自%@的新消息：%@",sender.roomJID.user,occupantJID.resource,@"语音消息");
                    break;
                }
                case 'p':{//photo
                    
                    break;
                }
                default:
                    break;
            }
            
        }else{
            NSLog(@"群组『%@』有来自%@的新消息：%@",sender.roomJID.user,occupantJID.resource,[message body]);
        }
   }

}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    //sender.roomJID.user与occupantJID.user都表示room的名称
//    NSString *str = [[NSString alloc]init];
//    if ([presence.type isEqualToString:@"available"]) {
//        str = @"online";
//    }
    NSLog(@"%@进入了%@房间",occupantJID.resource,sender.roomJID);

}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
//    NSString *str = [[NSString alloc]init];
//    if ([presence.type isEqualToString:@"unavailable"]) {
//        str = @"offline";
//    }
    NSLog(@"%@离开了%@房间",occupantJID.resource,sender.roomJID);
}

#pragma mark recieve invitation delegate

-(void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *)roomJID didReceiveInvitation:(XMPPMessage *)message
{
    NSLog(@"did recieve invite message :%@", message);
    NSLog(@"room jid:%@",roomJID);
    
    if (self.roomStorage==nil) {
        self.roomStorage = [[XMPPRoomCoreDataStorage alloc]init];
    }
    self.chatroom = [[XMPPRoom alloc] initWithRoomStorage:self.roomStorage jid:roomJID];
    [self.chatroom activate:self.stream];
    [self.chatroom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSString *joinname = [[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
    [self.chatroom joinRoomUsingNickname:joinname history:nil];
    
//    NSLog(@"XMPPMUC:%@",sender->rooms);

}




@end
