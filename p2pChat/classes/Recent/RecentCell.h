//
//  RecentCell.h
//  p2pChat
//
//  Created by admin on 16/3/31.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LastMessage;

@interface RecentCell : UITableViewCell

@property (strong, nonatomic)IBOutlet UIImageView *userimage;
@property (strong, nonatomic)IBOutlet UILabel *usernamelabel;
@property (strong, nonatomic)IBOutlet UILabel *lastmessagelabel;
@property (strong, nonatomic)IBOutlet UILabel *lastmessagetime;
@property (strong, nonatomic)IBOutlet UILabel *nonreadmessagenum;

- (void)setUnread:(NSString *)num;
@end
