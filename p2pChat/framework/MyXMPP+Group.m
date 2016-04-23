//
//  MyXMPP+Group.m
//  p2pChat
//
//  Created by xiaokun on 16/4/21.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MyXMPP+Group.h"
#import "DataManager.h"

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

- (void)sendMessage:(NSString *)text ToGroup:(NSString *)groupname{
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:text];
    [body addAttributeWithName:@"subtype" stringValue:@"text"];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"groupchat"];
    
    
    NSString *to = [NSString stringWithFormat:@"%@@%@", groupname, myRoomDomain];
    [message addAttributeWithName:@"to" stringValue:to];
    
    [message addChild:body];
    [self.stream sendElement:message];
    NSLog(@"message : %@", message);
    
    double time = [[NSDate date]timeIntervalSince1970];
    
    [self.dataManager saveMessageWithGroupname:groupname username:self.myjid.user time:[NSNumber numberWithDouble:time] body:text];
    [self.dataManager addRecentUsername:groupname time:[NSNumber numberWithDouble:time] body:text isOut:YES];
}

- (void)sendAudio:(NSString *)path ToGroup:(NSString *)groupname withlength:(NSString *)length{
    NSFileManager *filemnanager=[NSFileManager defaultManager];
    NSData *p = [filemnanager contentsAtPath:path];
    
    NSString *audiomsg = [p base64EncodedStringWithOptions:0];
    NSString *audiomsgwithlength = [NSString stringWithFormat:@"%@,%@",length,audiomsg];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:audiomsgwithlength];
    [body addAttributeWithName:@"subtype" stringValue:@"audio"];
    
    NSXMLElement *audiomessage = [NSXMLElement elementWithName:@"message"];
    [audiomessage addAttributeWithName:@"type" stringValue:@"groupchat"];
    
    NSString *to = [NSString stringWithFormat:@"%@@%@", groupname, myRoomDomain];
    [audiomessage addAttributeWithName:@"to" stringValue:to];
    
    [audiomessage addChild:body];
    [self.stream sendElement:audiomessage];
    
    double time = [[NSDate alloc]timeIntervalSince1970];
    
    [self.dataManager saveRecordWithGroupname:groupname username:self.myjid.user time:[NSNumber numberWithDouble:time] path:path length:length];
    
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
    for (NSXMLElement *field in fields)
    {
        NSString *var = [field attributeStringValueForName:@"var"];
        // 使房间变成永久的
        if ([var isEqualToString:@"muc#roomconfig_persistentroom"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
    }
    NSLog(@"AFTER Config for the room %@",newConfig);
    [sender configureRoomUsingOptions:newConfig];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MyXmppRoomDidConfigurationNotification object:nil];
    //    [self inviteFriends:@"ht" withMessage:@"hellossss"];
//    [self inviteFriends:@"cxh" withMessage:@"hello！"];
//    [self sendMessage:@"hello" ToGroup:@"222"];
    //    [self sendGroupMessage:@"哈哈哈哈哈哈哈"];
    //    [sender sendMessageWithBody:@"hehehehehehhe"];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items{
    NSLog(@"did fetch members list");
    NSLog(@"%@",items);
}

- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID{
    NSLog(@"群组『%@』有新消息：%@",sender.roomJID.user,[message body]);
    
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID
{
    NSLog(@"%@离开了房间",occupantJID.user);
}


@end
