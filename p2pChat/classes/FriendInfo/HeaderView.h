//
//  HeaderView.h
//  p2pChat
//
//  Created by nashht on 16/4/18.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HeaderView;

@protocol HeaderViewDelegate<NSObject>

- (void)headerViewDidClicked:(HeaderView *)headerView;
@end

@interface HeaderView : UIView
@property (nonatomic, weak) id<HeaderViewDelegate> delegate;
@property (nonatomic, assign) NSUInteger section;
@property (nonatomic, assign) BOOL allSelected;

+ (instancetype)headerView;
- (void)Name:(NSString *)name;
- (void)Image:(UIImage *)image;
@end
