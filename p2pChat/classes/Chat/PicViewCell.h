//
//  PicViewCell.h
//  p2pChat
//
//  Created by nashht on 16/3/15.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicFrameModel.h"
@interface PicViewCell : UITableViewCell<UIScrollViewDelegate>

@property(nonatomic,strong) PicFrameModel *picFrame;
@property(nonatomic,strong) id<UIScrollViewDelegate> delegate;
@end
