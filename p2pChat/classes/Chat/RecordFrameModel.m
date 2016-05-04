//
//  RecordFrameModel.m
//  p2pChat
//
//  Created by nashht on 16/3/15.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#define bodyPedding 20

#import "RecordFrameModel.h"
#import "MessageBean.h"
#import "Message+CoreDataProperties.h"

@implementation RecordFrameModel

- (void)setMessage:(MessageBean *)message{
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
    
    //    时长
    CGFloat voiceLengthX;
    CGFloat voiceLengthY;
    CGFloat voiceLengthW = 30;
    CGFloat voiceLengthH = 30;
    
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
    
    double length = [message.more doubleValue];
    
    CGFloat bodyLength = 100;
    if (length <=2) {
        bodyLength = 100;
    }else if(length <= 10){
        bodyLength += 10 * (int)(length - 2);
    }else if(length <= 60){
        bodyLength = 10 * (int)((length - 10) / 10) + 110;
    }else{
        bodyLength = 350;
    }
    
    CGSize lastBodySize = CGSizeMake(bodyLength,45);
    
    CGFloat bodyX;
    CGFloat bodyY = photoY;
     voiceLengthY = bodyY + 10;
    
    if ([message.isOut boolValue]) {
        //        发送的消息，frame靠右边确定
        bodyX = screenW - lastBodySize.width - padding - photoW;
        voiceLengthX = bodyX - 20;
        
    }else{
        bodyX = CGRectGetMaxX(_photoFrame) + padding;
        voiceLengthX = bodyX + bodyLength - 8;
    }
    
    _bodyFrame = (CGRect){{bodyX,bodyY},lastBodySize};
    _voiceLengthFrame = CGRectMake(voiceLengthX, voiceLengthY, voiceLengthW, voiceLengthH);
    
    //    cell的高度
    CGFloat maxBodyH = CGRectGetMaxY(_bodyFrame);
    CGFloat maxPhotoH = CGRectGetMaxY(_photoFrame);
    _cellHeight = MAX(maxBodyH, maxPhotoH);

}

@end
