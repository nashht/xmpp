//
//  FaceView.h
//  XMPP
//
//  Created by nashht on 16/4/27.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

 // 声明表情对应的block,用于把点击的表情的图片和图片信息传到上层视图
typedef void (^FaceBlock) (UIImage *image, NSString *imageName);

@interface FaceView : UIView

//      图片对应的文字
@property (nonatomic,strong) NSString *imageName;
//      表情图片
@property (nonatomic,strong) UIImage *faceImage;

//    设置block回调
- (void)setFaceBlock:(FaceBlock)block;
//    设置图片，文字
- (void)setImage:(UIImage *)image imageNamed:(NSString *)imageName ;

@end
