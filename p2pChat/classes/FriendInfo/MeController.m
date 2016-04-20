//
//  MeController.m
//  p2pChat
//
//  Created by nashht on 16/4/1.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MeController.h"
#import "MyXMPP.h"
#import "PhotoLibraryCenter.h"
#import "XMPPvCardTemp.h"

@interface MeController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end

@implementation MeController 

- (void)viewDidLoad {
    XMPPvCardTemp *myvCard = [MyXMPP shareInstance].myVCardTemp;
    self.navigationItem.title = @"我";
    [_photoView.layer setCornerRadius:CGRectGetHeight([_photoView bounds])/2];
    _photoView.layer.masksToBounds = true;
    _nameLabel.text = [[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
//    _groupLabel.text = myvCard.
    _titleLabel.text = myvCard.title;
    _phoneLabel.text = myvCard.note;
    _emailLabel.text = myvCard.mailer;
    
    _photoView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage)];
    tapImage.numberOfTapsRequired = 1; //点击次数
    tapImage.numberOfTouchesRequired = 1; //点击手指数
    [_photoView addGestureRecognizer:tapImage];
 
    
}

- (void)changeImage{
    NSLog(@"changeiamge");
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
    _photoView.image = [UIImage imageNamed:@"filemax_pic"];
}


- (IBAction)updatePassword:(id)sender {
    
}

- (IBAction)loginOut:(id)sender {
    [[MyXMPP shareInstance] loginout];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
