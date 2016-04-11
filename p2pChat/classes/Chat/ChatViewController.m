//
//  ChatViewController.m
//  p2pChat
//
//  Created by xiaokun on 16/1/4.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "ChatViewController.h"
#import "MessageFrameModel.h"
#import "RecordFrameModel.h"
#import "RecordViewCell.h"
#import "PicFrameModel.h"
#import "PicViewCell.h"
#import "MessageViewCell.h"
#import "DataManager.h"
#import "Message.h"
#import "MyFetchedResultsControllerDelegate.h"
#import "MessageCell.h"
#import "AudioCenter.h"
#import "Tool.h"
#import "RecordView.h"
#import "MoreView.h"
#import "MyXmpp.h"

#define VIEWHEIGHT 100

#define MyMessageCell @"my message"
#define FriendMessageCell @"friend message"
#define MyRecordCell @"my record"
#define FriendRecordCell @"friend record"
#define MyPhotoCell @"my photo"
#define FriendPhotoCell @"friend photo"

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    NSString *_photoPath;
    BOOL _showRecordView;
    BOOL _showMoreView;
    CGSize _screenSize;
//    NSString *_username;
}

@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *baseBottomConstraint;
@property (weak, nonatomic) IBOutlet UITextField *messageTF;
@property (weak, nonatomic) IBOutlet UITableView *historyTableView;

@property (strong, nonatomic) RecordView *recordView;
@property (strong, nonatomic) MoreView *moreView;

@property (strong, nonatomic) NSFetchedResultsController *historyController;
@property (strong, nonatomic) MyFetchedResultsControllerDelegate *historyControllerDelegate;

@property (strong, nonatomic) NSString *myPhotoPath;
@property (strong, nonatomic) MyXMPP *myXmpp;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _myXmpp = [MyXMPP shareInstance];
    // init table view
    _historyTableView.dataSource = self;
    _historyTableView.delegate = self;
    _historyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _historyController = [[DataManager shareManager]getMessageByUsername:_userJid.user];
    _historyControllerDelegate = [[MyFetchedResultsControllerDelegate alloc]initWithTableView:_historyTableView];
    _historyController.delegate = _historyControllerDelegate;

    // init text field
    _messageTF.delegate = self;
    
//    禁止选中tableView
    _historyTableView.allowsSelection = NO;
    
//    backgroundColor 设置为灰色
    _historyTableView.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
    
    _myPhotoPath = [[NSUserDefaults standardUserDefaults]stringForKey:@"photoPath"];

    // init record view
    _screenSize = [UIScreen mainScreen].bounds.size;
    _showRecordView = NO;
    _recordView = [[NSBundle mainBundle]loadNibNamed:@"RecordView" owner:self options:nil].lastObject;
    _recordView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, VIEWHEIGHT);
    _recordView.username = _userJid.user;
    [self.view addSubview:_recordView];
    
    // init more view
    _showMoreView = NO;
    _moreView = [[NSBundle mainBundle]loadNibNamed:@"MoreView" owner:self options:nil].lastObject;
    _moreView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, VIEWHEIGHT);
//    _moreView.username = _username;
    [self.view addSubview:_moreView];
    
    [self tableViewScrollToBottom];
    
    
    // 添加手势，使得触控tableView时候收回键盘
    UITapGestureRecognizer *tableViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentTableViewTouchInSide)];
    tableViewGesture.numberOfTapsRequired = 1;
    tableViewGesture.cancelsTouchesInView = NO;
    [_historyTableView addGestureRecognizer:tableViewGesture];
}

- (void)commentTableViewTouchInSide{
    [_messageTF resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:nil object:nil];
}

#pragma mark - IB actions
- (IBAction)record:(id)sender {
    [_messageTF resignFirstResponder];
    if (_showMoreView) {
        _baseBottomConstraint.constant = 0;
        [UIView animateWithDuration:0.5 animations:^{
            _moreView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, VIEWHEIGHT);
            [self.view layoutIfNeeded];
        }];
        _showMoreView = NO;
    }
    if (_showRecordView) {
        _baseBottomConstraint.constant = 0;
        [UIView animateWithDuration:0.5 animations:^{
            _recordView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, VIEWHEIGHT);
            [self.view layoutIfNeeded];
        }];
        _showRecordView = NO;
    } else {
        _baseBottomConstraint.constant = VIEWHEIGHT * -1;
        [UIView animateWithDuration:0.5 animations:^{
            _recordView.frame = CGRectMake(0, _screenSize.height - VIEWHEIGHT, _screenSize.width, VIEWHEIGHT);
            [self.view layoutIfNeeded];
        }];
        _showRecordView = YES;
    }
}

- (IBAction)send:(id)sender {
    NSString *message = _messageTF.text;
    if (![message isEqualToString:@""]) {
        _messageTF.text = @"";
        [_myXmpp sendMessage:message ToUser:_userJid.user];
    }
}

