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
#import "Tool.h"

static NSString *myDomain = @"xmpp.test";

@interface MyXMPP () <XMPPStreamDelegate,XMPPRosterStorage,XMPPRosterDelegate>

@property (strong, nonatomic) XMPPStream *stream;
@property (strong, nonatomic) XMPPRoster *roster;
@property (strong, nonatomic) XMPPJID *myjid;
@property (strong, nonatomic) NSString *password;

//@property (strong,nonatomic) XMPPvCardCoreDataStorage *vCardStorage;
@property (strong, nonatomic) XMPPvCardAvatarModule *vCardAvatar;
@property (strong, nonatomic) XMPPvCardTemp *myVCardTemp;
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
    _vCardAvatar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_vCardModule];
    [_vCardModule activate:self.stream];
    [_vCardAvatar activate:_stream];
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
    
    NSString *to = [NSString stringWithFormat:@"%@@%@", user, myDomain];
    [message addAttributeWithName:@"to" stringValue:to];
    
    [message addChild:body];
    [self.stream sendElement:message];
    
    [_dataManager saveMessageWithUsername:user time:[NSDate date] body:text isOut:YES];
    [_dataManager addRecentUsername:user time:[NSDate date] body:text isOut:YES];
}

- (void)sendAudio:(NSString *)path ToUser:(NSString *)user length:(NSString *)length{
    NSLog(@"audio");
    
    NSFileManager *filemnanager=[NSFileManager defaultManager];
    NSData *p = [filemnanager contentsAtPath:path];
    NSData *content = [p base64EncodedDataWithOptions:0];
    
    NSLog(@"send size: %ld", content.length);
    
//    NSString *audiomsg = [[NSString alloc] initWithBytes:content.bytes length:content.length encoding:NSUTF8StringEncoding];
    
    NSString *audiomsg = [[NSString alloc]initWithData:content encoding:NSUTF8StringEncoding];//audiomsg 是空，待解决
    NSString *audiomsgwithlength = [NSString stringWithFormat:@"%@,%@",length,audiomsg];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:audiomsgwithlength];
    
    NSXMLElement *audiomessage = [NSXMLElement elementWithName:@"message"];
    [audiomessage addAttributeWithName:@"type" stringValue:@"audio"];
    
    NSString *to = [NSString stringWithFormat:@"%@@%@", user, myDomain];
    [audiomessage addAttributeWithName:@"to" stringValue:to];
    
//    NSString *audiolength = length;
//    [audiomessage addAttributeWithName:@"audiolength" stringValue:audiolength];
    
    [audiomessage addChild:body];
    [self.stream sendElement:audiomessage];
    
    [_dataManager saveRecordWithUsername:user time:[NSDate date] path:path length:length isOut:YES];
    [_dataManager addRecentUsername:user time:[NSDate date] body:voice isOut:YES];
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
    [self.myVCardTemp setEmailAddresses:@[email]];
    [self.vCardModule updateMyvCardTemp:self.myVCardTemp];
}

- (void)updateMyNote:(NSString *)note {
    
    [self.vCardModule vCardTempForJID:self.myjid shouldFetch:YES];
    [self.myVCardTemp setNote:note];
    [self.vCardModule updateMyvCardTemp:self.myVCardTemp];
}

- (void)updateMyTel:(NSString *)tel {
        //Set Values as normal

    _myVCardTemp = [_vCardModule myvCardTemp];
//    if (!_myVCardTemp){
//        NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
//        XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
//        [newvCardTemp setNickname:@"aa"];
//        [_vCardModule updateMyvCardTemp:newvCardTemp];
//    }else{
//        _myVCardTemp.note = tel;
//    }
    _myVCardTemp.note = tel;
    
    [self.vCardModule updateMyvCardTemp:self.myVCardTemp];
    NSLog(@"mynote%@",_myVCardTemp);
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

- (void)loginout{
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

- (NSArray<XMPPGroupCoreDataStorageObject *> *)getFriends {
    NSManagedObjectContext *context = [[XMPPRosterCoreDataStorage sharedInstance] mainThreadManagedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPGroupCoreDataStorageObject"];
    //排序
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];//jidStr
    request.sortDescriptors = @[sort];
    
    NSError *err = nil;
    NSArray<XMPPGroupCoreDataStorageObject *> *friendGroups = [context executeFetchRequest:request error:&err];
    if (err != nil) {
        NSLog(@"myxmpp fetch friend failed: %@", err);
    }
    
    //XMPPUserCoreDataStorageObject  *obj类型的
    //名称为 obj.displayName
    return friendGroups;
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
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [UIApplication sharedApplication].keyWindow.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"tablebar"];
    
//    [self changeMyPassword:@"11"];
//    [self updateMyTel:@"13253545377"];
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
    NSLog(@"disconnet error:%@",error);
    [[NSNotificationCenter defaultCenter]postNotificationName:MyXmppConnectFailedNotification object:nil];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    NSLog(@"Connect Error didNotAuthenticate: %@", error);
    NSLog(@"用户名或密码错误");
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"name"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"password"];
    [[NSNotificationCenter defaultCenter]postNotificationName:MyXmppAuthenticateFailedNotification object:nil];
    [self disconnected];
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
    } if([message.type isEqualToString:@"audio"] && message.body !=nil){

        NSString *audiomessageBody = [[message elementForName:@"body"] stringValue];
        
        NSRange range1 = NSMakeRange(0, 9);
        NSString *audiolength = [audiomessageBody substringWithRange:range1];//获取语音消息长度
        NSRange range2 = NSMakeRange(9, [audiomessageBody length]-9);
        NSString *audiomsg = [audiomessageBody substringWithRange:range2];
        
        NSData *data = [[NSData alloc] initWithBase64EncodedString:audiomsg options:0];
         
//        NSData* data = [audiomsg dataUsingEncoding:NSUTF8StringEncoding];
        
        NSLog(@"did recieve audio message :%@, length: %ld",audiomessageBody, data.length);
        
        NSString *jidStr = message.fromStr;
        NSRange range3 = [jidStr rangeOfString:@"@"];
        jidStr = [jidStr substringToIndex:range3.location];
        NSLog(@"%@", jidStr);


        [_dataManager saveRecordWithUsername:jidStr time:[NSDate date] path:[Tool getFileName:@"recieve" extension:@"caf"] length:audiolength isOut:NO];
        [_dataManager addRecentUsername:jidStr time:[NSDate date] body:audiomessageBody isOut:NO];
 
    }
        else {
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
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid{
    
    NSLog(@"tel...%@",_myVCardTemp.note);
}

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
