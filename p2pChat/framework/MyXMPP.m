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

@interface MyXMPP () <XMPPStreamDelegate>

@property (strong, nonatomic) XMPPStream *stream;
@property (strong, nonatomic) XMPPRoster *roster;
@property (strong, nonatomic) XMPPJID *myjid;
@property (strong, nonatomic) NSString *password;

@property (strong, nonatomic) XMPPvCardAvatarModule *vCardAvatar;
@property (strong, nonatomic) XMPPvCardTemp *vCardTemp;
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
    [_vCardModule activate:self.stream];
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
    if (![self.stream isConnected]) {
        self.myjid = [XMPPJID jidWithUser:user domain:@"10.108.136.59" resource:@"iphone"];
        [self.stream setMyJID:self.myjid];
        
        NSError *error = nil;
        if (![self.stream connectWithTimeout:XMPPStreamTimeoutNone error:&error ]) {
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

- (void)updateMyEmail:(NSArray *)email {
    [self.vCardTemp setEmailAddresses:email];
    [self.vCardModule updateMyvCardTemp:self.vCardTemp];
}

- (void)updateMyNote:(NSString *)note {
    
    [self.vCardModule vCardTempForJID:self.myjid shouldFetch:YES];
    
    [self.vCardTemp setNote:note];
    [self.vCardModule updateMyvCardTemp:self.vCardTemp];
}

- (void)updateMyTel:(NSString *)tel {
    
}

- (void)changeMyPassword:(NSString *)newpassword {
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:register"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"to" stringValue:@"ubuntu-dev"];
    [iq addAttributeWithName:@"id" stringValue:@"change1"];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults stringForKey:@"cxh"];
    
    
    DDXMLNode *username=[DDXMLNode elementWithName:@"username" stringValue:userId];//不带@后缀
    DDXMLNode *password=[DDXMLNode elementWithName:@"password" stringValue:newpassword];//要改的密码
    [query addChild:username];
    [query addChild:password];
    [iq addChild:query];
    NSLog(@"%@iq",iq);
    [self.stream sendElement:iq];
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
    
    //XMPPUserCoreDataStorageObject  *obj类型的
    //名称为 obj.displayName
    return fetchFriends;
//    XMPPUserCoreDataStorageObject
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
    
//    [self disconnected];          //  断开连接
    [self changeMyPassword:@"111"];
}

/**
 * This method is called if authentication fails.
 **/

#pragma mark - connect delegate
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    NSLog(@"DidDisconnect");
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    NSLog(@"Connect Error didNotAuthenticate: %@", error);
    NSLog(@"用户名或密码错误");
}

#pragma mark - receivemessage delegate
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    if ([message.type isEqualToString:@"chat"] && message.body != nil) {
        NSString *messageBody = [[message elementForName:@"body"] stringValue];
        NSLog(@"my xmpp did receive message: %@", messageBody);
        NSString *bareJidStr = message.fromStr;
        NSRange range = [bareJidStr rangeOfString:@"@"];
        bareJidStr = [bareJidStr substringToIndex:range.location];
        
        NSLog(@"%@", bareJidStr);
        
        [_dataManager saveMessageWithUsername:bareJidStr time:[NSDate date] body:messageBody isOut:NO];
        [_dataManager addRecentUsername:bareJidStr time:[NSDate date] body:messageBody isOut:NO];
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

#pragma mark - vcard delegate
//- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
//        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
//                     forJID:(XMPPJID *)jid{
//    NSLog(@"获取名片");
//    //    [vCardTemp setNickname:@"ccc"];
//    //    [vCardTemp setNote:@"加油！"];
//    //    [_vCardModule updateMyvCardTemp:vCardTemp];//用于提交更新过的名片数据，只能更新自己的
//    NSString *nickname = vCardTemp.nickname;
//    NSArray *emailaddresse = vCardTemp.emailAddresses;
//    NSString *note = vCardTemp.note;
//    NSLog(@"昵称:%@ 邮箱:%@ 签名:%@ ",nickname,emailaddresse,note);
//}

- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule{
    NSLog(@"did update");
    
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error{
    NSLog(@"did not update");
}

#pragma mark - roster delegate
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender {

}


@end
