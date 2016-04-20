//
//  HeaderView.m
//  p2pChat
//
//  Created by nashht on 16/4/18.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "HeaderView.h"

@interface HeaderView ()

@property (weak, nonatomic) IBOutlet UIImageView *selectImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (assign, nonatomic, getter = checkoutStatus) BOOL checkoutStatus;

@end

@implementation HeaderView

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
         self.allSelected = NO;
    }
    return self;
}

+ (instancetype)headerView{
    return [[[NSBundle mainBundle]loadNibNamed:@"HeaderView" owner:self options:nil] lastObject];
}

- (void)Name:(NSString *)name{
    self.nameLabel.text = name;
}

- (void)Image:(UIImage *)image{
    self.selectImg.image = image;
}

- (void)selectedStatus{
    self.selectImg.image = [UIImage imageNamed:@"add_take_phone_n"];
}

- (IBAction)headerClick:(id)sender {
    NSLog(@"headerClick");
    
    if ([self.delegate respondsToSelector:@selector(headerViewDidClicked:)]) {
        [self.delegate headerViewDidClicked:self];
    }
//    self.nameLabel.text = @"click";
    NSLog(@"section:%ld",self.section);
}

@end
