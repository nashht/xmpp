//
//  RecordViewCell.m
//  p2pChat
//
//  Created by nashht on 16/3/15.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "RecordViewCell.h"
#import "AVFoundation/AVFoundation.h"
#import "Tool.h"
#import "RecordFrameModel.h"

@interface RecordViewCell()
@property(nonatomic,weak)UILabel *timeLable;
@property(nonatomic,weak)UIImageView *photoImage;
@property(nonatomic,weak)UIButton *bodyBtn;
@property(nonatomic,strong)AVAudioPlayer *player;

@end

@implementation RecordViewCell

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
        
        [self.contentView addSubview:btn];
        _bodyBtn = btn;
        
        
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}


- (void) setRecordFrame:(RecordFrameModel *)recordFrame{
    _recordFrame = recordFrame;
    
    //    数据模型
    Message *msg = _recordFrame.message;
    
    _timeLable.text = [Tool stringFromDate:msg.time];
    _timeLable.frame = _recordFrame.timeFrame;
    
    if ([msg.isOut boolValue]) {
        _photoImage.image = [UIImage imageNamed:@"0"];
    }else{
        _photoImage.image = [UIImage imageNamed:@"1"];
    }
    
    _photoImage.frame = _recordFrame.photoFrame;
    [_photoImage.layer setCornerRadius:CGRectGetHeight([_photoImage bounds]) / 2];
    _photoImage.layer.masksToBounds = true;
    
//    [_bodyBtn setTitle:msg.body forState:UIControlStateNormal];
    _bodyBtn.frame = _recordFrame.bodyFrame;
    [_bodyBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    
    //    背景,图片上加上播放图标
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

- (AVAudioPlayer *)player{
    if (_player == nil) {
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:_recordFrame.message.body] error:nil];
    }
        return _player;
}

- (void)btnClick{
    if ([self.player isPlaying]) {
        [_player stop];
    }else{
        _player.currentTime = 0;
        [_player play];
    }
//    NSLog(@"%@",_recordFrame.message.more);
}



@end