- (IBAction)more:(id)sender {
    [_messageTF resignFirstResponder];
    if (_showRecordView) {
        _baseBottomConstraint.constant = 0;
        [UIView animateWithDuration:0.5 animations:^{
            _recordView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, VIEWHEIGHT);
            [self.view layoutIfNeeded];
        }];
        _showRecordView = NO;
    }
    if (_showMoreView) {
        _baseBottomConstraint.constant = 0;
        [UIView animateWithDuration:0.5 animations:^{
            _moreView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, VIEWHEIGHT);
            [self.view layoutIfNeeded];
        }];
        _showMoreView = NO;
    } else {
        _baseBottomConstraint.constant = VIEWHEIGHT * -1;
        [UIView animateWithDuration:0.5 animations:^{
            _moreView.frame = CGRectMake(0, _screenSize.height - VIEWHEIGHT, _screenSize.width, VIEWHEIGHT);
            [self.view layoutIfNeeded];
        }];
        _showMoreView = YES;
    }
}

/**
 *  tableView自动显示最后一行
 */
- (void)tableViewScrollToBottom{
    
    NSUInteger sectionCount = [_historyTableView numberOfSections];
    if (sectionCount) {
        
        NSUInteger rowCount = [_historyTableView numberOfRowsInSection:0];
        if (rowCount) {
            
            NSUInteger ii[2] = {0, rowCount - 1};
            NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
            [_historyTableView scrollToRowAtIndexPath:indexPath
                                     atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}

#pragma mark -table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = _historyController.sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Message *message = [_historyController objectAtIndexPath:indexPath];
    MessageType type = message.type.charValue;
    switch (type) {
        case MessageTypeMessage:{
            static NSString *reuseIdentifier = @"messageCell";
            MessageViewCell *cell = [_historyTableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            
            if (cell == nil) {
                cell = [[MessageViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
            }
            MessageFrameModel *messageFrameModel = [[MessageFrameModel alloc] init];
            messageFrameModel.message = message;
            cell.messageFrame = messageFrameModel;
            return cell;
        }
        case MessageTypePicture:{
            static NSString *reuseIdentifier = @"picCell";
            PicViewCell *cell = [_historyTableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            
            if (cell == nil) {
                cell = [[PicViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
            }
            PicFrameModel *messageFrameModel = [[PicFrameModel alloc] init];
            messageFrameModel.message = message;
            cell.picFrame = messageFrameModel;
            return cell;
        }
        case MessageTypeRecord:{
            static NSString *reuseIdentifier = @"recordCell";
            RecordViewCell *cell = [_historyTableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            if (cell == nil) {
                cell = [[RecordViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
            }
            RecordFrameModel *recordFrameMode = [[RecordFrameModel alloc] init];
            recordFrameMode.message = message;
            cell.recordFrame = recordFrameMode;
            return cell;
        }
        default:
            break;
    }
    return nil;
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Message *message = [_historyController objectAtIndexPath:indexPath];
    
    MessageType type = message.type.charValue;
    switch (type) {
        case MessageTypeMessage:{
            MessageFrameModel *messageFrameModel = [[MessageFrameModel alloc] init];
            messageFrameModel.message = message;
            return messageFrameModel.cellHeight + 1;
        }
            break;
        case MessageTypePicture:{
            PicFrameModel *picFrameModel = [[PicFrameModel alloc] init];
            picFrameModel.message = message;
            return picFrameModel.cellHeight + 1;
        }
            break;
        case MessageTypeRecord:{
            RecordFrameModel *recordFrameMode = [[RecordFrameModel alloc] init];
            recordFrameMode.message = message;
            return recordFrameMode.cellHeight + 1;
        }
            break;
         default:
            break;
    }
    return 0;
}

/**
 *  滑动收回键盘
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark -keyboard notification
- (void)keyboardWillShow:(NSNotification *)notification {
    if (_showMoreView) {
        _baseBottomConstraint.constant = 0;
        [UIView animateWithDuration:0.5 animations:^{
            _moreView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, VIEWHEIGHT);
            [self.view layoutIfNeeded];
        }];
        _showMoreView = NO;
    }

    if (_showRecordView) {
        _baseBottomConstraint.constant = 0;
        [UIView animateWithDuration:0.5 animations:^{
            _recordView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, VIEWHEIGHT);
            [self.view layoutIfNeeded];
        }];
        _showRecordView = NO;
    }

    CGFloat height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - height, self.view.frame.size.width, self.view.frame.size.height);
    }];
    
//    //设置动画的名字
//    [UIView beginAnimations:@"Animation" context:nil];
//    //设置动画的间隔时间
//    [UIView setAnimationDuration:0.20];
//    //使用当前正在运行的状态开始下一段动画
//    [UIView setAnimationBeginsFromCurrentState: YES];
//    //设置视图移动的位移
//    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - height, self.view.frame.size.width, self.view.frame.size.height);
//    //设置动画结束
//    [UIView commitAnimations];
    
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    _baseBottomConstraint.constant = 0;
    
    CGFloat height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + height, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

#pragma mark -text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
//    点击send发送消息
    [self send:nil];
    
    return YES;
}

@end
