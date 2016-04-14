//
//  BottomView.h
//  p2pChat
//
//  Created by xiaokun on 16/4/14.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BottomViewDelegate <NSObject>

@required
- (void)showMoreView;

@end

@interface BottomView : UIView

@property (strong, nonatomic) NSString *user;
@property (weak, nonatomic) id<BottomViewDelegate> delegate;

- (void)resignTextfield;

@end
