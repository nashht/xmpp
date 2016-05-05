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
#import "RegularExpressionTool.h"
#import "AudioCenter.h"
#import "Tool.h"

#define BUTTONSIZE 35

@interface BottomView()<UITextFieldDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (strong, nonatomic) UIButton *recordBtn;
@property (assign, nonatomic) BOOL showRecord;
@property (copy, nonatomic) NSString *recordPath;

@end

@implementation BottomView

- (void)awakeFromNib {
    _messageTextView.delegate = self;
    _messageTextView.returnKeyType = UIReturnKeyDone;
    _messageTextView.layer.borderColor = [[UIColor colorWithRed:215.0 / 255.0 green:215.0 / 255.0 blue:215.0 / 255.0 alpha:1] CGColor];
    _messageTextView.layer.borderWidth = 0.6f;
    _messageTextView.layer.cornerRadius = 6.0f;
    _messageTextView.font = [UIFont systemFontOfSize:16.f];
    
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

- (void)inputFaceView:(NSString *)faceName{
    NSLog(@"faceviewname--%@",faceName);
    // 获得光标所在的位置
    long location = _messageTextView.selectedRange.location;
    // 将UITextView中的内容进行调整（主要是在光标所在的位置进行字符串截取，再拼接你需要插入的文字即可）
    NSString *content = _messageTextView.text;
//   e.g. [p/_002.png]
    NSString *result = [NSString stringWithFormat:@"%@[p/%@.png]%@",[content substringToIndex:location],faceName,[content substringFromIndex:location]];
//    _messageBody = result;
//    NSLog(@"_messageBody%@",result);
    
    _messageTextView.text = result;
//    
//    NSAttributedString *attributedString = [RegularExpressionTool stringTranslation2FaceView:result];
//    // 将调整后的字符串添加到UITextView上面
//    _messageTextView.attributedText = attributedString;
}

- (void)resignTextfield {
    [_messageTextView resignFirstResponder];
}

- (IBAction)showFaceView:(id)sender {
    [_messageTextView resignFirstResponder];
    [_delegate showFaceView];
}

- (IBAction)showRecord:(id)sender {
    [_messageTextView resignFirstResponder];
    _recordBtn.hidden = !_recordBtn.hidden;
    _messageTextView.hidden = !_messageTextView.hidden;
    [_delegate hideMoreView];
}

- (IBAction)showMore:(id)sender {
    [_messageTextView resignFirstResponder];
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


#pragma mark - text view delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        NSString *message = _messageTextView.text;
        if (![message isEqualToString:@""]) {
            if ([self isP2PChat]) {
                [[MyXMPP shareInstance]sendMessage:message ToUser:_chatObjectString];
            } else {
                [[MyXMPP shareInstance]sendMessage:message ToGroup:_chatObjectString];
            }
            
            _messageTextView.text = @"";
//            _messageBody = @"";
        }
        return NO;
    }
    return YES;
}
@end
