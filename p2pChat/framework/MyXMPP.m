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
#import "VoiceConverter.h"
#import "XMPPRoomCoreDataStorage.h"
#import "XMPPRoomMemoryStorage.h"

#define Voice @"[语音]"

static NSString *myDomain = @"xmpp.test";
static NSString *myRoomDomain = @"conference.xmpp.test";

@interface MyXMPP () <XMPPStreamDelegate,XMPPRosterStorage,XMPPRosterDelegate,XMPPRoomStorage,XMPPRoomDelegate>

@property (strong, nonatomic) XMPPStream *stream;
@property (strong, nonatomic) XMPPRoster *roster;
@property (strong, nonatomic) XMPPJID *myjid;
@property (strong, nonatomic) NSString *password;

//@property (strong,nonatomic) XMPPvCardCoreDataStorage *vCardStorage;
@property (strong, nonatomic) XMPPvCardAvatarModule *vCardAvatar;
@property (strong, nonatomic) XMPPvCardTemp *myVCardTemp;
@property (strong, nonatomic) XMPPvCardTempModule *vCardModule;

@property (strong, nonatomic) XMPPJID *groupjid;
@property (strong, nonatomic) XMPPRoom *chatroom;
@property (strong, nonatomic) XMPPRoomMemoryStorage *storage;

@property (strong, nonatomic) DataManager *dataManager;

@end

@implementation MyXMPP

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
    if ([self.stream isConnected]) {
        [self disconnected];
    }
    self.myjid = [XMPPJID jidWithUser:user domain:myDomain resource:@"iphone"];
    [self.stream setHostName:@"10.108.136.59"];
    [self.stream setMyJID:self.myjid];
    
    NSError *error = nil;
    if (![self.stream connectWithTimeout:XMPPStreamTimeoutNone error:&error ]) {
        NSLog(@"Connect Error: %@", [[error userInfo] description]);
    }
    
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
    
    [_dataManager saveMessageWithUsername:user time:[NSDate date] body:text isOut:YES];
    [_dataManager addRecentUsername:user time:[NSDate date] body:text isOut:YES];
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
    
    [_dataManager saveRecordWithUsername:user time:[NSDate date] path:path length:length isOut:YES];
    [_dataManager addRecentUsername:user time:[NSDate date] body:Voice isOut:YES];
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
    _myVCardTemp = [_vCardModule myvCardTemp];
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
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        //  回到登陆界面
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        [UIApplication sharedApplication].keyWindow.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"login"];
//    });
}

/**
 *  断开连接
 */
- (void)disconnected{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_stream sendElement:presence];
    [_stream disconnect];
};

- (NSArray<XMPPGroupCoreDataStorageObject *> *)getFriendsGroup {
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

- (void)creatGroupChat:(NSString *)groupname withpassword:(NSString *)roompwd andsubject:(NSString *)subject{//创建聊天室
    _storage = [[XMPPRoomMemoryStorage alloc]init];
    NSString* roomID = [NSString stringWithFormat:@"%@@%@",groupname,myRoomDomain];
    XMPPJID * roomJID = [XMPPJID jidWithString:roomID];
    _chatroom = [[XMPPRoom alloc] initWithRoomStorage:_storage jid:roomJID dispatchQueue:dispatch_get_main_queue()];
    [_chatroom changeRoomSubject:subject];
    [_chatroom activate:self.stream];
    [_chatroom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_chatroom joinRoomUsingNickname:self.stream.myJID.user history:nil password:roompwd];//创建聊天室必须将自己加入聊天室，否则不会创建成功！
}

- (void)inviteFriends:(NSString *)friendname withMessage:(NSString *)text{
    [_chatroom inviteUser:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@xmpp.test",friendname ]]withMessage:text];
}

- (void)fetchMembersFromGroup{
    [_chatroom fetchMembersList];
}

- (void)sendGroupMessage:(NSString *)text{
    [_chatroom sendMessageWithBody:text];
}

- (void)destroyChatRoom{
    [_chatroom destroyRoom];
}


#pragma mark - private method
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

- (NSString *)getSubtypeFrom:(XMPPMessage *)message {
    NSArray *bodyArr = [message elementsForName:@"body"];
    DDXMLElement *body = bodyArr[0];
    return [[body attributeForName:@"subtype"]stringValue];
}

#pragma mark - xmpp delegate

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
    
    [self creatGroupChat:@"chat" withpassword:nil andsubject:@"ios开发"];
//    [self inviteFriends:@"cxh" withMessage:@"hello"];
//    [self destroyChatRoom];
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
    NSLog(@"用户名或密码错误");
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"name"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"password"];
    [[NSNotificationCenter defaultCenter]postNotificationName:MyXmppAuthenticateFailedNotification object:nil];
    [self disconnected];
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
                [_dataManager saveMessageWithUsername:bareJidStr time:[NSDate date] body:messageBody isOut:NO];
                [_dataManager addRecentUsername:bareJidStr time:[NSDate date] body:messageBody isOut:NO];
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
                
                [_dataManager saveRecordWithUsername:bareJidStr time:[NSDate date] path:path length:audiolength isOut:NO];
                [_dataManager addRecentUsername:bareJidStr time:[NSDate date] body:Voice isOut:NO];
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

#pragma mark - vcard delegate
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid{
    
//    NSLog(@"tel...%@",_myVCardTemp.note);
}

- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule{
    NSLog(@"did update");
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error{
    NSLog(@"did not update");
}

#pragma mark - group chat delegate
- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    NSLog(@"did creat chat room");
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

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm
{
    NSLog(@"did configure");
    [self inviteFriends:@"ht" withMessage:@"hellossss"];
    [self inviteFriends:@"cxh" withMessage:@"hello！"];
    
    [self sendGroupMessage:@"哈哈哈哈哈哈哈"];
//    [sender sendMessageWithBody:@"hehehehehehhe"];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items{
    NSLog(@"did fetch members list");
    NSLog(@"%@",items);
}

- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID{
    NSLog(@"did recieve groupchat message");
//    [sender fetchMembersList];
}

@end
