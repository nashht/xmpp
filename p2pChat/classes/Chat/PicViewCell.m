//
//  MessageCellTableViewCell.m
//  p2pChat
//
//  Created by nashht on 16/3/10.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#define bodyPadding 15
#define CachePath(a) ([NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:(a)])

#import "MessageViewCell.h"
#import "AFNetworking.h"
#import "PicFrameModel.h"
#import "Tool.h"
#import "PicViewCell.h"
#import "MessageBean.h"
#import "MyXMPP+VCard.h"
#import "PhotoLibraryCenter.h"

@interface PicViewCell()

@property (nonatomic, weak) UILabel *timeLable;
@property (nonatomic, weak) UIImageView *photoImage;
@property (nonatomic, weak) UIButton *bodyBtn;
@property (nonatomic, weak) UIScrollView *bodyScroll;
@property (nonatomic, weak) UIImageView *aImageView;
@property (nonatomic, weak) UIImage *image;
@property (nonatomic, weak) UIView *cover;
@property (nonatomic, assign) CGRect lastFrame;

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


- (void)setPicFrame:(PicFrameModel *)picFrame{
    _picFrame = picFrame;
    
    //    数据模型
    MessageBean *message = picFrame.message;
    
    _timeLable.text = [Tool stringFromDate:[NSDate dateWithTimeIntervalSince1970:message.time.doubleValue]];
    _timeLable.frame = picFrame.timeFrame;
    
    XMPPvCardTemp *vCard;
    if ([message.isOut boolValue]) {
        vCard = [MyXMPP shareInstance].myVCardTemp;
    }else{
        vCard = [[MyXMPP shareInstance]fetchFriend:[XMPPJID jidWithUser:message.username domain:myDomain resource:nil]];
    }
    
    if (vCard.photo != nil) {
        _photoImage.image = [UIImage imageWithData:vCard.photo];
    } else {
        _photoImage.image = [UIImage imageNamed:@"0"];
    }
    
    _photoImage.frame = picFrame.photoFrame;
    [_photoImage.layer setCornerRadius:10];
    _photoImage.layer.masksToBounds = true;
    
    UIImage *image = picFrame.image;
    [_bodyBtn setImage:image forState:UIControlStateNormal];
    
    _bodyBtn.frame = picFrame.bodyFrame;
//    _lastFrame = _bodyBtn.frame;
    [_bodyBtn addTarget:self action:@selector(picBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _image = image;
    
    //    pic背景
    if ([message.isOut boolValue]) {
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

- (void)picBtnClick:(UIButton *)button{
//    添加一个遮盖
    UIView *cover = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    cover.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication].keyWindow addSubview:cover];
    _cover = cover;
    UIImageView *imageView = [[UIImageView alloc]init];
    _aImageView = imageView;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if ([_picFrame.message.isOut boolValue]) {//发送出去的图片原图在图库里
        [[[PhotoLibraryCenter alloc]init]getImageWithLocalIdentifier:_picFrame.message.body withCompletionHandler:^(UIImage *image) {
            imageView.image = image;
            
            [cover addSubview:imageView];
        }];
    } else {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:CachePath(_picFrame.message.body)]) {
//            NSLog(@"已经存在");
            UIImage *image = [UIImage imageWithContentsOfFile:CachePath(_picFrame.message.body)];
            _aImageView.image = image;
            [cover addSubview:imageView];
        }else{
//            NSLog(@"需要下载");
            [self downloadImageWithFilename:_picFrame.message.body withCompletionHandler:^(UIImage *image) {
                _aImageView.image = image;
                [cover addSubview:imageView];
            }];
        }
    }
    
    imageView.frame = [cover convertRect:button.imageView.frame fromView:cover];
     _lastFrame = imageView.frame;
    
    [UIView animateWithDuration:0.2 animations:^{
        CGFloat w = cover.frame.size.width;
        CGFloat h = w * (cover.frame.size.height / imageView.frame.size.height);
        CGFloat x = 0;
        CGFloat y = (cover.frame.size.height - h) * 0.5;
        CGRect frame = CGRectMake(x, y, w, h);
        imageView.frame = frame;
    }];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [cover addGestureRecognizer: tap];
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _aImageView;
}

- (void)hideImage:(UITapGestureRecognizer*)tap{
    [UIView animateWithDuration:0.2 animations:^{
//        _cover.backgroundColor = [UIColor clearColor];
//        _aImageView.frame = _lastFrame;
    } completion:^(BOOL finished) {
        [tap.view removeFromSuperview];
    }];
}

- (void)downloadImageWithFilename:(NSString *)filename withCompletionHandler:(void(^)(UIImage *image))completionHandler{
    NSString *url =  [NSString stringWithFormat:@"http://10.108.136.59:8080/FileServer/file?method=download&filename=%@",filename];
//    url = @"http://10.108.136.59:8080/FileServer/file?method=download&filename=ht_test_1464095341";
    AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLSessionDownloadTask *task = [sessionManager downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"downloadProgress---------- : %@",downloadProgress);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        // 将下载文件保存在缓存路径中
        // URLWithString返回的是网络的URL,如果使用本地URL,需要注意
        //        NSURL *fileURL1 = [NSURL URLWithString:path];
        NSURL *fileURL = [NSURL fileURLWithPath:CachePath(filename)];
        return fileURL;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"-----filePath -----  %@",filePath);
        
        NSData *data = [NSData dataWithContentsOfURL:filePath];
        UIImage *image = [UIImage imageWithData:data];
        completionHandler(image);
    }];
    
    [task resume];
}

@end
