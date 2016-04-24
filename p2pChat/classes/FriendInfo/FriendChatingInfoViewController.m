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
    UIImage *image = nil;
    if (vCard.photo != nil) {
        image = [UIImage imageWithData:vCard.photo];
    } else {
        image = [UIImage imageNamed:@"1"];
    }
    [_friendPhotoBtn setImage:image forState:UIControlStateNormal];
    _friendNameLabel.text = _friendName;
}

- (IBAction)createGroup:(id)sender {
    
}

@end
