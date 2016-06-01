//
//  MyProgressView.m
//  XMPP
//
//  Created by nashht on 16/5/31.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MyProgressView.h"

@implementation MyProgressView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = MyProgressBackgroundColor;
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setCenterProgressText:(NSString *)text withAttributes:(NSDictionary *)attributes{
    CGFloat centerX = self.frame.size.width * 0.5;
    CGFloat centerY = self.frame.size.height * 0.5;
    
    CGSize strSize = [text sizeWithAttributes:attributes];
    CGFloat strX = centerX - strSize.width * 0.5;
    CGFloat strY = centerY - strSize.height * 0.5;
    [text drawAtPoint:CGPointMake(strX, strY) withAttributes:attributes];
}

- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (progress >= 1.0) {
            [self removeFromSuperview];
        }else{
            [self setNeedsDisplay];
        }
    });
}

- (void)drawRect:(CGRect)rect{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat centerX = rect.size.width * 0.5;
    CGFloat centerY = rect.size.height * 0.5;
    [[UIColor greenColor] set];
    
    CGFloat radius = MIN(rect.size.width * 0.5, rect.size.height * 0.5) - MyProgressMargin;
    
    CGFloat w = radius * 2 + MyProgressMargin;
    CGFloat h = w;
    CGFloat x = (rect.size.width - w) * 0.5;
    CGFloat y = (rect.size.height - h) * 0.5;
    
    CGContextAddEllipseInRect(ctx, CGRectMake(x, y, w, h));
    CGContextFillPath(ctx);
    [[UIColor grayColor] set];
 
    CGFloat startAngle = M_PI * 0.5 - _progress * M_PI;
    CGFloat endAngle = M_PI * 0.5 + _progress * M_PI;
    CGContextAddArc(ctx, centerX, centerY, radius, startAngle, endAngle, 0);
    CGContextFillPath(ctx);
    
//    进度数字
    NSString *progressStr = [NSString stringWithFormat:@"%.0f%%",_progress * 100];
    NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
    attrDict[NSFontAttributeName] = [UIFont systemFontOfSize:18.f];
    attrDict[NSForegroundColorAttributeName] = [UIColor lightGrayColor];
    [self setCenterProgressText:progressStr withAttributes:attrDict];
}

- (void)dismiss{
    self.progress = 1.0;
}

+ (instancetype)progressView{
    return [[self alloc] init];
}
@end
