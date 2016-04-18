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

//- (instancetype)initWithCoder:(NSCoder *)aDecoder{
//    
//}

+ (instancetype)headerView{
    return [[[NSBundle mainBundle]loadNibNamed:@"HeaderView" owner:self options:nil] lastObject];
}

- (void)Name:(NSString *)name{
    self.nameLabel.text = name;
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
}

@end
