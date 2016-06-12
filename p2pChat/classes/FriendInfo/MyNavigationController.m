//
//  MyNavigationController.m
//  XMPP
//
//  Created by nashht on 16/6/12.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MyNavigationController.h"

@implementation MyNavigationController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.navigationBar.barTintColor = [UIColor colorWithRed:28.0/155 green:162.0/255 blue:230.0/255 alpha:1.0];
}

+ (void)initialize{
    [self setupNavigationBarTheme];
    [self setupBarButtonItemTheme];
}

+ (void)setupNavigationBarTheme{
    UINavigationBar *apperance = [UINavigationBar appearance];
    
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    attr[NSForegroundColorAttributeName] = [UIColor whiteColor];
    attr[NSFontAttributeName] = [UIFont systemFontOfSize:18.f];
    
    [apperance setTitleTextAttributes:attr];
    [apperance setTintColor:[UIColor whiteColor]];      //   箭头颜色白色
}

+ (void)setupBarButtonItemTheme{
    UIBarButtonItem *apperance = [UIBarButtonItem appearance];
    
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    attr[NSForegroundColorAttributeName] = [UIColor whiteColor];
    attr[NSFontAttributeName] = [UIFont systemFontOfSize:15.f];
    
    [apperance setTitleTextAttributes:attr forState:UIControlStateNormal];
}
@end
