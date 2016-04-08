//
//  MyXMPP.m
//  p2pChat
//
//  Created by xiaokun on 16/3/4.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MyXMPP.h"
#import "XMPPFramework.h"

#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardTempModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPvCardTemp.h"
#import "DataManager.h"

@interface MyXMPP () <XMPPStreamDelegate,XMPPRosterStorage,XMPPRosterDelegate>

@property (strong, nonatomic) XMPPStream *stream;
@property (strong, nonatomic) XMPPRoster *roster;
@property (strong, nonatomic) XMPPJID *myjid;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) XMPPReconnect *reconnect;

@property (strong,nonatomic) XMPPvCardCoreDataStorage *vCardStorage;
@property (strong, nonatomic) XMPPvCardAvatarModule *vCardAvatar;
@property (strong, nonatomic) XMPPvCardTempModule *vCardModule;

@property (strong, nonatomic) DataManager *dataManager;

@end

@implementation MyXMPP

- (id)init {
    self = [super init];
    
    if (self.stream == nil) {
        self.stream = [[XMPPStream alloc] init];
        [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        _dataManager = [DataManager shareManager];
    }

    return self;
}

- (void)initRoster {
    _roster = [[XMPPRoster alloc]initWithRosterStorage:[XMPPRosterCoreDataStorage sharedInstance]];
    _roster.autoFetchRoster = YES;
    [_roster addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
    [_roster activate:_stream];
    [_roster fetchRoster];
}

- (void)initVCard {
    _vCardModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:[XMPPvCardCoreDataStorage sharedInstance]];
    [_vCardModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_vCardModule activate:_stream];
    
    _vCardAvatar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_vCardModule];
    [_vCardAvatar activate:_stream];

}

- (void)initReconnect{
    _reconnect = [[XMPPReconnect alloc] init];
    [_reconnect activate:_stream];
}

+ (instancetype)shareInstance {
    static MyXMPP *myXmpp;
    static dispatch_once_t myXmppToken;
    dispatch_once(&myXmppToken, ^{
        myXmpp = [[MyXMPP alloc]init];
    });
    
    return myXmpp;
}

- (void)loginWithName:(NSString *)user Password:(NSString *)password {
    self.password = password;
    if (![_stream isConnected]) {
        self.myjid = [XMPPJID jidWithUser:user domain:@"10.108.136.59" resource:@"iphone"];
        [_stream setMyJID:self.myjid];
        
        NSError *error = nil;
        if (![_stream connectWithTimeout:XMPPStreamTimeoutNone error:&error ]) {
            NSLog(@"Connect Error: %@", [[error userInfo] description]);
        }
    }
}

- (void)sendMessage:(NSString *)text ToUser:(NSString *) user {
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:text];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    
    NSString *to = [NSString stringWithFormat:@"%@@xmpp.test", user];
    [message addAttributeWithName:@"to" stringValue:to];
    
    [message addChild:body];
    [self.stream sendElement:message];
    
    [_dataManager saveMessageWithUsername:user time:[NSDate date] body:text isOut:YES];
    [_dataManager addRecentUsername:user time:[NSDate date] body:text isOut:YES];
}

- (void)updateFriendsList {
    
    //获取 roster 列表，获取好友列表
    if ([self.roster autoFetchRoster]){
        [_roster fetchRoster];//获取好友列表，之后自动调用xmppRosterDidEndPopulating和xmppRosterDidPopulate
    }
}

- (XMPPvCardTemp *)fetchFriend:(XMPPJID *)userJid {
    return [_vCardModule vCardTempForJID: userJid shouldFetch:YES];
}

- (void)updateMyEmail:(NSString *)email {
    XMPPvCardTemp *myVCardTemp = [_vCardModule myvCardTemp];
    myVCardTemp.mailer = email;
    [_vCardModule updateMyvCardTemp:myVCardTemp];
}

- (void)updateMyNote:(NSString *)note {
    
}

