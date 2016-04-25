//
//  MeController.m
//  p2pChat
//
//  Created by nashht on 16/4/1.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "MeController.h"
#import "XMPP.h"
#import "MyXMPP+VCard.h"
#import "PhotoLibraryCenter.h"

@interface MeController ()<UIImagePickerControllerDelegate,UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photoView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) XMPPvCardTemp *myvCard;

@end

@implementation MeController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"MEviewDidLoadME");
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
}

- (void)loadvCard{
  
//    XMPPvCardTemp *myvCard = [MyXMPP shareInstance].myVCardTemp;
    NSLog(@"myjid--------%@",[MyXMPP shareInstance].myjid);
    XMPPvCardTemp *myvCard = [[MyXMPP shareInstance]fetchFriend:[MyXMPP shareInstance].myjid];
    _myvCard = myvCard;
    self.navigationItem.title = @"我";
    _photoView.layer.cornerRadius = 10;
    _photoView.layer.masksToBounds = true;
    _nameLabel.text = [[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
    //    _groupLabel.text = myvCard
    NSLog(@"titleLabel.text-------------%@",_myvCard.note);
    _titleLabel.text = _myvCard.note;
    _phoneLabel.text = _myvCard.note;
    _emailLabel.text = _myvCard.mailer;
    
    
    
    if (_myvCard.photo) {
        _photoView.image = [UIImage imageWithData:_myvCard.photo];
    }else{
        _photoView.image = [UIImage imageNamed:@"filemax_pic"];
    }
    
    _photoView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage)];
    tapImage.numberOfTapsRequired = 1; //点击次数
    tapImage.numberOfTouchesRequired = 1; //点击手指数
    [_photoView addGestureRecognizer:tapImage];
}

- (void)changeImage{
    NSLog(@"changeimage");
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    [self presentViewController:imagePicker animated:YES completion:^{
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;

    [self loadvCard];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editInfo"]) {
        EditViewController *editVC = segue.destinationViewController;
        NSIndexPath *indexPath = sender;
        editVC.type = indexPath.row;
    }
}

- (IBAction)updatePassword:(id)sender {
    
}

- (IBAction)loginOut:(id)sender {
    [[MyXMPP shareInstance] loginout];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        [self performSegueWithIdentifier:@"editInfo" sender:indexPath];
    }
}

#pragma mark - UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    _photoView.image = image;

    [[MyXMPP shareInstance]updataeMyPhoto:UIImagePNGRepresentation(self.photoView.image)];
    NSLog(@"didFinishPickingMediaWithInfo");
    
    [self dismissViewControllerAnimated:YES completion:^{
      
    }];
}
@end
