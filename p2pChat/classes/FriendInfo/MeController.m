//
//  MeController.m
//  p2pChat
//
//  Created by nashht on 16/4/1.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MeController.h"

@interface MeController ()

@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation MeController

- (void)viewDidLoad {
    _nameLabel.text = [[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
    _groupLabel.text = @"nmrc1";
    _phoneLabel.text = @"12345678901";
    _emailLabel.text = @"ios@nmrc.com";
}

- (IBAction)updatePassword:(id)sender {
    
}

- (IBAction)loginOut:(id)sender {
    
}

@end
