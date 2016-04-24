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
#import "objc/runtime.h"

#define MOREHEIGHT 100
#define BOTTOMHEIGHT 40

static NSString *textReuseIdentifier = @"textMessageCell";
static NSString *audioReuseIdentifier = @"audioMessageCell";
static NSString *pictureReuseIdentifier = @"pictureMessageCell";

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, BottomViewDelegate> {
    NSString *_photoPath;
    BOOL _showMoreView;
    CGSize _screenSize;
    CGFloat _keyboardHeight;//底下弹出的高度，不只是键盘
}

@property (weak, nonatomic) IBOutlet UITableView *historyTableView;
@property (strong, nonatomic) BottomView *bottomView;
@property (strong, nonatomic) MoreView *moreView;

@property (strong, nonatomic) NSFetchedResultsController *historyController;
@property (strong, nonatomic) MyFetchedResultsControllerDelegate *historyControllerDelegate;

@property (assign, nonatomic) CGFloat tableViewHeight;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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
    _keyboardHeight = 0;
    // init bottom view
    _bottomView = [[NSBundle mainBundle]loadNibNamed:@"BottomView" owner:self options:nil].lastObject;
    _bottomView.frame = CGRectMake(0, _screenSize.height - BOTTOMHEIGHT, _screenSize.width, BOTTOMHEIGHT);
    _bottomView.chatObjectString = _chatObjectString;
    _bottomView.p2pChat = [self isP2PChat];
    _bottomView.delegate = self;
    [[UIApplication sharedApplication].windows[0] addSubview:_bottomView];//bottom放在window上
    
    // init more view
    _showMoreView = NO;
    _moreView = [[NSBundle mainBundle]loadNibNamed:@"MoreView" owner:self options:nil].lastObject;
    _moreView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, MOREHEIGHT);
    _moreView.chatObjectString = _chatObjectString;
    _moreView.p2pChat = [self isP2PChat];
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
        [self hideMoreView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    if (_historyTableView.contentSize.height < _screenSize.height) {
        [self addObserver:self forKeyPath:@"tableViewHeight" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:nil object:nil];
    [_bottomView resignFirstResponder];
    [_bottomView removeFromSuperview];
    @try {
        [self removeObserver:self forKeyPath:@"tableViewHeight"];
    }
    @catch (NSException *exception) {
        
    };
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
    self.tableViewHeight = _historyTableView.contentSize.height + 150;
    NSManagedObject *messageObj = [_historyController objectAtIndexPath:indexPath];
    MessageBean *message = nil;
    if (self.isP2PChat) {
        Message *p2pMessage = (Message *)messageObj;
        message = [[MessageBean alloc]initWithUsername:p2pMessage.username type:p2pMessage.type body:p2pMessage.body time:p2pMessage.time isOut:p2pMessage.isOut isP2P:YES];
    } else {
        GroupMessage *groupMessage = (GroupMessage *)messageObj;
        message = [[MessageBean alloc]initWithUsername:groupMessage.username type:groupMessage.type body:groupMessage.body time:groupMessage.time isOut:nil isP2P:NO];
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
        case MessageTypePicture:{
            PicViewCell *cell = [_historyTableView dequeueReusableCellWithIdentifier:pictureReuseIdentifier];
            
            if (cell == nil) {
                cell = [[PicViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:pictureReuseIdentifier];
            }
            PicFrameModel *messageFrameModel = [[PicFrameModel alloc] init];
//            messageFrameModel.message = message;
            cell.picFrame = messageFrameModel;
            return cell;
        }
        case MessageTypeRecord:{
            RecordViewCell *cell = [_historyTableView dequeueReusableCellWithIdentifier:audioReuseIdentifier];
            
            if (cell == nil) {
                cell = [[RecordViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:audioReuseIdentifier];
            }
            RecordFrameModel *recordFrameMode = [[RecordFrameModel alloc] init];
//            recordFrameMode.message = message;
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
    NSManagedObject *messageObj = [_historyController objectAtIndexPath:indexPath];
    MessageBean *message = nil;
    if (self.isP2PChat) {
        Message *p2pMessage = (Message *)messageObj;
        message = [[MessageBean alloc]initWithUsername:p2pMessage.username type:p2pMessage.type body:p2pMessage.body time:p2pMessage.time isOut:p2pMessage.isOut isP2P:YES];
    } else {
        GroupMessage *groupMessage = (GroupMessage *)messageObj;
        message = [[MessageBean alloc]initWithUsername:groupMessage.username type:groupMessage.type body:groupMessage.body time:groupMessage.time isOut:nil isP2P:NO];
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
//            picFrameModel.message = message;
            return picFrameModel.cellHeight + 1;
        }
            break;
        case MessageTypeRecord:{
            RecordFrameModel *recordFrameMode = [[RecordFrameModel alloc] init];
//            recordFrameMode.message = message;
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
    CGFloat height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    _keyboardHeight = height;
    _showMoreView = NO;
    _moreView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, MOREHEIGHT);
    if (_historyTableView.contentSize.height + 100 > _screenSize.height) {//内容已经很多，view全部上移即可
        [UIView animateWithDuration:0.5 animations:^{
            self.view.frame = CGRectMake(0, -(height + BOTTOMHEIGHT), _screenSize.width, _screenSize.height);
            _bottomView.frame = CGRectMake(0, _screenSize.height - height - BOTTOMHEIGHT, _screenSize.width, BOTTOMHEIGHT);
        }];
    } else if (_historyTableView.contentSize.height + height + BOTTOMHEIGHT + 100 > _screenSize.height) {//内容不是很多，view只需移动一点
        [UIView animateWithDuration:0.5 animations:^{
            self.view.frame = CGRectMake(0, _screenSize.height - height - BOTTOMHEIGHT - _historyTableView.contentSize.height - 100, _screenSize.width, _screenSize.height);
            _bottomView.frame = CGRectMake(0, _screenSize.height - height - BOTTOMHEIGHT, _screenSize.width, BOTTOMHEIGHT);
        }];
    } else {//内容很少，view不用上移
        [UIView animateWithDuration:0.5 animations:^{
            _bottomView.frame = CGRectMake(0, _screenSize.height - height - BOTTOMHEIGHT, _screenSize.width, BOTTOMHEIGHT);
        }];
    }
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    _keyboardHeight = 0;
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame = CGRectMake(0, 0, _screenSize.width, _screenSize.height);
        _bottomView.frame = CGRectMake(0, _screenSize.height - BOTTOMHEIGHT, _screenSize.width, BOTTOMHEIGHT);
    }];
}

#pragma mark - bottom delegate
- (void)showMoreView {
    if (_showMoreView) {
        _keyboardHeight = 0;
        [UIView animateWithDuration:0.5 animations:^{
            self.view.frame = CGRectMake(0, 0, _screenSize.width, _screenSize.height);
            _bottomView.frame = CGRectMake(0, _screenSize.height - BOTTOMHEIGHT, _screenSize.width, BOTTOMHEIGHT);
            _moreView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, MOREHEIGHT);
        }];
    } else {
        _keyboardHeight = MOREHEIGHT;
        if (_historyTableView.contentSize.height + 100 > _screenSize.height) {
            [UIView animateWithDuration:0.5 animations:^{
                self.view.frame = CGRectMake(0, -MOREHEIGHT, _screenSize.width, _screenSize.height);
                _bottomView.frame = CGRectMake(0, _screenSize.height - MOREHEIGHT - BOTTOMHEIGHT, _screenSize.width, BOTTOMHEIGHT);
            }];
        } else if (_historyTableView.contentSize.height + MOREHEIGHT + BOTTOMHEIGHT + 100 > _screenSize.height) {
            [UIView animateWithDuration:0.5 animations:^{
                self.view.frame = CGRectMake(0, _screenSize.height - MOREHEIGHT - BOTTOMHEIGHT - _historyTableView.contentSize.height - 100, _screenSize.width, _screenSize.height);
                _bottomView.frame = CGRectMake(0, _screenSize.height - MOREHEIGHT, _screenSize.width, BOTTOMHEIGHT);
            }];
        } else {
            [UIView animateWithDuration:0.5 animations:^{
                _bottomView.frame = CGRectMake(0, _screenSize.height - MOREHEIGHT - BOTTOMHEIGHT, _screenSize.width, BOTTOMHEIGHT);
                _moreView.frame = CGRectMake(0, _screenSize.height - MOREHEIGHT, _screenSize.width, MOREHEIGHT);
            }];
        }
    }
    _showMoreView = !_showMoreView;
}

- (void)hideMoreView {
    if (_showMoreView) {
        [UIView animateWithDuration:0.5 animations:^{
            self.view.frame = CGRectMake(0, 0, _screenSize.width, _screenSize.height);
            _bottomView.frame = CGRectMake(0, _screenSize.height - BOTTOMHEIGHT, _screenSize.width, BOTTOMHEIGHT);
            _moreView.frame = CGRectMake(0, _screenSize.height, _screenSize.width, MOREHEIGHT);
        }];
    }
}

#pragma mark - kvo
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"tableViewHeight"]) {
        NSNumber *new = change[@"new"];
        if (new.doubleValue > _screenSize.height - _keyboardHeight - 100 && new.doubleValue < _screenSize.height - 100) {
            [UIView animateWithDuration:0.2 animations:^{
                self.view.frame = CGRectMake(0, -1 * (_keyboardHeight + new.doubleValue - _screenSize.height + 100), _screenSize.width, _screenSize.height);
            }];
        }
        if (new.doubleValue + 100 >= _screenSize.height) {
            [UIView animateWithDuration:0.2 animations:^{
                self.view.frame = CGRectMake(0, -_keyboardHeight, _screenSize.width, _screenSize.height);
            }];
            @try {
                [self removeObserver:self forKeyPath:@"tableViewHeight"];
            }
            @catch (NSException *exception) {
                
            };
        }
    }
}

@end
