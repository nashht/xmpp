//
//  MessageCellTableViewCell.m
//  p2pChat
//
//  Created by nashht on 16/3/10.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#define bodyPadding 20
#import "MessageViewCell.h"
#import "MessageFrameModel.h"
#import "Tool.h"

@interface MessageViewCell()
@property(nonatomic,weak)UILabel *timeLable;
@property(nonatomic,weak)UIImageView *photoImage;
@property(nonatomic,weak)UIButton *bodyBtn;

@end

@implementation MessageViewCell

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
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        btn.titleLabel.numberOfLines = 0;   //自动换行；
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.contentEdgeInsets = UIEdgeInsetsMake(bodyPadding, bodyPadding, bodyPadding, bodyPadding);
        
        [self.contentView addSubview:btn];
        _bodyBtn = btn;
            
        
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}


- (void) setMessageFrame:(MessageFrameModel *)messageFrame{
    _messageFrame = messageFrame;
    
    //    数据模型
    Message *msg = messageFrame.message;
    
    _timeLable.text = [Tool stringFromDate:msg.time];
    _timeLable.frame = messageFrame.timeFrame;
    
    if ([msg.isOut boolValue]) {
        _photoImage.image = [UIImage imageNamed:@"0"];
    }else{
        _photoImage.image = [UIImage imageNamed:@"1"];
    }
    
    _photoImage.frame = messageFrame.photoFrame;
    
    [_bodyBtn setTitle:msg.body forState:UIControlStateNormal];
    _bodyBtn.frame = messageFrame.bodyFrame;
    
//    文字背景
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

@end
