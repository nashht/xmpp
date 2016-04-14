//
//  BottomView.m
//  p2pChat
//
//  Created by xiaokun on 16/4/14.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "BottomView.h"
#import "MyXMPP.h"

@interface BottomView()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *messageTF;

@end

@implementation BottomView

- (void)awakeFromNib {
    _messageTF.delegate = self;
}

- (void)resignTextfield {
    [_messageTF resignFirstResponder];
}

- (IBAction)showRecord:(id)sender {
    [_messageTF resignFirstResponder];
}

- (IBAction)showMore:(id)sender {
    [_messageTF resignFirstResponder];
    [_delegate showMoreView];
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *message = _messageTF.text;
    if (![message isEqualToString:@""]) {
        [[MyXMPP shareInstance]sendMessage:message ToUser:_user];
        _messageTF.text = @"";
    }
    
    return YES;
}
@end
