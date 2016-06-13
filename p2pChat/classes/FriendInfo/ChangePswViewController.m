//
//  ChangePswViewController.m
//  XMPP
//
//  Created by admin on 16/6/13.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "ChangePswViewController.h"
#import "MyXMPP.h"

@interface ChangePswViewController ()

@property (weak,nonatomic) IBOutlet UITextField *newpsw;
@property (weak,nonatomic) IBOutlet UITextField *newpswagain;

@end

@implementation ChangePswViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MyXMPP *xmpp = [MyXMPP shareInstance];
    NSString *name = [[NSUserDefaults standardUserDefaults]valueForKey:@"name"];
    if (([_newpsw.text length]!=0)&&([_newpswagain.text length]!=0)) {
        BOOL result = [_newpsw.text isEqualToString: _newpswagain.text];
        
        if (result&&([name isEqualToString:xmpp.myjid.user])) {
            [[NSUserDefaults standardUserDefaults]setValue:_newpsw forKey:@"password"];
        }
        
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   }



@end
