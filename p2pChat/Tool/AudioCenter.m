//
//  Recorder.m
//  ZXKChat_2
//
//  Created by xiaokun on 15/12/20.
//  Copyright © 2015年 xiaokun. All rights reserved.
//

#import "AudioCenter.h"
#import "AppDelegate.h"

@interface AudioCenter ()

@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;

@end

@implementation AudioCenter

+ (instancetype)shareInstance {
//    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
//    AudioCenter *center = delegate.audioCenter;
    static AudioCenter *center;
    static dispatch_once_t centerToken;
    dispatch_once(&centerToken, ^{
        center = [[AudioCenter alloc]init];
    });
    return center;
}

- (void)startRecord {
    NSLog(@"AudioCenter: record start");
    NSDictionary *settings = @{AVFormatIDKey : @(kAudioFormatiLBC), AVSampleRateKey : @(8000), AVChannelLayoutKey : @(1), AVLinearPCMBitDepthKey : @(8), AVLinearPCMIsFloatKey : @(YES)};
    NSError *err = nil;
    _recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL fileURLWithPath:_path] settings:settings error:&err];
    if (err) {
        NSLog(@"AudioCenter record error: %@", err);
    }
    [_recorder record];
}

- (float)stopRecord {
    NSTimeInterval during = _recorder.currentTime;
    [_recorder stop];
    [self startPlay];
    return (float)during;
}

- (void)startPlay {
    NSError *err = nil;
    _player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:_path] error:&err];
    NSLog(@"record path: %@", _path);
    if (err) {
        NSLog(@"AudioCenter play error: %@", err);
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];//以上两句话用来让声音外放
    [_player play];
}
@end
