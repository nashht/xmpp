//
//  FriendCell.h
//  p2pChat
//
//  Created by nashht on 16/3/31.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendCell : UITableViewCell
//@property (strong,nonatomic) Friend *friend;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendStatusLabel;

- (void)setLable:(NSString *) name;

@end
