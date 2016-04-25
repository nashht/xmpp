//
//  FriendCell.m
//  p2pChat
//
//  Created by nashht on 16/3/31.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "FriendCell.h"

@interface FriendCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;

@end

@implementation FriendCell

- (void)setIcon:(UIImage *)icon{
    self.iconView.image = icon;
}

-(void)setLabel:(NSString *)name{
    self.nameLabel.text = name;
}

- (void)setStatus:(NSString *)status{
    self.statusLabel.text = status;
}

- (void)setDepartment:(NSString *)department {
    self.departmentLabel.text = department;
}

- (void)awakeFromNib {
    // Initialization code
    [_iconView.layer setCornerRadius:10];
    _iconView.layer.masksToBounds = true;
    
}

#pragma mark - 绘制Cell分割线
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //上分割线，
//    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:198/255.0 green:198/255.0 blue:198/255.0 alpha:1].CGColor);
//    CGContextStrokeRect(context, CGRectMake(0, 0, rect.size.width, 1));
    
    //下分割线
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:198/255.0 green:198/255.0 blue:198/255.0 alpha:1].CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height, rect.size.width, 1));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
