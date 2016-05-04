//
//  FunctionView.h
//  XMPP
//
//  Created by nashht on 16/4/27.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
//      定义对应的block类型，用于数据的交互
typedef void (^FunctionBlock) (UIImage *image,NSString *imageName);

@interface FunctionView : UIView

//      资源文件名
@property (nonatomic, strong) NSString *plistFileName;
//      接受block段
- (void)setFunctionBlock:(FunctionBlock) block;

@end
