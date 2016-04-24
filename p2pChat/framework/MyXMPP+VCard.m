//
//  MyXMPP+VCard.m
//  p2pChat
//
//  Created by xiaokun on 16/4/21.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MyXMPP+VCard.h"
#import "XMPPvCardTempModule.h"
#import "XMPPvCardTempEmail.h"
#import "XMPPvCardTempAdr.h"

@implementation MyXMPP (VCard)

- (XMPPvCardTemp *)fetchFriend:(XMPPJID *)userJid {
    return [self.vCardModule vCardTempForJID: userJid shouldFetch:YES];
}

- (void)updateMyInfo:(NSString *)newValue withType:(MyXmppUpdateType)type {
    switch (type) {
        case MyXmppUpdateTypeMobilePhone:
            self.myVCardTemp.note = newValue;
            break;
        case MyXmppUpdateTypeAddress:
            
            break;
        case MyXmppUpdateTypeEmail:

            break;
        case MyXmppUpdateTypePhone:
            
            break;
        case MyXmppUpdateTypeTitle:
            self.myVCardTemp.title = newValue;
            break;
    }
    [self.vCardModule updateMyvCardTemp:self.myVCardTemp];
}

- (void)updataeMyPhoto:(NSData *)photoData {
    self.myVCardTemp.photo = photoData;
    [self.vCardModule updateMyvCardTemp:self.myVCardTemp];
}

- (void)changeMyPassword:(NSString *)newpassword {
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:register"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"to" stringValue:@"xmpp.test"];
    [iq addAttributeWithName:@"id" stringValue:@"change1"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults stringForKey:@"name"];
    
    NSXMLElement *username = [NSXMLElement elementWithName:@"username"];
    [username setStringValue:userId];
    
    NSXMLElement *password = [NSXMLElement elementWithName:@"password"];
    [password setStringValue:newpassword];
    
    [query addChild:username];
    [query addChild:password];
    [iq addChild:query];
    NSLog(@"%@发送iq",iq);
    [self.stream sendElement:iq];
    [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

#pragma mark - vcard delegate
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid{
    
    //    NSLog(@"tel...%@",_myVCardTemp.note);
}

- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule{
    NSLog(@"did update");
    [[NSNotificationCenter defaultCenter]postNotificationName:MyXmppUpdatevCardSuccessNotification object:nil];
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error{
    NSLog(@"did not update");
    [[NSNotificationCenter defaultCenter]postNotificationName:MyXmppUpdatevCardFailedNotification object:nil];
}

@end
