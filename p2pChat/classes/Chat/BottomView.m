//
//  BottomView.m
//  p2pChat
//
//  Created by xiaokun on 16/4/14.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "BottomView.h"
#import "MyXMPP+P2PChat.h"
#import "MyXMPP+Group.h"
#import "AudioCenter.h"
#import "Tool.h"

#define BUTTONSIZE 35

@interface BottomView()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *messageTF;
@property (strong, nonatomic) UIButton *recordBtn;
@property (assign, nonatomic) BOOL showRecord;
@property (copy, nonatomic) NSString *recordPath;

@end

@implementation BottomView

- (void)awakeFromNib {
    _messageTF.delegate = self;
    
    [self initRecordBtn];
}

- (void)initRecordBtn {
    CGRect recordBtnFrame = CGRectMake(BUTTONSIZE, 5, [UIScreen mainScreen].bounds.size.width - BUTTONSIZE * 3, 30);
    _recordBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _recordBtn.frame = recordBtnFrame;
    [_recordBtn setTitle:@"按住说话" forState:UIControlStateNormal];
    _recordBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_recordBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_recordBtn addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchDown];
    [_recordBtn addTarget:self action:@selector(stopRecord) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_recordBtn];
    _recordBtn.hidden = YES;
    _showRecord = NO;
}

- (void)resignTextfield {
    [_messageTF resignFirstResponder];
}

- (IBAction)showFaceView:(id)sender {
    [_messageTF resignFirstResponder];
    [_delegate showFaceView];
}

- (IBAction)showRecord:(id)sender {
    [_messageTF resignFirstResponder];
    _recordBtn.hidden = !_recordBtn.hidden;
    _messageTF.hidden = !_messageTF.hidden;
    [_delegate hideMoreView];
}

- (IBAction)showMore:(id)sender {
    [_messageTF resignFirstResponder];
    [_delegate showMoreView];
}



- (void)startRecord {
    NSLog(@"start record");
    _recordPath = [Tool getFileName:@"send" extension:@"wav"];
    AudioCenter *audioCenter = [AudioCenter shareInstance];
    audioCenter.path = _recordPath;
    [audioCenter startRecord];
}

- (void)stopRecord {
    NSLog(@"stop record");
    float length = [[AudioCenter shareInstance] stopRecord];
    if ([self isP2PChat]) {
        [[MyXMPP shareInstance]sendAudio:_recordPath ToUser:_chatObjectString length:[NSString stringWithFormat:@"%f", length]];
    } else {
        [[MyXMPP shareInstance]sendAudio:_recordPath ToGroup:_chatObjectString withlength:[NSString stringWithFormat:@"%f", length]];
    }
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *message = _messageTF.text;
    if (![message isEqualToString:@""]) {
        if ([self isP2PChat]) {
            [[MyXMPP shareInstance]sendMessage:message ToUser:_chatObjectString];
        } else {
            [[MyXMPP shareInstance]sendMessage:message ToGroup:_chatObjectString];
        }
        
        _messageTF.text = @"";
    }
    
    return YES;
}
@end
