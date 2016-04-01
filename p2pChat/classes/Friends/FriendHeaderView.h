//
//  FriendHeaderView.h
//  p2pChat
//
//  Created by nashht on 16/3/24.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FriendsGroup,FriendHeaderView;
@protocol FriendHeaderViewDelegate<NSObject>
@optional

- (void) headerViewDidClickedNameView:(FriendHeaderView *)headerView;

@end



@interface FriendHeaderView : UITableViewHeaderFooterView
@property (nonatomic, strong) FriendsGroup *group;
@property (nonatomic, weak) id<FriendHeaderViewDelegate> delegate;

+ (instancetype)friendHeaderViewWithTableView:(UITableView *)tableView;
@end
