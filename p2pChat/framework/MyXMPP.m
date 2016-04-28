//
//  MyXMPP.m
//  p2pChat
//
//  Created by xiaokun on 16/3/4.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MyXMPP.h"
#import "MyXMPP+Roster.h"
#import "XMPPFramework.h"
#import "XMPPvCardCoreDataStorage.h"
#import "DataManager.h"
#import "Tool.h"
#import "MyXMPP+Group.h"
#import "Reachability.h"
#import "PhotoLibraryCenter.h"

@interface MyXMPP () <XMPPStreamDelegate> {
    BOOL _hasInit;
    BOOL _timerIsRunning;
}

@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) XMPPvCardAvatarModule *vCardAvatar;
@property (strong, nonatomic) NSTimer *reconnectTimer;

@property (strong, nonatomic) Reachability *reachability;

@end

static NSString *serverHost = @"10.108.136.59";

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
    _myjid = [XMPPJID jidWithUser:user domain:myDomain resource:@"iphone"];
    [self.stream setHostName:serverHost];
    [self.stream setMyJID:self.myjid];
    
    NSError *error = nil;
    if (![self.stream connectWithTimeout:XMPPStreamTimeoutNone error:&error ]) {
        NSLog(@"Connect Error: %@", [[error userInfo] description]);
    }
}

- (void)loginout {
    [self disconnected];
}

- (void)reconnect {
    [self loginWithName:_myjid.user Password:_password];
}

/**
 *  断开连接
 */
- (void)disconnected{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_stream sendElement:presence];
    [_stream disconnect];
};

#pragma mark - private method
- (id)init {
    self = [super init];
    _hasInit = NO;
    if (self.stream == nil) {
        self.stream = [[XMPPStream alloc] init];
        [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        self.stream.enableBackgroundingOnSocket = YES;
    }
    _dataManager = [DataManager shareManager];
    
    _reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(reconnect) userInfo:nil repeats:YES];
    [_reconnectTimer setFireDate:[NSDate distantFuture]];
    _timerIsRunning = NO;
    
    _reachability = [Reachability reachabilityWithHostName:serverHost];//监测网络状态的类
    [_reachability startNotifier];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkStatusChanaged) name:kReachabilityChangedNotification object:nil];
    
    _photoLibraryCenter = [[PhotoLibraryCenter alloc]init];
    
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
    _myVCardTemp = [_vCardModule myvCardTemp];
}

- (void)networkStatusChanaged {
    NSLog(@"网络状态变化");
    if (!_stream.isConnected) {
        [_reconnectTimer setFireDate:[NSDate date]];
        _timerIsRunning = YES;
    }
}

- (void)initmuc{
    
    self.muc = [[XMPPMUC alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    [self.muc activate:self.stream];
    [self.muc addDelegate:self delegateQueue:dispatch_get_main_queue()];

}

#pragma mark - xmpp delegate
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSError *err = nil;
    if (![_stream authenticateWithPassword:self.password error:&err]){
        NSLog(@"Connect Error: %@", [[err userInfo] description]);
    }
    else{
        NSLog(@"正在验证密码...");
    }
    [_reconnectTimer setFireDate:[NSDate distantFuture]];
    _timerIsRunning = NO;
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    NSLog(@"连接超时");
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [self.stream sendElement:presence];
    NSLog(@"登录成功");
    
    [[NSNotificationCenter defaultCenter]postNotificationName:MyXmppDidLoginNotification object:nil];
    
    if (!_hasInit) {
        //roster初始化
        [self initRoster];
        
        //vcard初始化
        [self initVCard];
        
        //muc初始化，用于接受群邀请
        [self initmuc];
        
        _hasInit = YES;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [UIApplication sharedApplication].keyWindow.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"tablebar"];
    
//    [self creatGroupName:@"11111" withpassword:nil andsubject:@"11111"];
    
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
            [[NSNotificationCenter defaultCenter]postNotificationName:MyXmppUserStatusChangedNotification object:nil];
        }else if([presenceType isEqualToString:@"unavailable"]){
            NSLog(@"%@下线了",presenceFromUser);
        }
    }
}

#pragma mark - connect delegate
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    NSLog(@"DidDisconnect");
    NSLog(@"disconnet error:%@",error);
    [[NSNotificationCenter defaultCenter]postNotificationName:MyXmppConnectFailedNotification object:nil];
    if (!_timerIsRunning) {
        [_reconnectTimer setFireDate:[NSDate date]];
        _timerIsRunning = YES;
    }
    
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    NSLog(@"用户名或密码错误, %@", error);
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"name"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"password"];
    [[NSNotificationCenter defaultCenter]postNotificationName:MyXmppAuthenticateFailedNotification object:nil];
    [self disconnected];
}
@end
