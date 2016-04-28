//
//  FunctionView.m
//  XMPP
//
//  Created by nashht on 16/4/27.
//  Copyright © 2016年 xiaokun. All rights reserved.
//
#define ScreenSize ([UIScreen mainScreen].bounds.size)
#define ImageNum 143

#import "FunctionView.h"
#import "FaceView.h"

@interface FunctionView()<UIScrollViewDelegate>
@property (nonatomic, strong) FunctionBlock block;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) UIImage *faceImage;
@property (nonatomic, strong) UIScrollView *faceScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation FunctionView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor greenColor];
        [self loadImages];

    }
    return self;
}


//接受回调
-(void)setFunctionBlock:(FunctionBlock)block
{
    self.block = block;
}

//负责把查出来的图片显示
-(void)loadImages
{
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height -50);
    
    self.faceScrollView = [[UIScrollView alloc] initWithFrame:frame];
    [self addSubview:self.faceScrollView];
  
    CGFloat scrollHeight = (self.frame).size.height - 50;
    NSLog(@"frame===%@",[NSValue valueWithCGRect:self.frame]);
    

    
    //根据图片量来计算scrollView的Contain的宽度
    int cols = ScreenSize.width / 56;           // 列数
    int rows = scrollHeight / 56;                 //行数
    NSLog(@"列数cols = %d----行数rows = %d",cols,rows);
    

    int groupNum = (ImageNum / (cols * rows - 1) + 1);
    CGFloat width = ScreenSize.width * groupNum;
    CGFloat marginX = (ScreenSize.width - 56 * cols) / 2;
    CGFloat marginY = (frame.size.height - 56 * rows) / 2;
    NSLog(@"width---%f----%d屏",width,ImageNum / (cols * rows - 1) + 1);
    
    self.faceScrollView.contentSize = CGSizeMake(width, scrollHeight);
    self.faceScrollView.pagingEnabled = YES;
    self.faceScrollView.showsHorizontalScrollIndicator = NO;
    self.faceScrollView.delegate = self;
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height, ScreenSize.width, 50)];
    [self addSubview:self.pageControl];
    self.pageControl.numberOfPages = groupNum;
    self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    self.pageControl.pageIndicatorTintColor = [UIColor orangeColor];
  
    
    //图片坐标
    CGFloat x = 0;
    CGFloat y = 0;
    
    NSString *imageName;
    
    //往scroll上贴图片
    for (int i = 0; i < ImageNum; i ++) {

//        if (!((i + 1) % (rows * cols ))) {
//            imageName = @"_143";
//            continue;
//        }
        
        //获取图片信息
        if (i < 10) {
            imageName = [NSString stringWithFormat:@"_00%d",i];
        }else if(i < 100){
             imageName = [NSString stringWithFormat:@"_0%d",i];
        }else{
             imageName = [NSString stringWithFormat:@"_%d",i];
        }
    
        UIImage *image = [UIImage imageNamed:imageName];
        
        int imageRow = i / cols;
        int imageCol = i % cols;
        
        //计算图片位置

        x = 56 * imageCol + marginX;
        if (imageRow >= rows) {
        
            x = 56 * imageCol + ScreenSize.width * (imageRow / rows - 1) + marginX;
                imageRow %= rows;
        }
        y = 56 * imageRow + marginY;
        
        FaceView *face = [[FaceView alloc] initWithFrame:CGRectMake(x, y, 56, 56)];
        [face setImage:image imageNamed:imageName];
        
        //face的回调，当face点击时获取face的图片
        __weak __block FunctionView *copy_self = self;
        [face setFaceBlock:^(UIImage *image, NSString *imageName)
         {
             copy_self.block(image, imageName);
             NSLog(@"name..click%@",imageName);
         }];
        
        [self.faceScrollView addSubview:face];
    }
    
    [self.faceScrollView setNeedsDisplay];
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    double doublePage = scrollView.contentOffset.x / ScreenSize.width;
    int intPage = (int) (doublePage + 0.5);
    self.pageControl.currentPage = intPage;
}

@end
