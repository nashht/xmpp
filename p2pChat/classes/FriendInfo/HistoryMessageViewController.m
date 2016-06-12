//
//  HistoryMessageViewController.m
//  XMPP
//
//  Created by xiaokun on 16/6/11.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "HistoryMessageViewController.h"
#import "DataManager.h"
#import "UITableView+GenerateMyXMPPCell.h"
#import "MessageBean.h"
#import "Message.h"
#import "GroupMessage.h"

@interface HistoryMessageViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *historyTableView;
@property (strong, nonatomic) NSFetchedResultsController *messages;

@end

@implementation HistoryMessageViewController

- (void)viewDidLoad {
    _historyTableView.delegate = self;
    _historyTableView.dataSource = self;
    UIBarButtonItem *clearItem = [[UIBarButtonItem alloc]initWithTitle:@"删除聊天记录" style:UIBarButtonItemStylePlain target:self action:@selector(alertClear)];
    self.navigationItem.rightBarButtonItem = clearItem;
    [self initMessages];
}

- (void)initMessages {
    if (_isP2P) {
        _messages = [[DataManager shareManager]getMessageByUsername:_chatObjName];
    } else {
        _messages = [[DataManager shareManager]getMessageByGroupname:_chatObjName];
    }
}

- (MessageBean *)messageFromManagedObject:(NSManagedObject *)messageObj {
    MessageBean *message = nil;
    if (self.isP2P) {
        Message *p2pMessage = (Message *)messageObj;
        message = [[MessageBean alloc]initWithUsername:p2pMessage.username type:p2pMessage.type body:p2pMessage.body more:p2pMessage.more time:p2pMessage.time isOut:p2pMessage.isOut isP2P:YES];
    } else {
        GroupMessage *groupMessage = (GroupMessage *)messageObj;
        message = [[MessageBean alloc]initWithUsername:groupMessage.username type:groupMessage.type body:groupMessage.body more:groupMessage.more time:groupMessage.time isOut:nil isP2P:NO];
    }
    return message;
}

- (void)alertClear {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认删除" message:@"将删除该好友的所有记录" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (_isP2P) {
            [[DataManager shareManager]clearMessageByUsername:_chatObjName];
            [[DataManager shareManager]deleteRecentUsername:_chatObjName isP2P:YES];
        } else {
            [[DataManager shareManager]clearMessageByGroupname:_chatObjName];
            [[DataManager shareManager]deleteRecentUsername:_chatObjName isP2P:NO];
        }
        [self initMessages];
        [_historyTableView reloadData];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = _messages.sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *messageObj = [_messages objectAtIndexPath:indexPath];
    MessageBean *message = [self messageFromManagedObject:messageObj];
    
    return [tableView dequeueMyXMPPCellFromMessage:message];
}

#pragma mark - delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *messageObj = [_messages objectAtIndexPath:indexPath];
    MessageBean *message = [self messageFromManagedObject:messageObj];
    
    return [tableView heightOfMessage:message];
}

@end
