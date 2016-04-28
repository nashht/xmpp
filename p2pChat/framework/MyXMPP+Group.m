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
#import "XMPPMUC.h"

#define Voice @"[语音]"

static NSString *myRoomDomain = @"conference.xmpp.test";

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
}

- (void)fetchMembersFromGroup{
    [self.chatroom fetchMembersList];
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
    double time = [date timeIntervalSince1970];
    
    [self sendMessageWithSubtype:@"audio" time:time body:audiomsg more:length toGroup:groupname];
    
    [self.dataManager saveRecordWithGroupname:groupname username:self.myjid.user time:[NSNumber numberWithDouble:time] path:path length:length];
    [self.dataManager addRecentUsername:groupname time:[NSNumber numberWithInt:time] body:Voice isOut:YES isP2P:NO];
}

- (void)destroyChatRoom{
    [self.chatroom destroyRoom];
}

#pragma mark - room delegate
- (void)xmppRoomDidCreate:(XMPPRoom *)sender {
    NSLog(@"did creat chat room");
    //    [self sendDefaultRoomConfig];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    NSLog(@"did join chat room");
    [sender fetchConfigurationForm];
    
    //    [sender inviteUser:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@xmpp.test",@"cxh" ]]withMessage:@"hello!"];
    //    [sender inviteUser:[XMPPJID jidWithString:@"zxk@xmpp.test"] withMessage:@"hello!"];
    //
    //   [sender editRoomPrivileges:@[[XMPPRoom itemWithAffiliation:@"member" jid:self.myjid]]];
    //    [sender fetchMembersList];
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
    
//    [self inviteFriends:@"ht" withMessage:@"hellossss"];
//    [self inviteFriends:@"ht" withMessage:@"hello！"];
//    [self sendMessage:@"hello" ToGroup:@"222"];
//    [self sendGroupMessage:@"哈哈哈哈哈哈哈"];
//    [sender sendMessageWithBody:@"hehehehehehhe"];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items{
    NSLog(@"did fetch members list");
    NSLog(@"%@",items);
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
            NSString *subtype = [message getSubtype];//[NSNumber numberWithDouble:[[NSDate date]timeIntervalSince1970]]
            NSLog(@"group subtype:%@",subtype);
            char firstLetter = [subtype characterAtIndex:0];
            switch (firstLetter) {
                case 't':{//text
                    [[DataManager shareManager]saveMessageWithGroupname:occupantJID.user username:user time:timeNumber body:text];
                    [[DataManager shareManager]addRecentUsername:sender.roomJID.user time:time body:message.body isOut:NO isP2P:NO];
                    break;
                }
                case 'a':{//audio
                    
                    break;
                }
                case 'p':{//photo
                    
                    break;
                }
                default:
                    break;
            }
            
        }else{
            NSLog(@"群组『%@』有新消息：%@",sender.roomJID.user,[message body]);
        }
   }
//    NSDate *date = [Tool transferDate:[NSDate date]];
//    NSNumber *timeNum = [NSNumber numberWithDouble:[date timeIntervalSince1970]];
//    NSString *text = [message body];[NSNumber numberWithDouble:[[NSDate date]timeIntervalSince1970]]
    
    
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID
{
    NSLog(@"%@离开了房间",occupantJID.user);
}

#pragma mark recieve invitation delegate

-(void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *)roomJID didReceiveInvitation:(XMPPMessage *)message
{
    NSLog(@"did recieve invite message :%@", message);
    NSLog(@"room jid:%@",roomJID);
    
    self.roomStorage = [[XMPPRoomCoreDataStorage alloc]init];
    self.chatroom = [[XMPPRoom alloc] initWithRoomStorage:self.roomStorage jid:roomJID];
    [self.chatroom activate:self.stream];
    [self.chatroom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSString *joinname = [[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
    [self.chatroom joinRoomUsingNickname:joinname history:nil];
}


@end
