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
static NSString *fileType = @"[文件]";

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
    
//    NSNumber *lasttime= [NSNumber numberWithInt:time];
//    NSDate *d2 = [NSDate dateWithTimeIntervalSince1970:[t intValue]];
//    NSDate *d1 = [Tool transferDate:d];
//    NSLog(@"send time :%@",d1);
    
    [self sendMessageWithSubtype:@"text" time:time body:text more:nil toUser:user];
    
    [self.dataManager saveMessageWithUsername:user time:[NSNumber numberWithDouble:time]  body:text isOut:YES];
    [self.dataManager addRecentUsername:user time:[NSNumber numberWithInt:time] body:text isOut:YES isP2P:YES];
}

- (void)sendAudio:(NSString *)path ToUser:(NSString *)user length:(NSString *)length{
    NSFileManager *filemnanager=[NSFileManager defaultManager];
    NSData *p = [filemnanager contentsAtPath:path];
    NSLog(@"MyXmpp: audio file length :%lu", (unsigned long)p.length);
    NSString *audiomsg = [p base64EncodedStringWithOptions:0];
    
    NSDate *date = [NSDate date];
    NSTimeInterval t = [date timeIntervalSince1970];
    int time = (int)t;
    
    [self sendMessageWithSubtype:@"audio" time:time body:audiomsg more:length toUser:user];
    
    [self.dataManager saveRecordWithUsername:user time:[NSNumber numberWithInt:time] path:path length:length isOut:YES];
    [self.dataManager addRecentUsername:user time:[NSNumber numberWithInt:time] body:voiceType isOut:YES isP2P:YES];
}

- (void)sendFile:(NSString *)filename ToUser:(NSString *)user fileSize:(NSString *)fileSize{
    NSDate *date = [NSDate date];
    NSTimeInterval t = [date timeIntervalSince1970];
    int time = (int)t;
//    path 和 filename 存的是一样的
    [self sendMessageWithSubtype:@"file" time:time body:filename more:fileSize toUser:user];
    [self.dataManager saveFileWithUsername:user time:[NSNumber numberWithInt:time] filename:filename fileSize:fileSize isOut:YES];
    [self.dataManager addRecentUsername:user time:[NSNumber numberWithInt:time] body:fileType isOut:YES isP2P:YES];
}


- (void)sendPictureIdentifier:(NSString *)identifier data:(NSData *)imageData thumbnailData:(NSData *)thumbnailData thumbnailName:(NSString *)thumbnailName filename:(NSString *)filename ToUser:(NSString *)user{
    
    NSDate *date = [NSDate date];
    NSTimeInterval t = [date timeIntervalSince1970];
    int time = (int)t;
    
    [self.dataManager savePhotoWithUsername:user time:[NSNumber numberWithInt:time] filename:identifier thumbnail:thumbnailName isOut:YES];
    [self.dataManager addRecentUsername:user time:[NSNumber numberWithInt:time] body:pictureType isOut:YES isP2P:YES];
}

- (void)uploadPic:(NSData *)imageData thumbnailData:(NSData *)thumbnailData filename:(NSString *)filename toUser:(NSString *)user{
    NSLog(@"uploadPic2Server");
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"method"] = @"upload";
    param[@"filename"] = filename;
    // 参数para:{method:"upload"/"download",filename:"xxx"}(filename格式：username_timestamp
    //     访问路径
    //    NSString *stringURL = @"http://10.108.136.59:8080/FileServer/file?method=upload&filename=1123";
    //    NSString *url = [NSString stringWithFormat:@"http://10.108.136.59:8080/FileServer/file?method=upload&filename=",filename];
    [manager POST: @"http://10.108.136.59:8080/FileServer/file" parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        // 拼接文件参数
        [formData appendPartWithFileData:imageData name:@"file" fileName:filename mimeType:@"application/octet-stream"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"uploadProgress ---  %@",uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"success%@",json);
        
        NSString *picString = [thumbnailData base64EncodedStringWithOptions:0];
        NSDate *date = [NSDate date];
        NSTimeInterval t = [date timeIntervalSince1970];
        int time = (int)t;
        
        [self sendMessageWithSubtype:@"picture" time:time body:picString more:filename toUser:user];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed------error:   %@",error);
    }];
    
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
                NSString *filename = [message getMore];
                NSString *thumbnailName = [NSString stringWithFormat:@"%@_receiveThumbnail",filename];
                NSString *path = [Tool getFileName:thumbnailName extension:@"jpeg"];
                [data writeToFile:path atomically:YES];
                
                [self.dataManager savePhotoWithUsername:bareJidStr time:timeNumber filename:filename thumbnail:thumbnailName isOut:NO];
                [self.dataManager addRecentUsername:bareJidStr time:ltime body:pictureType isOut:NO isP2P:YES];
                break;
            }
            
            case 'f':{
                NSString *filename = message.body;
                NSString *fileSize = [message getMore];
                [self.dataManager saveFileWithUsername:bareJidStr time:timeNumber filename:filename fileSize:fileSize isOut:NO];
                 [self.dataManager addRecentUsername:bareJidStr time:ltime body:messageBody isOut:NO isP2P:YES];
                localNotification.alertBody = [NSString stringWithFormat:@"%@:%@", bareJidStr, messageBody];
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
