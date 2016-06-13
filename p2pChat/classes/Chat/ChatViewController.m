//
//  ChatViewController.m
//  p2pChat
//
//  Created by xiaokun on 16/1/4.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "UIViewController+BackButtonHandler.h"
#import "ChatViewController.h"
#import "DataManager.h"
#import "Message.h"
#import "GroupMessage.h"
#import "MessageBean.h"
#import "MyFetchedResultsControllerDelegate.h"
#import "AudioCenter.h"
#import "Tool.h"
#import "BottomView.h"
#import "MoreView.h"
#import "MyXMPP.h"
#import "FriendChatingInfoViewController.h"
#import "GroupMembersInfoTableViewController.h"
#import "FaceView.h"
#import "FunctionView.h"
#import "UITableView+GenerateMyXMPPCell.h"

#define MOREHEIGHT 150
#define ScreenSize  [UIScreen mainScreen].bounds.size
#define BOTTOMHEIGHT 40
#define FACEVIEWHEIGHT (ScreenSize.height * 0.353)

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, BackButtonHandlerProtocol,BottomViewDelegate> {
    NSString *_photoPath;
    BOOL _showMoreView;
    BOOL _showFaceView;
    CGSize _screenSize;
    CGFloat _scrollOffset;//用于判断滚动的方向
    CGFloat _tabBarHeight;
}

@property (weak, nonatomic) IBOutlet UITableView *historyTableView;
@property (strong, nonatomic) BottomView *bottomView;
@property (strong, nonatomic) MoreView *moreView;
@property (nonatomic, strong) FunctionView *functionView;

@property (strong, nonatomic) NSFetchedResultsController *historyController;
@property (strong, nonatomic) MyFetchedResultsControllerDelegate *historyControllerDelegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBottomHeight;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _chatObjectString;
    _tabBarHeight = self.tabBarController.tabBar.frame.size.height;
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
    _tableBottomHeight.constant = BOTTOMHEIGHT - _tabBarHeight;
    [self.view addSubview:_bottomView];

    // 添加手势，使得触控tableView时候收回键盘
    UITapGestureRecognizer *tableViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentTableViewTouchInSide)];
    tableViewGesture.numberOfTapsRequired = 1;
    tableViewGesture.cancelsTouchesInView = NO;
    [_historyTableView addGestureRecognizer:tableViewGesture];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // init more view
        _showMoreView = NO;
        _moreView = [[NSBundle mainBundle]loadNibNamed:@"MoreView" owner:self options:nil].lastObject;
        _moreView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, MOREHEIGHT);
        _moreView.chatObjectString = _chatObjectString;
        //    _moreView.p2pChat = [self isP2PChat];
        _moreView.p2pChat = YES;
        [self.view addSubview:_moreView];
        
        // init face view
        self.functionView = [[FunctionView alloc] initWithFrame:CGRectMake(0,_screenSize.height, [UIScreen mainScreen].bounds.size.width, FACEVIEWHEIGHT)];
        self.functionView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_functionView];
        _showFaceView = NO;
        //获取图片并显示
        __weak typeof (self) weakSelf = self;
        [self.functionView setFunctionBlock:^(UIImage *image, NSString *imageName)
         {
             NSString *str = [NSString stringWithFormat:@"%@", imageName];
             [weakSelf.bottomView inputFaceView:str];
         }];
    });

    [self tableViewScrollToBottom];
}

- (void)commentTableViewTouchInSide {
    [_bottomView resignTextfield];
    [self hideMoreView];
    [self hideFaceView];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationEnteredBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:nil object:nil];
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
                                     atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
}

- (void)backToRecent{
    self.tabBarController.selectedIndex = 0;
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showFriendInfo"]) {
        FriendChatingInfoViewController *infoVC = segue.destinationViewController;
        infoVC.friendName = _chatObjectString;
    } else if ([segue.identifier isEqualToString:@"showGroupInfo"]) {
        GroupMembersInfoTableViewController *infoVC = segue.destinationViewController;
        infoVC.groupName = _chatObjectString;
    }
}

