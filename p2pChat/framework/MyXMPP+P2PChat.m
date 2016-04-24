//
//  MyXMPP+P2PChat.m
//  p2pChat
//
//  Created by xiaokun on 16/4/21.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyXMPP+P2PChat.h"
#import "XMPPStream.h"
#import "XMPPMessage.h"
#import "XMPPMessage+MyExtends.h"
#import "NSXMLElement+XMPP.h"
#import "DataManager.h"
#import "Tool.h"
#import "VoiceConverter.h"
#import "Tool.h"

#define Voice @"[语音]"

@implementation MyXMPP (P2PChat)

- (void)sendMessageWithSubtype:(NSString *)subtype time:(double)time body:(NSString *)body more:(NSString *)more toUser:(NSString *)user {
    NSXMLElement *bodyElement = [NSXMLElement elementWithName:@"body"];
    [bodyElement addAttributeWithName:@"subtype" stringValue:subtype];

    [bodyElement addAttributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%f", time]];
    if (more != nil) {
        [bodyElement addAttributeWithName:@"more" stringValue:more];
    }
    [bodyElement setStringValue:body];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    
    NSString *to = [NSString stringWithFormat:@"%@@%@", user, myDomain];
    [message addAttributeWithName:@"to" stringValue:to];
    
    [message addChild:bodyElement];
    [self.stream sendElement:message];
    NSLog(@"message : %@", message);
}

- (void)sendMessage:(NSString *)text ToUser:(NSString *)user {
    NSDate *date = [Tool transferDate:[NSDate date]];
    NSTimeInterval t = [date timeIntervalSince1970];
    int time = (int)t;
    
    [self sendMessageWithSubtype:@"text" time:time body:text more:nil toUser:user];
    
    [self.dataManager saveMessageWithUsername:user time:[NSNumber numberWithInt:time] body:text isOut:YES];
    [self.dataManager addRecentUsername:user time:[NSNumber numberWithInt:time] body:text isOut:YES];
}

- (void)sendAudio:(NSString *)path ToUser:(NSString *)user length:(NSString *)length{
    NSFileManager *filemnanager=[NSFileManager defaultManager];
    NSData *p = [filemnanager contentsAtPath:path];
    NSString *audiomsg = [p base64EncodedStringWithOptions:0];
    
    NSDate *date = [Tool transferDate:[NSDate date]];
    double time = [date timeIntervalSince1970];
//    int time = (int)t;
//    double time = [[NSDate alloc]timeIntervalSince1970];
    
    [self sendMessageWithSubtype:@"audio" time:time body:audiomsg more:length toUser:user];
    
    [self.dataManager saveRecordWithUsername:user time:[NSNumber numberWithInt:time] path:path length:length isOut:YES];
    [self.dataManager addRecentUsername:user time:[NSNumber numberWithInt:time] body:Voice isOut:YES];
}

#pragma mark - receivemessage delegate
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    if ([message isChatMessageWithBody]) {
        NSString *subtype = [message getSubtype];
        NSString *timeStr = [message getTime];
        NSNumber *timenum = [NSNumber numberWithDouble:[timeStr doubleValue]];
        NSDate *d = [NSDate dateWithTimeIntervalSince1970:[timenum doubleValue]];
        NSDate *date = [Tool transferDate:d];
        NSNumber *timeNumber = [NSNumber numberWithDouble:[date timeIntervalSinceReferenceDate]];
        NSLog(@"recieve time:%@",date);
        
        NSString *messageBody = [[message elementForName:@"body"] stringValue];
        XMPPJID *fromJid = message.from;
        NSString *bareJidStr = fromJid.user;
        
        UILocalNotification *localNotification = [[UILocalNotification alloc]init];
        localNotification.fireDate = [NSDate date];
        
        char firstLetter = [subtype characterAtIndex:0];
        switch(firstLetter) {
            case 't':{//text
                [self.dataManager saveMessageWithUsername:bareJidStr time:timeNumber body:messageBody isOut:NO];
                [self.dataManager addRecentUsername:bareJidStr time:timeNumber body:messageBody isOut:NO];
                localNotification.alertBody = [NSString stringWithFormat:@"%@:%@", bareJidStr, messageBody];
                break;
            }
            case 'a':{//audio
                NSString *during = [message getMore];
                NSData *data = [[NSData alloc] initWithBase64EncodedString:messageBody options:0];
                
                NSString *tmpPath = [Tool getFileName:@"tmp" extension:@"amr"];
                NSString *path = [Tool getFileName:@"receive" extension:@"wav"];
                [data writeToFile:tmpPath atomically:YES];
                [VoiceConverter amrToWav:tmpPath wavSavePath:path];
                
                [self.dataManager saveRecordWithUsername:bareJidStr time:timeNumber path:path length:during isOut:NO];
                [self.dataManager addRecentUsername:bareJidStr time:timeNumber body:Voice isOut:NO];
                localNotification.alertBody = [NSString stringWithFormat:@"%@:[语音]", bareJidStr];
                break;
            }
            case 'p':{
                
                break;
            }
                
            default:
                break;
        }
        
        NSLog(@"%@", message);
        
        [[UIApplication sharedApplication]presentLocalNotificationNow:localNotification];
    } else {
        NSLog(@"%@", message);
    }
}

#pragma mark - sendmessage delegate
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error {
    NSLog(@"send error : %@", error);
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    NSLog(@"did send");
}

@end
