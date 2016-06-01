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
- (void)hideMoreView;
- (void)showFaceView;
@end

@interface BottomView : UIView

@property (copy, nonatomic) NSString *chatObjectString;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) id<BottomViewDelegate> delegate;
@property (assign, nonatomic, getter=isP2PChat) BOOL p2pChat;

- (void)resignTextfield;
- (void)inputFaceView:(NSString *)faceName;

@end
