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
#import "PhotoLibraryCenter.h"

static NSString *voiceType = @"[语音]";
static NSString *pictureType = @"[图片]";

@interface MyXMPP () 

@end

@implementation MyXMPP (P2PChat)

- (void)sendMessageWithSubtype:(NSString *)subtype time:(int)time body:(NSString *)body more:(NSString *)more toUser:(NSString *)user {
    NSXMLElement *bodyElement = [NSXMLElement elementWithName:@"body"];
    [bodyElement addAttributeWithName:@"subtype" stringValue:subtype];

    [bodyElement addAttributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%d", time]];
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
//    NSLog(@"message : %@", message);
}

- (void)sendMessage:(NSString *)text ToUser:(NSString *)user {
    NSDate *date = [Tool transferDate:[NSDate date]];
    NSTimeInterval t = [date timeIntervalSince1970];
    int time = (int)t;
    
    [self sendMessageWithSubtype:@"text" time:time body:text more:nil toUser:user];
    
    [self.dataManager saveMessageWithUsername:user time:[NSNumber numberWithInt:time] body:text isOut:YES];
    [self.dataManager addRecentUsername:user time:[NSNumber numberWithInt:time] body:text isOut:YES isP2P:YES];
}

- (void)sendAudio:(NSString *)path ToUser:(NSString *)user length:(NSString *)length{
    NSFileManager *filemnanager=[NSFileManager defaultManager];
    NSData *p = [filemnanager contentsAtPath:path];
    NSLog(@"MyXmpp: audio file length :%lu", (unsigned long)p.length);
    NSString *audiomsg = [p base64EncodedStringWithOptions:0];
    
    NSDate *date = [Tool transferDate:[NSDate date]];
    int time = (int)[date timeIntervalSince1970];
    
    [self sendMessageWithSubtype:@"audio" time:time body:audiomsg more:length toUser:user];
    
    [self.dataManager saveRecordWithUsername:user time:[NSNumber numberWithInt:time] path:path length:length isOut:YES];
    [self.dataManager addRecentUsername:user time:[NSNumber numberWithInt:time] body:voiceType isOut:YES isP2P:YES];
}

- (void)sendPictureIdentifier:(NSString *)identifier data:(NSData *)imageData thumbnailPath:(NSString *)path ToUser:(NSString *)user {
    NSString *picString = [imageData base64EncodedStringWithOptions:0];
    NSDate *date = [Tool transferDate:[NSDate date]];
    int time = (int)[date timeIntervalSince1970];
    [self sendMessageWithSubtype:@"picture" time:time body:picString more:nil toUser:user];
    [self.dataManager savePhotoWithUsername:user time:[NSNumber numberWithInt:time] path:identifier thumbnail:path isOut:YES];
    [self.dataManager addRecentUsername:user time:[NSNumber numberWithInt:time] body:pictureType isOut:YES isP2P:YES];
}

#pragma mark - receivemessage delegate
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    if ([message isChatMessageWithBody]) {
        NSString *subtype = [message getSubtype];
        NSString *timeStr = [message getTime];
        NSNumber *timeNumber = [NSNumber numberWithInt:[timeStr intValue]];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeNumber doubleValue]];
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
                [self.dataManager addRecentUsername:bareJidStr time:timeNumber body:messageBody isOut:NO isP2P:YES];
                localNotification.alertBody = [NSString stringWithFormat:@"%@:%@", bareJidStr, messageBody];
                break;
            }
            case 'a':{//audio
                NSString *during = [message getMore];
                NSData *data = [[NSData alloc] initWithBase64EncodedString:messageBody options:0];
                
                NSString *path = [Tool getFileName:@"receive" extension:@"wav"];
                [data writeToFile:path atomically:YES];
                [self.dataManager saveRecordWithUsername:bareJidStr time:timeNumber path:path length:during isOut:NO];
                [self.dataManager addRecentUsername:bareJidStr time:timeNumber body:voiceType isOut:NO isP2P:YES];
                localNotification.alertBody = [NSString stringWithFormat:@"%@:%@", bareJidStr, voiceType];
                break;
            }
            case 'p':{
                NSData *data = [[NSData alloc]initWithBase64EncodedString:messageBody options:0];
                [self.photoLibraryCenter saveImage:[UIImage imageWithData:data] withCompletionHandler:^(NSString *identifier, NSString *thumbnailPath) {
                    [self.dataManager savePhotoWithUsername:bareJidStr time:timeNumber path:identifier thumbnail:thumbnailPath isOut:NO];
                    [self.dataManager addRecentUsername:bareJidStr time:timeNumber body:pictureType isOut:NO isP2P:NO];
                }];
                break;
            }
                
            default:
                break;
        }
        
//        NSLog(@"%@", message);
        
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
