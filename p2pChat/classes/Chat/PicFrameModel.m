//
//  PicFrameMode.m
//  p2pChat
//
//  Created by nashht on 16/3/15.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#define bodyPedding 20
#import "PicFrameModel.h"
#import "MessageFrameModel.h"
#import "MessageBean.h"

@implementation PicFrameModel

- (void)setMessage:(MessageBean *)message {
    _message = message;
    //    设置屏幕的宽
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    //    设置边距
    CGFloat padding = 10;
    
    //    时间
    CGFloat timeX = 0;
    CGFloat timeY = 0;
    CGFloat timeW = screenW;
    CGFloat timeH = 44;
    _timeFrame = CGRectMake(timeX, timeY, timeW, timeH);
    
    //    头像
    CGFloat photoX;
    CGFloat photoY = CGRectGetMaxY(_timeFrame) + padding;
    CGFloat photoW = 50;
    CGFloat photoH = 50;
    
    if ([message.isOut boolValue]) {
        //        自己发送的消息，头像在右边
        photoX = screenW - padding - photoW;
    }else{
        photoX = padding;
    }
    
    _photoFrame = CGRectMake(photoX, photoY, photoW, photoH);
    
    UIImage *image = [UIImage imageWithContentsOfFile:message.more];
    _image = image;

    CGSize bodySize =  image.size;
    CGSize lastBodySize = CGSizeMake(bodySize.width + bodyPedding * 2, bodySize.height + bodyPedding * 2);
    
    CGFloat bodyX;
    CGFloat bodyY =  photoY;
    if ([message.isOut boolValue]) {
        //        发送的消息，frame靠右边确定
        bodyX = screenW - lastBodySize.width - padding - photoW;
    }else{
        bodyX = CGRectGetMaxX(_photoFrame) + padding;
    }
    _bodyFrame = (CGRect){{bodyX,bodyY},lastBodySize};
    
    CGFloat maxBodyH = CGRectGetMaxY(_bodyFrame);
    CGFloat maxPhotoH = CGRectGetMaxY(_photoFrame);
    _cellHeight = MAX(maxBodyH, maxPhotoH);
}

@end
