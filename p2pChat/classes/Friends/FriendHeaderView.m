//
//  FriendHeaderView.m
//  p2pChat
//
//  Created by nashht on 16/3/24.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "FriendHeaderView.h"
#import "FriendsGroup.h"

@interface FriendHeaderView()
@property (nonatomic,weak) UILabel *countView;
@property (nonatomic,weak) UIButton *nameView;

@end

@implementation FriendHeaderView

+ (instancetype)friendHeaderViewWithTableView:(UITableView *)tableView{
    static NSString *ID = @"header";
    FriendHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ID];
    if (header == nil) {
        header = [[FriendHeaderView alloc] initWithReuseIdentifier:ID];
    }
    return header;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        UIButton *nameView = [UIButton buttonWithType:UIButtonTypeCustom];
        [nameView setBackgroundImage:[UIImage imageNamed:@"buddy_header_bg"] forState:UIControlStateNormal];
        [nameView setBackgroundImage:[UIImage imageNamed:@"buddy_header_bg_highlighted"] forState:UIControlStateHighlighted];
        [nameView setImage:[UIImage imageNamed:@"buddy_header_arrow"] forState:UIControlStateNormal];
        [nameView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        nameView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        nameView.titleEdgeInsets = UIEdgeInsetsMake(0, 0 + 10, 0, 0);
        nameView.contentEdgeInsets = UIEdgeInsetsMake(0, 0 + 10, 0, 0);
        [nameView addTarget:self action:@selector(nameViewClick) forControlEvents:UIControlEventTouchUpInside];
        
        nameView.imageView.contentMode = UIViewContentModeCenter;
        nameView.imageView.clipsToBounds = NO;
        
        [self.contentView addSubview:nameView];
        self.nameView = nameView;
        
        UILabel *countView = [[UILabel alloc] init];
        countView.textAlignment = NSTextAlignmentRight;
        countView.textColor = [UIColor grayColor];
        
        [self.contentView addSubview:countView];
        self.countView = countView;
     }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.nameView.frame = self.bounds;

    CGFloat countY = 0;
    CGFloat countW = 150;
    CGFloat countH = self.bounds.size.height;
    CGFloat countX = self.bounds.size.width - countW - 10;
    self.countView.frame = CGRectMake(countX, countY, countW, countH);
}

- (void)setGroup:(FriendsGroup *)group{
    _group = group;
    [self.nameView setTitle:group.name forState:UIControlStateNormal];
    self.countView.text = [NSString stringWithFormat:@"%d/%ld",group.online,group.friends.count];
}

- (void)nameViewClick{
    self.group.opened = !self.group.isOpened;
    
    if ([self.delegate respondsToSelector:@selector(headerViewDidClickedNameView:)]) {
        [self.delegate headerViewDidClickedNameView:self];
    }
}

//    视图移动之前调用
- (void)didMoveToSuperview{
    if (!self.group.opened) {
        self.nameView.imageView.transform = CGAffineTransformMakeRotation(0);
    }else{
        self.nameView.imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
}
@end
