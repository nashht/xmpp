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

@interface RecordView () {
    AudioCenter *_audioCenter;
}
@end

@implementation RecordView

- (IBAction)startRecord:(id)sender {
    NSString *path = [Tool getFileName:@"send" extension:@"caf"];
    _audioCenter = [AudioCenter shareInstance];
    _audioCenter.path = path;
    [_audioCenter startRecord];
}

- (IBAction)stopRecord:(id)sender {
    [[AudioCenter shareInstance] stopRecord];
}
@end