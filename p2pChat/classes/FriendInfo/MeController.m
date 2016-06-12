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
#import "MyXMPP+Roster.h"
#import "PhotoLibraryCenter.h"
#import "EditViewController.h"
#import "MyXMPP.h"

@interface MeController ()<UIImagePickerControllerDelegate,UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
//@property (weak, nonatomic) IBOutlet UILabel *groupLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) XMPPvCardTemp *myvCard;
@property (weak, nonatomic) IBOutlet UILabel *zuojiLabel;

@property (strong, nonatomic) MyXMPP *xmpp;
@property (assign, nonatomic) MyXMPPStatus status;

@end

@implementation MeController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBar];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)setNavigationBar{
    self.navigationItem.title = @"我";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:28.0/155 green:162.0/255 blue:230.0/255 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    UIBarButtonItem *backbutton = [[UIBarButtonItem alloc]init];
    backbutton.title = @"返回";
    self.navigationItem.backBarButtonItem = backbutton;
}

- (void)loadvCard{    
    _myvCard = [MyXMPP shareInstance].myVCardTemp;

    _photoView.layer.cornerRadius = 10;
    _photoView.layer.masksToBounds = true;
    NSString *myName = [[NSUserDefaults standardUserDefaults]stringForKey:@"name"];
    _nameLabel.text = myName;
    XMPPUserCoreDataStorageObject *user = [[MyXMPP shareInstance]fetchUserWithUsername:myName];
    
    _xmpp = [MyXMPP shareInstance];
    _status = [_xmpp myStatus];
    switch (_status) {
        case MyXMPPStatusOnline:
            _statusLabel.text = @"在线";
            break;
        case MyXMPPStatusBusy:
            _statusLabel.text = @"忙碌";
            break;
        case MyXMPPStatusOffline:
            _statusLabel.text = @"离开";
            break;
    }

//    _groupLabel.text = user.groups.allObjects[0];
    _titleLabel.text = _myvCard.title;
    _phoneLabel.text = _myvCard.note;
    _emailLabel.text = _myvCard.emailAddresses[0];
    
    _titleLabel.text = _myvCard.title ? : @"未设置";
    _phoneLabel.text = _myvCard.note ? : @"未设置";
    _emailLabel.text = _myvCard.mailer ? : @"未设置";
    _addressLabel.text = _myvCard.url ? : @"未设置";
    _zuojiLabel.text = _myvCard.uid ? : @"未设置";
    
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

    [self loadvCard];
}

- (void)viewDidAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editInfo"]) {
        EditViewController *editVC = segue.destinationViewController;
//        NSIndexPath *indexPath = sender;
        editVC.type = ((NSIndexPath *)sender).row;
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
//    NSLog(@"didFinishPickingMediaWithInfo");
    
    [self dismissViewControllerAnimated:YES completion:^{
      
    }];
}
@end
