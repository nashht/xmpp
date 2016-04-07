//
//  ChangePswController.h
//  p2pChat
//
//  Created by admin on 16/4/6.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePswController : UIViewController


@property (strong,nonatomic) IBOutlet UITextField *Pswnew;
@property (strong,nonatomic) IBOutlet UITextField *Pswidentify;


- (void) save;

@end
