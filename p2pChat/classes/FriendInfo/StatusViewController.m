//
//  StatusViewController.m
//  XMPP
//
//  Created by xiaokun on 16/6/7.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "StatusViewController.h"
#import "MyXMPP.h"
#import "DataManager.h"

@interface StatusViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *onlineCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *busyCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *offlineCell;
@property (strong, nonatomic) UITableViewCell *currentCell;

@property (strong, nonatomic) MyXMPP *xmpp;
@property (assign, nonatomic) MyXMPPStatus status;

@end

@implementation StatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _xmpp = [MyXMPP shareInstance];
    _status = [_xmpp myStatus];
    switch (_status) {
        case MyXMPPStatusOnline:
            _onlineCell.accessoryType = UITableViewCellAccessoryCheckmark;
            _currentCell = _onlineCell;
            break;
        case MyXMPPStatusBusy:
            _busyCell.accessoryType = UITableViewCellAccessoryCheckmark;
            _currentCell = _busyCell;
            break;
        case MyXMPPStatusOffline:
            _offlineCell.accessoryType = UITableViewCellAccessoryCheckmark;
            _currentCell = _offlineCell;
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 3 : 1;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger section = indexPath.section;
    DataManager *dataManager = [DataManager shareManager];
    switch (section) {
        case 0://状态
            switch (indexPath.row) {
                case 0://在线
                    if (_status != MyXMPPStatusOnline) {
                        [_xmpp online];
                        _onlineCell.accessoryType = UITableViewCellAccessoryCheckmark;
                        _currentCell.accessoryType = UITableViewCellAccessoryNone;
                        _currentCell = _onlineCell;
                        _status = MyXMPPStatusOnline;
                    }
                    break;
                case 1://忙碌
                    if (_status != MyXMPPStatusBusy) {
                        [_xmpp busy];
                        _busyCell.accessoryType = UITableViewCellAccessoryCheckmark;
                        _currentCell.accessoryType = UITableViewCellAccessoryNone;
                        _currentCell = _busyCell;
                        _status = MyXMPPStatusBusy;
                    }
                    break;
                case 2://离开
                    if (_status != MyXMPPStatusOffline) {
                        [_xmpp offline];
                        _offlineCell.accessoryType = UITableViewCellAccessoryCheckmark;
                        _currentCell.accessoryType = UITableViewCellAccessoryNone;
                        _currentCell = _offlineCell;
                        _status = MyXMPPStatusOffline;
                    }
                    break;
                default:
                    break;
            }
            break;
        case 1:
            
            break;
        default:
            break;
    }
}

@end
