//
//  FaceView.m
//  XMPP
//
//  Created by nashht on 16/4/27.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "FaceView.h"

@interface FaceView()
@property (nonatomic, strong) FaceBlock block;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation FaceView

//      初始化图片
- (instancetype)initWithFrame:(CGRect)frame{
    CGFloat imageWidth = frame.size.width;
    frame.size.height = 30;
    frame.size.width = 30;
    CGFloat marginX = (imageWidth - 30) * 0.5;
    
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.frame = CGRectMake(marginX, 0, frame.size.width, frame.size.height);
        [self addSubview:self.imageView];

     }
    return self;
}

- (void)setFaceBlock:(FaceBlock)block{
    self.block = block;
}

- (void)setImage:(UIImage *)image imageNamed:(NSString *)imageName{
//    显示图片
    [self.imageView setImage:image];
    self.imageName = imageName;

}

//      点击回调
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    //判断触摸的结束点是否在图片中
    if (CGRectContainsPoint(self.bounds, point) ) {
//        回调
        self.block(self.faceImage, self.imageName);
    }
}

@end
