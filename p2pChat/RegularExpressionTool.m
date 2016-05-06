//
//  RegularExpressionTool.m
//  RegularExpression
//
//  Created by nashht on 16/5/4.
//  Copyright © 2016年 nashht. All rights reserved.
//

#import "RegularExpressionTool.h"

@implementation RegularExpressionTool

+ (NSAttributedString *)stringTranslation2FaceView:(NSString *)str{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    //正则匹配要替换的文字的范围
    
    //正则表达式
    NSString * pattern = @"\\[[a-zA-Z0-9]+\\]";
    pattern = @"\\[p/_\\d{3}.png\\]";
    NSError *error = nil;
    NSRegularExpression * re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    if (!re) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    //通过正则表达式来匹配字符串
    NSArray *resultArray = [re matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    
//    NSLog(@"resultArray %@",resultArray);
    
    //用来存放字典，字典中存储的是图片和图片对应的位置
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    
    //根据匹配范围来用图片进行相应的替换
    for(NSTextCheckingResult *match in resultArray) {
        //获取数组元素中得到range
        NSRange range = [match range];
        
        //获取原字符串中对应的值
        
        NSString *subStr = [str substringWithRange:range];
//        NSLog(@"subStr == %@",subStr);
        NSRange range1 = NSMakeRange(3, 8);
        
        NSString *imageName = [subStr substringWithRange:range1];
//        NSLog(@"imageName = %@",imageName);
        
        //新建文字附件来存放我们的图片
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
           textAttachment.bounds = CGRectMake(0, -8, 26, 26);
        //给附件添加图片
        textAttachment.image = [UIImage imageNamed:imageName];
        //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
        NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
        //把图片和图片对应的位置存入字典中
        NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
        [imageDic setObject:imageStr forKey:@"image"];
        [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
        
        //把字典存入数组中
        [imageArray addObject:imageDic];
        
    }
    
    //从后往前替换
    for (long i = imageArray.count -1; i >= 0; i--)
    {
        NSRange range;
        [imageArray[i][@"range"] getValue:&range];
        //进行替换
        [attributedString replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
    }
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.f] range:NSMakeRange(0, attributedString.length)];
    
    return attributedString;
}
@end
