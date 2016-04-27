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
#import "GroupMessage.h"
#import "MessageBean.h"
#import "MyFetchedResultsControllerDelegate.h"
#import "MessageCell.h"
#import "AudioCenter.h"
#import "Tool.h"
#import "BottomView.h"
#import "MoreView.h"
#import "MyXMPP.h"
#import "FriendChatingInfoViewController.h"

#define MOREHEIGHT 100
#define BOTTOMHEIGHT 40

static NSString *textReuseIdentifier = @"textMessageCell";
static NSString *audioReuseIdentifier = @"audioMessageCell";
static NSString *pictureReuseIdentifier = @"pictureMessageCell";

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, BottomViewDelegate> {
    NSString *_photoPath;
    BOOL _showMoreView;
    CGSize _screenSize;
    CGFloat _scrollOffset;//用于判断滚动的方向
}

@property (weak, nonatomic) IBOutlet UITableView *historyTableView;
@property (strong, nonatomic) BottomView *bottomView;
@property (strong, nonatomic) MoreView *moreView;

@property (strong, nonatomic) NSFetchedResultsController *historyController;
@property (strong, nonatomic) MyFetchedResultsControllerDelegate *historyControllerDelegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBottomHeight;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = back;
    
    // init table view
    _historyTableView.dataSource = self;
    _historyTableView.delegate = self;
    _historyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if ([self isP2PChat]) {
        _historyController = [[DataManager shareManager]getMessageByUsername:_chatObjectString];
    } else {
        _historyController = [[DataManager shareManager]getMessageByGroupname:_chatObjectString];
    }
    
    _historyControllerDelegate = [[MyFetchedResultsControllerDelegate alloc]initWithTableView:_historyTableView withScrolling:YES];
    _historyController.delegate = _historyControllerDelegate;
    
//    禁止选中tableView
    _historyTableView.allowsSelection = NO;
    
//    backgroundColor 设置为灰色
    _historyTableView.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
    // 注册cell
    [_historyTableView registerClass:[MessageViewCell class] forCellReuseIdentifier:textReuseIdentifier];
    [_historyTableView registerClass:[RecordViewCell class] forCellReuseIdentifier:audioReuseIdentifier];
    [_historyTableView registerClass:[PicViewCell class] forCellReuseIdentifier:pictureReuseIdentifier];
    
    _screenSize = [UIScreen mainScreen].bounds.size;
    // init bottom view
    _bottomView = [[NSBundle mainBundle]loadNibNamed:@"BottomView" owner:self options:nil].lastObject;
    _bottomView.frame = CGRectMake(0, _screenSize.height - BOTTOMHEIGHT, _screenSize.width, BOTTOMHEIGHT);
    _bottomView.chatObjectString = _chatObjectString;
    _bottomView.p2pChat = [self isP2PChat];
    _bottomView.delegate = self;
    [self.view addSubview:_bottomView];
    
    // init more view
    _showMoreView = NO;
    _moreView = [[NSBundle mainBundle]loadNibNamed:@"MoreView" owner:self options:nil].lastObject;
    _moreView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, MOREHEIGHT);
    _moreView.chatObjectString = _chatObjectString;
//    _moreView.p2pChat = [self isP2PChat];
    _moreView.p2pChat = YES;
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
    [self hideMoreView];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
    [[UIApplication sharedApplication].windows[0] addSubview:_bottomView];//bottom放在window上
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationEnteredBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:nil object:nil];
    [_bottomView resignFirstResponder];
    [_bottomView removeFromSuperview];
    [[DataManager shareManager]updateUsername:_chatObjectString];
}
- (IBAction)showChatingInfo:(id)sender {
    if (self.isP2PChat) {
        [self performSegueWithIdentifier:@"showFriendInfo" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"showGroupInfo" sender:nil];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showFriendInfo"]) {
        FriendChatingInfoViewController *infoVC = segue.destinationViewController;
        infoVC.friendName = _chatObjectString;
    } else if ([segue.identifier isEqualToString:@"showGroupInfo"]) {
        
    }
}

