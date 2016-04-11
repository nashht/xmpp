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
    [_nonreadmessagenum.layer setCornerRadius:CGRectGetHeight([_nonreadmessagenum bounds]) / 2];
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
    [_userimage.layer setCornerRadius:CGRectGetHeight([_userimage bounds]) / 2];
    _userimage.layer.masksToBounds = true;
    
}



@end
