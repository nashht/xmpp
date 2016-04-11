//
//  FriendCell.m
//  p2pChat
//
//  Created by nashht on 16/3/31.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "FriendCell.h"

@interface FriendCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLable;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *statusLable;

@end

@implementation FriendCell

- (void)setIcon:(NSString *)icon{
    self.iconView.image = [UIImage imageNamed:icon];
}

-(void)setLable:(NSString *)name{
    self.nameLable.text = name;
}

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
