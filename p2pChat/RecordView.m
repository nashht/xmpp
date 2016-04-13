//
//  RecordView.m
//  p2pChat
//
//  Created by xiaokun on 16/1/10.
//  Copyright © 2016年 xiaokun. All rights reserved.
//

#import "RecordView.h"
#import "AudioCenter.h"
#import "Tool.h"
#import "DataManager.h"
#import "MyXMPP.h"

@interface RecordView () {
    AudioCenter *_audioCenter;
    NSString *path_;
}
@end

@implementation RecordView

- (IBAction)startRecord:(id)sender {
    path_ = [Tool getFileName:@"send" extension:@"wav"];
    _audioCenter = [AudioCenter shareInstance];
    _audioCenter.path = path_;
    [_audioCenter startRecord];
}

- (IBAction)stopRecord:(id)sender {
    float length = [_audioCenter stopRecord];
    [[MyXMPP shareInstance]sendAudio:path_ ToUser:_username length:[NSString stringWithFormat:@"%f", length]];
}



@end