#pragma mark -table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = _historyController.sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *messageObj = [_historyController objectAtIndexPath:indexPath];
    MessageBean *message = nil;
    if (self.isP2PChat) {
        Message *p2pMessage = (Message *)messageObj;
        message = [[MessageBean alloc]initWithUsername:p2pMessage.username type:p2pMessage.type body:p2pMessage.body more:p2pMessage.more time:p2pMessage.time isOut:p2pMessage.isOut isP2P:YES];
    } else {
        GroupMessage *groupMessage = (GroupMessage *)messageObj;
        message = [[MessageBean alloc]initWithUsername:groupMessage.username type:groupMessage.type body:groupMessage.body more:groupMessage.more time:groupMessage.time isOut:nil isP2P:NO];
    }
    MessageType type = message.type.charValue;
    switch (type) {
        case MessageTypeMessage:{
            MessageViewCell *cell = [_historyTableView dequeueReusableCellWithIdentifier:textReuseIdentifier];
            
            if (cell == nil) {
                cell = [[MessageViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:textReuseIdentifier];
            }
            MessageFrameModel *messageFrameModel = [[MessageFrameModel alloc] init];
            messageFrameModel.message = message;
            cell.messageFrame = messageFrameModel;
            return cell;
        }
            
        case MessageTypeRecord:{
            RecordViewCell *cell = [_historyTableView dequeueReusableCellWithIdentifier:audioReuseIdentifier];
            
            if (cell == nil) {
                cell = [[RecordViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:audioReuseIdentifier];
            }
            RecordFrameModel *recordFrameMode = [[RecordFrameModel alloc] init];
            recordFrameMode.message = message;
            cell.recordFrame = recordFrameMode;
            return cell;
        }
            
        case MessageTypePicture:{
            PicViewCell *cell = [_historyTableView dequeueReusableCellWithIdentifier:pictureReuseIdentifier];
            
            if (cell == nil) {
                cell = [[PicViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:pictureReuseIdentifier];
            }
            
            PicFrameModel *messageFrameModel = [[PicFrameModel alloc] init];
            messageFrameModel.message = message;
            cell.picFrame = messageFrameModel;
            return cell;
        }
        
        default:
            break;
    }
    
    return nil;
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *messageObj = [_historyController objectAtIndexPath:indexPath];
    MessageBean *message = nil;
    if (self.isP2PChat) {
        Message *p2pMessage = (Message *)messageObj;
        message = [[MessageBean alloc]initWithUsername:p2pMessage.username type:p2pMessage.type body:p2pMessage.body more:p2pMessage.more time:p2pMessage.time isOut:p2pMessage.isOut isP2P:YES];
    } else {
        GroupMessage *groupMessage = (GroupMessage *)messageObj;
        message = [[MessageBean alloc]initWithUsername:groupMessage.username type:groupMessage.type body:groupMessage.body more:groupMessage.more time:groupMessage.time isOut:nil isP2P:NO];
    }
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
    [_bottomView resignTextfield];
}

#pragma mark -keyboard notification
- (void)keyboardWillShow:(NSNotification *)notification {
    CGFloat height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    _showMoreView = NO;
    _moreView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, MOREHEIGHT);
    _tableBottomHeight.constant = height;
    [UIView animateWithDuration:0.5 animations:^{
        _bottomView.frame = CGRectMake(0, _screenSize.height - height - BOTTOMHEIGHT, _screenSize.width, BOTTOMHEIGHT);
        [self.view layoutIfNeeded];
    }];
    
    [self tableViewScrollToBottom];
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    _tableBottomHeight.constant = BOTTOMHEIGHT;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
        _bottomView.frame = CGRectMake(0, _screenSize.height - BOTTOMHEIGHT, _screenSize.width, BOTTOMHEIGHT);
    }];
}

#pragma mark - application notifition
- (void)applicationEnteredBackground {
    [[DataManager shareManager]updateUsername:_chatObjectString];
}

#pragma mark - bottom delegate
- (void)showMoreView {
    if (_showMoreView) {
        _tableBottomHeight.constant = BOTTOMHEIGHT;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
            _bottomView.frame = CGRectMake(0, _screenSize.height - BOTTOMHEIGHT, _screenSize.width, BOTTOMHEIGHT);
            _moreView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, MOREHEIGHT);
        }];
    } else {
        _tableBottomHeight.constant = BOTTOMHEIGHT + MOREHEIGHT;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
            _bottomView.frame = CGRectMake(0, _screenSize.height - BOTTOMHEIGHT - MOREHEIGHT, _screenSize.width, BOTTOMHEIGHT);
            _moreView.frame = CGRectMake(0, _screenSize.height - MOREHEIGHT, _screenSize.width, MOREHEIGHT);
        }];
    }
    _showMoreView = !_showMoreView;
}

- (void)hideMoreView {
    if (_showMoreView) {
        _tableBottomHeight.constant = BOTTOMHEIGHT;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
            _bottomView.frame = CGRectMake(0, _screenSize.height - BOTTOMHEIGHT, _screenSize.width, BOTTOMHEIGHT);
            _moreView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, MOREHEIGHT);
        }];
    }
}

@end
