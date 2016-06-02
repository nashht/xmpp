//
//  MyProgressView.h
//  XMPP
//
//  Created by nashht on 16/5/31.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#define MyColor(r,g,b,a) [UIColor colorWithRed:((r)/255.0) green:((g)/255.0) blue:((b)/255.0) alpha:(a)]
#define MyProgressBackgroundColor MyColor(240,240,240,0.9)
#define MyProgressMargin 10
#define MyProgressViewFontScale (MIN(self.frame.size.width, self.frame.size.height) / 100.0)

#import <UIKit/UIKit.h>


@interface MyProgressView : UIView

@property (nonatomic, assign) CGFloat progress;

- (void)setCenterProgressText:(NSString *)text withAttributes:(NSDictionary *)attributes;
- (void)dismiss;
+ (instancetype)progressView;
@end
