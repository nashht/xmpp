//
//  MyXMPP+P2PChat.m
//  p2pChat
//
//  Created by xiaokun on 16/4/21.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyXMPP+P2PChat.h"
#import "AFNetworking.h"
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
//    NSDate *d = [NSDate date];
//    NSDate *date = [Tool transferDate:d];
//    NSNumber *t = [NSNumber numberWithDouble:[date timeIntervalSince1970]];
//    int time = [t intValue];
    
    NSDate *date = [NSDate date];
    NSTimeInterval t = [date timeIntervalSince1970];
    int time = (int)t;
    
    NSDate *d = [Tool transferDate:date];
    NSNumber *ltime= [NSNumber numberWithDouble:[d timeIntervalSince1970]];
//    NSNumber *lasttime= [NSNumber numberWithInt:time];
//    NSDate *d2 = [NSDate dateWithTimeIntervalSince1970:[t intValue]];
//    NSDate *d1 = [Tool transferDate:d];
//    NSLog(@"send time :%@",d1);
    
    [self sendMessageWithSubtype:@"text" time:time body:text more:nil toUser:user];
    
    [self.dataManager saveMessageWithUsername:user time:[NSNumber numberWithDouble:time]  body:text isOut:YES];
    [self.dataManager addRecentUsername:user time:ltime body:text isOut:YES isP2P:YES];
}

- (void)sendAudio:(NSString *)path ToUser:(NSString *)user length:(NSString *)length{
    NSFileManager *filemnanager=[NSFileManager defaultManager];
    NSData *p = [filemnanager contentsAtPath:path];
    NSLog(@"MyXmpp: audio file length :%lu", (unsigned long)p.length);
    NSString *audiomsg = [p base64EncodedStringWithOptions:0];
    
    NSDate *date = [NSDate date];
    NSTimeInterval t = [date timeIntervalSince1970];
    int time = (int)t;
    
    NSDate *d = [Tool transferDate:date];
    NSNumber *ltime= [NSNumber numberWithDouble:[d timeIntervalSince1970]];
    
    [self sendMessageWithSubtype:@"audio" time:time body:audiomsg more:length toUser:user];
    
    [self.dataManager saveRecordWithUsername:user time:[NSNumber numberWithInt:time] path:path length:length isOut:YES];
    [self.dataManager addRecentUsername:user time:ltime body:voiceType isOut:YES isP2P:YES];
}



- (void)sendPictureIdentifier:(NSString *)identifier data:(NSData *)imageData thumbnailName:(NSString *)thumbnailName filename:(NSString *)filename ToUser:(NSString *)user{
    NSString *picString = [imageData base64EncodedStringWithOptions:0];
    
    NSDate *date = [NSDate date];
    NSTimeInterval t = [date timeIntervalSince1970];
    int time = (int)t;
    
    NSDate *d = [Tool transferDate:date];
    NSNumber *ltime= [NSNumber numberWithDouble:[d timeIntervalSince1970]];
    
    [self sendMessageWithSubtype:@"picture" time:time body:picString more:filename toUser:user];
    [self.dataManager savePhotoWithUsername:user time:[NSNumber numberWithInt:time] filename:identifier thumbnail:thumbnailName isOut:YES];
    [self.dataManager addRecentUsername:user time:ltime body:pictureType isOut:YES isP2P:YES];
}

#pragma mark - receivemessage delegate
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    if ([message isChatMessageWithBody]) {
        NSString *subtype = [message getSubtype];
        NSString *timeStr = [message getTime];
        NSNumber *timeNumber = [NSNumber numberWithInt:[timeStr intValue]];//聊天记录中的时间
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeNumber doubleValue]];
        
        NSDate *d = [Tool transferDate:date];
        NSNumber *ltime= [NSNumber numberWithDouble:[d timeIntervalSince1970]];//最后一条消息的时间
        NSLog(@"xmppStream recieve time:%@",d);
        
        NSString *messageBody = [[message elementForName:@"body"] stringValue];
        XMPPJID *fromJid = message.from;
        NSString *bareJidStr = fromJid.user;
        
        UILocalNotification *localNotification = [[UILocalNotification alloc]init];
        localNotification.fireDate = [NSDate date];
        
        char firstLetter = [subtype characterAtIndex:0];
        switch(firstLetter) {
            case 't':{//text
                [self.dataManager saveMessageWithUsername:bareJidStr time:timeNumber body:messageBody isOut:NO];
                [self.dataManager addRecentUsername:bareJidStr time:ltime body:messageBody isOut:NO isP2P:YES];
                localNotification.alertBody = [NSString stringWithFormat:@"%@:%@", bareJidStr, messageBody];
                break;
            }
            case 'a':{//audio
                NSString *during = [message getMore];
                NSData *data = [[NSData alloc] initWithBase64EncodedString:messageBody options:0];
                
                NSString *path = [Tool getFileName:@"receive" extension:@"wav"];
                [data writeToFile:path atomically:YES];
                [self.dataManager saveRecordWithUsername:bareJidStr time:timeNumber path:path length:during isOut:NO];
                [self.dataManager addRecentUsername:bareJidStr time:ltime body:voiceType isOut:NO isP2P:YES];
                localNotification.alertBody = [NSString stringWithFormat:@"%@:%@", bareJidStr, voiceType];
                break;
            }
            case 'p':{//pic
                NSData *data = [[NSData alloc]initWithBase64EncodedString:messageBody options:0];
                NSString *path = [Tool getFileName:@"receive" extension:@"jpeg"];
                NSString *filename = [message getMore];
                [data writeToFile:path atomically:YES];
                
                NSString  *thumbnailName = [NSString stringWithFormat:@"%@receive.jpeg",[Tool stringFromDate:[NSDate date]]];
                
                [self.dataManager savePhotoWithUsername:bareJidStr time:timeNumber filename:filename thumbnail:thumbnailName isOut:NO];
                [self.dataManager addRecentUsername:bareJidStr time:ltime body:pictureType isOut:NO isP2P:YES];
                break;
            }
                
            default:
                break;
        }
        
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