- (void)updateMyTel:(NSString *)tel {

     XMPPvCardTemp *myVCardTemp = [_vCardModule myvCardTemp];
    myVCardTemp.note = tel;
    
    [self.vCardModule updateMyvCardTemp:myVCardTemp];
    NSLog(@"mynote%@",myVCardTemp);
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

- (void)logout{
    [self disconnected];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //  回到登陆界面
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        [UIApplication sharedApplication].keyWindow.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"login"];
    });
}

/**
 *  断开连接
 */
- (void)disconnected{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_stream sendElement:presence];
    [_stream disconnect];
};

- (NSFetchedResultsController *)getFriends {
    NSManagedObjectContext *context = [[XMPPRosterCoreDataStorage sharedInstance] mainThreadManagedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    //排序
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"jidStr" ascending:YES];//jidStr
    request.sortDescriptors = @[sort];
    
    NSFetchedResultsController *fetchFriends = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    NSError *error = nil;
    if (![fetchFriends performFetch:&error]) {
        NSLog(@"fetching friends error: %@", error);
    }
    
    return fetchFriends;
}



#pragma mark - xmpp delegate

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket{
    NSLog(@"成功连接到服务器");
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    //    NSLog(@"连接成功");
    NSError *err = nil;
    if (![_stream authenticateWithPassword:self.password error:&err]){
        NSLog(@"Connect Error: %@", [[err userInfo] description]);
    }
    else{
        NSLog(@"正在验证密码...");
    }
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    NSLog(@"连接超时");
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [self.stream sendElement:presence];
    NSLog(@"登录成功");
    [[NSNotificationCenter defaultCenter]postNotificationName:MyXmppDidLoginNotification object:nil];
    
    //roster初始化
    [self initRoster];
    
    //vcard初始化
    [self initVCard];
    
    [self initReconnect];
    
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    
    NSString *iqTypePWD = [[iq attributeForName:@"type"]stringValue];
    
    NSString *iqIDPWD = [[iq attributeForName:@"id"]stringValue];
    
//    NSLog(@"iqTypePWD:%@___iqTypePWD:%@",iqTypePWD,iqIDPWD);
    
    if ([iqTypePWD isEqualToString:@"result"]&&[iqIDPWD isEqualToString:@"change1"]) {   //进行判断只有type="result" id="change1"时,密码修改成功
//        NSLog(@"OpenFire密码修改成功!");
    }else{
//        NSLog(@"OpenFire密码修改不成功!");
    }
    return YES;
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    NSString *presenceType = [presence type];
    NSString *presenceFromUser = [[presence from] user];
    NSString *myID = [[sender myJID] user];
    if (presenceFromUser != myID) {
        if ([presenceType isEqualToString:@"available"]) {
            NSLog(@"%@上线了",presenceFromUser);
        }else if([presenceType isEqualToString:@"unavailable"]){
            NSLog(@"%@下线了",presenceFromUser);
        }
    }
}

/**
 * This method is called if authentication fails.
 **/

#pragma mark - connect delegate
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    NSLog(@"DidDisconnect");
    [[NSNotificationCenter defaultCenter]postNotificationName:MyXmppConnectFailedNotification object:nil];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    NSLog(@"Connect Error didNotAuthenticate: %@", error);
    NSLog(@"用户名或密码错误");
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"name"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"password"];
    [self disconnected];
}

#pragma mark - receivemessage delegate
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    if ([message.type isEqualToString:@"chat"] && message.body) {
        NSString *messageBody = [[message elementForName:@"body"] stringValue];
        
        NSLog(@"my xmpp did receive message:%@ from:  %@", messageBody,message.from.user);
//        NSLog(@"user = %@",message.from.user);
        [_dataManager saveMessageWithUsername:message.from.user time:[NSDate date] body:messageBody isOut:NO];
        [_dataManager addRecentUsername:message.from.user time:[NSDate date] body:messageBody isOut:NO];
    } else {
//        NSLog(@"receive message%@", message);
    }
    
}

#pragma mark - sendmessage delegate
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error {
    NSLog(@"send message error : %@", error);
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    NSLog(@"did send message");
}

#pragma mark - vcard delegate
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid{
    
}

- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule{
    NSLog(@"did update my vCard");
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error{
    NSLog(@"did not update my vCard");
}

#pragma mark - roster delegate
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender {

}


@end
