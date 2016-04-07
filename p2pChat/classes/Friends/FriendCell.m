//
//  FriendCell.m
//  p2pChat
//
//  Created by nashht on 16/3/31.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "FriendCell.h"

@interface FriendCell ()

@end

@implementation FriendCell





- (void)awakeFromNib {
    // Initialization code
    [_iconView.layer setCornerRadius:CGRectGetHeight([_iconView bounds])/2];
    _iconView.layer.masksToBounds = true;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
