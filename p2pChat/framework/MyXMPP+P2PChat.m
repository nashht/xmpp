//
//  MyXMPP+P2PChat.m
//  p2pChat
//
//  Created by xiaokun on 16/4/21.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MyXMPP+P2PChat.h"
#import "XMPPStream.h"
#import "XMPPMessage.h"
#import "NSXMLElement+XMPP.h"
#import "DataManager.h"
#import "Tool.h"
#import "VoiceConverter.h"

#define Voice @"[语音]"

@implementation MyXMPP (P2PChat)

- (NSString *)getSubtypeFrom:(XMPPMessage *)message {
    NSArray *bodyArr = [message elementsForName:@"body"];
    DDXMLElement *body = bodyArr[0];
    return [[body attributeForName:@"subtype"]stringValue];
}

- (void)sendMessage:(NSString *)text ToUser:(NSString *) user {
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:text];
    [body addAttributeWithName:@"subtype" stringValue:@"text"];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    
    
    NSString *to = [NSString stringWithFormat:@"%@@%@", user, myDomain];
    [message addAttributeWithName:@"to" stringValue:to];
    
    [message addChild:body];
    [self.stream sendElement:message];
    NSLog(@"message : %@", message);
    
    [self.dataManager saveMessageWithUsername:user time:[NSDate date] body:text isOut:YES];
    [self.dataManager addRecentUsername:user time:[NSDate date] body:text isOut:YES];
}

- (void)sendAudio:(NSString *)path ToUser:(NSString *)user length:(NSString *)length{
    NSFileManager *filemnanager=[NSFileManager defaultManager];
    NSData *p = [filemnanager contentsAtPath:path];
    
    NSString *audiomsg = [p base64EncodedStringWithOptions:0];
    NSString *audiomsgwithlength = [NSString stringWithFormat:@"%@,%@",length,audiomsg];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:audiomsgwithlength];
    [body addAttributeWithName:@"subtype" stringValue:@"audio"];
    
    NSXMLElement *audiomessage = [NSXMLElement elementWithName:@"message"];
    [audiomessage addAttributeWithName:@"type" stringValue:@"chat"];
    
    NSString *to = [NSString stringWithFormat:@"%@@%@", user, myDomain];
    [audiomessage addAttributeWithName:@"to" stringValue:to];
    
    [audiomessage addChild:body];
    [self.stream sendElement:audiomessage];
    
    [self.dataManager saveRecordWithUsername:user time:[NSDate date] path:path length:length isOut:YES];
    [self.dataManager addRecentUsername:user time:[NSDate date] body:Voice isOut:YES];
}

#pragma mark - receivemessage delegate
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    if ([message isChatMessageWithBody]) {
        NSString *subtype = [self getSubtypeFrom:message];
        NSString *messageBody = [[message elementForName:@"body"] stringValue];
        XMPPJID *fromJid = message.from;
        NSString *bareJidStr = fromJid.user;
        char firstLetter = [subtype characterAtIndex:0];
        switch (firstLetter) {
            case 't':{//text
                [self.dataManager saveMessageWithUsername:bareJidStr time:[NSDate date] body:messageBody isOut:NO];
                [self.dataManager addRecentUsername:bareJidStr time:[NSDate date] body:messageBody isOut:NO];
                break;
            }
            case 'a':{//audio
                NSRange range1 = NSMakeRange(0, 9);
                NSString *audiolength = [messageBody substringWithRange:range1];//获取语音消息长度
                NSRange range2 = NSMakeRange(9, [messageBody length]-9);
                NSString *audiomsg = [messageBody substringWithRange:range2];
                
                NSData *data = [[NSData alloc] initWithBase64EncodedString:audiomsg options:0];
                
                NSLog(@"did recieve audio message :%@, length: %lu",messageBody, (unsigned long)data.length);
                
                NSString *tmpPath = [Tool getFileName:@"tmp" extension:@"amr"];
                NSString *path = [Tool getFileName:@"receive" extension:@"wav"];
                [data writeToFile:tmpPath atomically:YES];
                [VoiceConverter amrToWav:tmpPath wavSavePath:path];
                
                [self.dataManager saveRecordWithUsername:bareJidStr time:[NSDate date] path:path length:audiolength isOut:NO];
                [self.dataManager addRecentUsername:bareJidStr time:[NSDate date] body:Voice isOut:NO];
                break;
            }
            case 'p':{
                
                break;
            }
                
            default:
                break;
        }
        
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
