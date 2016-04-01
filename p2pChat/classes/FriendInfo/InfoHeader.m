//
//  InfoHeader.m
//  p2pChat
//
//  Created by nashht on 16/3/31.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "InfoHeader.h"

@implementation InfoHeader

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (instancetype)headerViewWithName:(NSString *)name{
    
    InfoHeader *header = [[[NSBundle mainBundle] loadNibNamed:@"InfoHeader" owner:nil options:nil] firstObject];
    header.nameLable.text = name;
    header.iconView.image = [UIImage imageNamed:@"1"];
    return header;
}

@end
