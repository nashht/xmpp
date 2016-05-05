//
//  FunctionView.m
//  XMPP
//
//  Created by nashht on 16/4/27.
//  Copyright © 2016年 xiaokun. All rights reserved.
//
#define ScreenSize ([UIScreen mainScreen].bounds.size)
#define colsNum 7
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
    int cols = 7;           // 列数
    int rows = 3;                 //行数

    CGFloat imageWidth = ScreenSize.width / cols;
    
    int groupNum = (ImageNum / (cols * rows - 1) + 1);
    CGFloat width = ScreenSize.width * groupNum;
    CGFloat marginX = (ScreenSize.width - imageWidth * cols) / 2;
    CGFloat marginY = (frame.size.height - imageWidth * rows) / 2;
    
    self.faceScrollView.contentSize = CGSizeMake(width, scrollHeight);
    self.faceScrollView.pagingEnabled = YES;
    self.faceScrollView.showsHorizontalScrollIndicator = NO;
    self.faceScrollView.delegate = self;
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height, ScreenSize.width, 50)];
    [self addSubview:self.pageControl];
    self.pageControl.numberOfPages = groupNum;
    self.pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.814 alpha:1.000];
  
    
    //图片坐标
    CGFloat x = 0;
    CGFloat y = 0;
    
    NSString *imageName;
    
    //往scroll上贴图片
    for (int i = 0; i < ImageNum; i ++) {
        
        //获取图片信息
        if (i < 10) {
            imageName = [NSString stringWithFormat:@"_00%d",i];
        }else if(i < 100){
             imageName = [NSString stringWithFormat:@"_0%d",i];
        }else{
             imageName = [NSString stringWithFormat:@"_%d",i];
        }
    
        UIImage *image = [UIImage imageNamed:imageName];
        
        int page = i / (cols * rows - 1);
        int count = i % (cols * rows - 1);
        int imageRow = count / cols;
        int imageCol = count % cols;

        
        //计算图片位置
        x = ScreenSize.width * page + imageWidth * imageCol + marginX;
        y = imageWidth * imageRow + marginY;
        
        FaceView *face = [[FaceView alloc] initWithFrame:CGRectMake(x, y, imageWidth, imageWidth)];
        [face setImage:image imageNamed:imageName];
        
        //face的回调，当face点击时获取face的图片
        __weak __block FunctionView *copy_self = self;
        [face setFaceBlock:^(UIImage *image, NSString *imageName)
         {
             copy_self.block(image, imageName);
//             NSLog(@"name..click%@",imageName);
         }];
        
        [self.faceScrollView addSubview:face];
        
        if (1 == (i + 1) % (rows * cols - 1)) {
            imageName = @"_del";
            UIImage *image = [UIImage imageNamed:imageName];
            //计算图片位置
            
            x = ScreenSize.width * page + (cols - 1) * imageWidth + marginX;
            y = imageWidth * (rows - 1) + marginY;
            
            FaceView *face = [[FaceView alloc] initWithFrame:CGRectMake(x, y, imageWidth, imageWidth)];
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
