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
#import "BottomView.h"
#import "MoreView.h"
#import "MyXMPP.h"

#define MOREHEIGHT 100
#define BOTTOMHEIGHT 40

#define MyMessageCell @"my message"
#define FriendMessageCell @"friend message"
#define MyRecordCell @"my record"
#define FriendRecordCell @"friend record"
#define MyPhotoCell @"my photo"
#define FriendPhotoCell @"friend photo"

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, BottomViewDelegate> {
    NSString *_photoPath;
    BOOL _showMoreView;
    BOOL _bottomPostion;
    CGSize _screenSize;
}

@property (weak, nonatomic) IBOutlet UITableView *historyTableView;
@property (strong, nonatomic) BottomView *bottomView;
@property (strong, nonatomic) MoreView *moreView;

@property (strong, nonatomic) NSFetchedResultsController *historyController;
@property (strong, nonatomic) MyFetchedResultsControllerDelegate *historyControllerDelegate;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // init table view
    _historyTableView.dataSource = self;
    _historyTableView.delegate = self;
    _historyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _historyController = [[DataManager shareManager]getMessageByUsername:_userJid.user];
    _historyControllerDelegate = [[MyFetchedResultsControllerDelegate alloc]initWithTableView:_historyTableView];
    _historyController.delegate = _historyControllerDelegate;
    
//    禁止选中tableView
    _historyTableView.allowsSelection = NO;
    
//    backgroundColor 设置为灰色
    _historyTableView.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
    
    _screenSize = [UIScreen mainScreen].bounds.size;
    // init bottom view
    _bottomView = [[NSBundle mainBundle]loadNibNamed:@"BottomView" owner:self options:nil].lastObject;
    _bottomView.frame = CGRectMake(0, _screenSize.height - BOTTOMHEIGHT, _screenSize.width, BOTTOMHEIGHT);
    _bottomView.username = _userJid.user;
    _bottomView.delegate = self;
    _bottomPostion = YES;
    [self.view addSubview:_bottomView];
    
    // init more view
    _showMoreView = NO;
    _moreView = [[NSBundle mainBundle]loadNibNamed:@"MoreView" owner:self options:nil].lastObject;
    _moreView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, MOREHEIGHT);
//    _moreView.username = _username;
    [self.view addSubview:_moreView];
    
    [self tableViewScrollToBottom];
    
    
    // 添加手势，使得触控tableView时候收回键盘
    UITapGestureRecognizer *tableViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentTableViewTouchInSide)];
    tableViewGesture.numberOfTapsRequired = 1;
    tableViewGesture.cancelsTouchesInView = NO;
    [_historyTableView addGestureRecognizer:tableViewGesture];
}

- (void)commentTableViewTouchInSide {
    [_bottomView resignTextfield];
    if (_showMoreView) {
        _showMoreView = NO;
        [self moveDownView:MOREHEIGHT];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:nil object:nil];
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

- (BOOL)moveUpView:(CGFloat)offset {//view是否需要往上弹
//    BOOL flag = _historyTableView.contentSize.height + offset +BOTTOMHEIGHT >= _historyTableView.frame.size.height;
//    if (flag) {
        [UIView animateWithDuration:0.5 animations:^{
            self.view.frame = CGRectMake(0, -offset, _screenSize.width, _screenSize.height);
        }];
//    }
    return YES;
}

- (void)moveDownView:(CGFloat)height {
    if (_historyTableView.contentSize.height + height + BOTTOMHEIGHT >=  _historyTableView.frame.size.height) {
        [UIView animateWithDuration:0.5 animations:^{
            self.view.frame = CGRectMake(0, 0, _screenSize.width, _screenSize.height);
        }];
    }
}

#pragma mark -keyboard notification
- (void)keyboardWillShow:(NSNotification *)notification {
    CGFloat height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    [self moveUpView:height];
    [self tableViewScrollToBottom];
    if (_historyTableView.contentSize.height + height +BOTTOMHEIGHT <= _historyTableView.frame.size.height) {
        _bottomPostion = NO;
        [UIView animateWithDuration:0.5 animations:^{
//            _bottomView.frame = CGRectMake(0, _screenSize.height - height - BOTTOMHEIGHT, _screenSize.width, BOTTOMHEIGHT);
        }];
    }
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    CGFloat height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    if (!_bottomPostion) {
        [UIView animateWithDuration:0.5 animations:^{
            _bottomView.frame = CGRectMake(0, _screenSize.height - BOTTOMHEIGHT, _screenSize.width, BOTTOMHEIGHT);
        }];
    } else {
        [self moveDownView:height];
    }
}

#pragma mark - bottom delegate
- (void)showMoreView {
    if (_showMoreView) {
        [self moveDownView:MOREHEIGHT];
    } else {
        [self moveUpView:MOREHEIGHT];
    }
    _showMoreView = !_showMoreView;
}

- (void)hideMoreView {
    if (_showMoreView) {
        [self moveDownView:MOREHEIGHT];
    }
}

@end
