//
//  MessageCellTableViewCell.m
//  p2pChat
//
//  Created by nashht on 16/3/10.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#define bodyPadding 20
#import "MessageViewCell.h"
#import "PicFrameModel.h"
#import "Tool.h"
#import "PicViewCell.h"

@interface PicViewCell()
@property(nonatomic,weak)UILabel *timeLable;
@property(nonatomic,weak)UIImageView *photoImage;
@property(nonatomic,weak)UIButton *bodyBtn;
@property(nonatomic,weak)UIScrollView *bodyScroll;
@property(nonatomic,weak)UIImageView *aImageView;
@property(nonatomic,weak)UIImage *image;
@property(nonatomic,weak)UIView *v;

@end

@implementation PicViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //        1.时间
        UILabel *timeLable = [[UILabel alloc] init];
        timeLable.textAlignment = NSTextAlignmentCenter;
        timeLable.font = [UIFont systemFontOfSize:13.0f];
        [self.contentView addSubview:timeLable];
        _timeLable = timeLable;
        
        //        2.头像
        UIImageView *photoImage = [[UIImageView alloc] init];
        [self.contentView addSubview:photoImage];
        _photoImage = photoImage;
        
        //        3.正文
        UIButton *btn = [[UIButton alloc] init];
        btn.contentEdgeInsets = UIEdgeInsetsMake(bodyPadding, bodyPadding, bodyPadding, bodyPadding);
        
        [self.contentView addSubview:btn];
        _bodyBtn = btn;
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:imageView];
        
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}


- (void) setPicFrame:(PicFrameModel *)picFrame{
    _picFrame = picFrame;
    
    //    数据模型
    Message *msg = picFrame.message;
    
    _timeLable.text = [Tool stringFromDate:msg.time];
    _timeLable.frame = picFrame.timeFrame;
    
    if ([msg.isOut boolValue]) {
        _photoImage.image = [UIImage imageNamed:@"0"];
    }else{
        _photoImage.image = [UIImage imageNamed:@"1"];
    }
    
    _photoImage.frame = picFrame.photoFrame;
    
    UIImage *image = [UIImage imageWithContentsOfFile:picFrame.message.body];
    [_bodyBtn setImage:image forState:UIControlStateNormal];
    _bodyBtn.frame = picFrame.bodyFrame;
    [_bodyBtn addTarget:self action:@selector(picBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _image = image;
    
    //    pic背景
    if ([msg.isOut boolValue]) {
        [_bodyBtn setBackgroundImage: [self resizeImageWithName:@"chat_send_nor"] forState:UIControlStateNormal];
    }else{
        [_bodyBtn setBackgroundImage:[self resizeImageWithName:@"chat_recive_nor"] forState:UIControlStateNormal];
    }
    
}

- (UIImage *)resizeImageWithName:(NSString *)name
{
    UIImage *normal = [UIImage imageNamed:name];
    
    CGFloat w = normal.size.width * 0.5f - 1;
    CGFloat h = normal.size.height* 0.5f - 1;
    
    return [normal resizableImageWithCapInsets:UIEdgeInsetsMake(h, w, h, w)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)picBtnClick{
    UIView *v = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    v.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication].keyWindow addSubview:v];
    _v = v;
    
    UIScrollView *imageScroll = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:_image];
    [imageScroll addSubview:imageView];
//    UIImage *image = [UIImage imageNamed:@"Snip20151210_2.png"];
    _aImageView = imageView;
    _bodyScroll = imageScroll;
    
    _bodyScroll.contentSize = _image.size;
    _bodyScroll.delegate = self;
    
    _bodyScroll.maximumZoomScale = 3.0;
    _bodyScroll.minimumZoomScale = 0.5;
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-_image.size.height*[UIScreen mainScreen].bounds.size.width/_image.size.width)/2, [UIScreen mainScreen].bounds.size.width, _image.size.height*[UIScreen mainScreen].bounds.size.width/_image.size.width);
    }];
    
    [v addSubview:_bodyScroll];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [_bodyScroll addGestureRecognizer: tap];

   }

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _aImageView;
}

- (void)hideImage:(UITapGestureRecognizer*)tap{
    [UIView animateWithDuration:0.3 animations:^{
        [_v removeFromSuperview];
    } completion:^(BOOL finished) {
        
    }];
}

@end