- (MessageBean *)messageFromManagedObject:(NSManagedObject *)messageObj {
    MessageBean *message = nil;
    if (self.isP2PChat) {
        Message *p2pMessage = (Message *)messageObj;
        message = [[MessageBean alloc]initWithUsername:p2pMessage.username type:p2pMessage.type body:p2pMessage.body more:p2pMessage.more time:p2pMessage.time isOut:p2pMessage.isOut isP2P:YES];
    } else {
        GroupMessage *groupMessage = (GroupMessage *)messageObj;
        message = [[MessageBean alloc]initWithUsername:groupMessage.username type:groupMessage.type body:groupMessage.body more:groupMessage.more time:groupMessage.time isOut:nil isP2P:NO];
    }
    return message;
}

#pragma mark -table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = _historyController.sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *messageObj = [_historyController objectAtIndexPath:indexPath];
    MessageBean *message = [self messageFromManagedObject:messageObj];
    
    return [tableView dequeueMyXMPPCellFromMessage:message];
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *messageObj = [_historyController objectAtIndexPath:indexPath];
    MessageBean *message = [self messageFromManagedObject:messageObj];

    return [tableView heightOfMessage:message];
}

/**
 *  滑动收回键盘
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_bottomView resignTextfield];
}

#pragma mark - keyboard notification
- (void)keyboardWillShow:(NSNotification *)notification {
    CGFloat height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    _showMoreView = NO;
    _showFaceView = NO;
    _moreView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, MOREHEIGHT);
    _functionView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, FACEVIEWHEIGHT);
    _tableBottomHeight.constant = height + BOTTOMHEIGHT - _tabBarHeight;
    [UIView animateWithDuration:0.5 animations:^{
        _bottomView.frame = CGRectMake(0, _screenSize.height - height - BOTTOMHEIGHT, _screenSize.width, BOTTOMHEIGHT);
        [self.view layoutIfNeeded];
    }];
    
    [self tableViewScrollToBottom];
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    _tableBottomHeight.constant = BOTTOMHEIGHT - _tabBarHeight;
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
        [self hideMoreView];
    } else {
        _tableBottomHeight.constant = BOTTOMHEIGHT + MOREHEIGHT -_tabBarHeight;
        [UIView animateWithDuration:0.2 animations:^{
                    [self hideFaceView];
            [self.view layoutIfNeeded];
            [self tableViewScrollToBottom];
            _bottomView.frame = CGRectMake(0, _screenSize.height - BOTTOMHEIGHT - MOREHEIGHT, _screenSize.width, BOTTOMHEIGHT);
            _moreView.frame = CGRectMake(0, _screenSize.height - MOREHEIGHT, _screenSize.width, MOREHEIGHT);
        }];
        _showMoreView = YES;
    }
}

- (void)hideMoreView {
    if (_showMoreView) {
        _tableBottomHeight.constant = BOTTOMHEIGHT - _tabBarHeight;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
            [self tableViewScrollToBottom];
            _bottomView.frame = CGRectMake(0, _screenSize.height - BOTTOMHEIGHT, _screenSize.width, BOTTOMHEIGHT);
            _moreView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, MOREHEIGHT);
        }];
        _showMoreView = NO;
    }
}

- (void)showFaceView {
    if (_showFaceView) {
        [self hideFaceView];
    } else {
        [self hideMoreView];
        _tableBottomHeight.constant = BOTTOMHEIGHT + FACEVIEWHEIGHT -_tabBarHeight;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
            [self tableViewScrollToBottom];
            _bottomView.frame = CGRectMake(0, _screenSize.height - BOTTOMHEIGHT - FACEVIEWHEIGHT, _screenSize.width, BOTTOMHEIGHT);
            _functionView.frame = CGRectMake(0, _screenSize.height - FACEVIEWHEIGHT, _screenSize.width, FACEVIEWHEIGHT);
        }];
        _showFaceView = YES;
    }
}

- (void)hideFaceView {
    if (_showFaceView) {
        _tableBottomHeight.constant = BOTTOMHEIGHT - _tabBarHeight;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
            [self tableViewScrollToBottom];
            _bottomView.frame = CGRectMake(0, _screenSize.height - BOTTOMHEIGHT, _screenSize.width, BOTTOMHEIGHT);
            _functionView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, FACEVIEWHEIGHT);
        }];
    _showFaceView = NO;
    }
}

- (BOOL)navigationShouldPopOnBackButton{
    [self backToRecent];
    return YES;
}
@end
