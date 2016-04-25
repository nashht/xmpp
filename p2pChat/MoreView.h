//
//  MoreView.h
//  p2pChat
//
//  Created by xiaokun on 16/1/10.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MoreView : UIView <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (copy, nonatomic) NSString *chatObjectString;
@property (assign, nonatomic, getter=isP2PChat) BOOL p2pChat;

@end
