//
//  FriendChatingInfoViewController.m
//  p2pChat
//
//  Created by xiaokun on 16/4/24.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "FriendChatingInfoViewController.h"
#import "MyXMPP+VCard.h"

@interface FriendChatingInfoViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *friendPhotoBtn;
@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;

@end

@implementation FriendChatingInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XMPPvCardTemp *vCard = [[MyXMPP shareInstance]fetchFriend:[XMPPJID jidWithUser:_friendName domain:myDomain resource:nil]];
    [_friendPhotoBtn setImage:[UIImage imageWithData:vCard.photo] forState:UIControlStateNormal];
    _friendNameLabel.text = _friendName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createGroup:(id)sender {
    
}

@end
