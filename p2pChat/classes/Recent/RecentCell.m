//
//  RecentCell.m
//  p2pChat
//
//  Created by admin on 16/3/31.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "RecentCell.h"
#import "LastMessage+CoreDataProperties.h"

@interface RecentCell ()

@end

@implementation RecentCell

- (void)setUnread:(NSNumber *) num {
    
    NSNumber * minNumber = [[NSNumber alloc] initWithInt:0];
    NSNumber * maxNumber = [[NSNumber alloc] initWithInt:10];
    [_nonreadmessagenum.layer setCornerRadius:10];
    _nonreadmessagenum.layer.masksToBounds = true;
    
    if ([num compare:minNumber] == NSOrderedSame) {
        _nonreadmessagenum.hidden = YES;
    }
    else
    {
        if ([num compare:maxNumber] == NSOrderedDescending) {
            _nonreadmessagenum.text = @"10+";
        }
        _nonreadmessagenum.hidden = NO;
    }
}

- (void)awakeFromNib {
    // Initialization code
    [_userimage.layer setCornerRadius:10];
    _userimage.layer.masksToBounds = true;
    
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


@end
