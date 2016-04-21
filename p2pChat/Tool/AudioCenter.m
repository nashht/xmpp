//
//  Recorder.m
//  ZXKChat_2
//
//  Created by xiaokun on 15/12/20.
//  Copyright © 2015年 xiaokun. All rights reserved.
//

#import "AudioCenter.h"
#import "AppDelegate.h"
#import "VoiceConverter.h"
#import "Tool.h"

@interface AudioCenter ()

@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (copy, nonatomic) NSString *wavPath;

@end

@implementation AudioCenter

+ (instancetype)shareInstance {
    static AudioCenter *center;
    static dispatch_once_t centerToken;
    dispatch_once(&centerToken, ^{
        center = [[AudioCenter alloc]init];
    });
    return center;
}

- (void)startRecord {
    NSLog(@"AudioCenter: record start");
    NSDictionary *settings = @{AVFormatIDKey : @(kAudioFormatLinearPCM), AVSampleRateKey : @(8000.f), AVChannelLayoutKey : @(1), AVLinearPCMBitDepthKey : @(8), AVLinearPCMIsFloatKey : @(YES)};
    _wavPath = [Tool getFileName:@"tmp" extension:@"wav"];
    NSError *err = nil;
    _recorder = nil;
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryRecord error:nil];
    _recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL fileURLWithPath:_wavPath] settings:settings error:&err];
    if (err) {
        NSLog(@"AudioCenter record error: %@", err);
    }
    if([_recorder prepareToRecord]) {
        if (![_recorder record]) {
            NSLog(@"AudioCenter record failed");
        }
    } else {
        NSLog(@"AudioCenter prepare to record failed");
    }
}

- (float)stopRecord {
#warning during时长不对
    NSTimeInterval during = _recorder.currentTime;
    [_recorder stop];
    [VoiceConverter wavToAmr:_wavPath amrSavePath:_path];
    NSString *convertedWavPath = [Tool getFileName:@"receive" extension:@"wav"];
    [VoiceConverter amrToWav:_path wavSavePath:convertedWavPath];
    [self startPlay:convertedWavPath];
    return (float)during;
}

- (BOOL)isPlaying {
    return _player.isPlaying;
}

- (void)startPlay:(NSString *)path {
    NSError *err = nil;
    _player = nil;
    _player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&err];
    NSLog(@"record path: %@", path);
    if (err) {
        NSLog(@"AudioCenter play error: %@", err);
    }
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:nil];//外放
    if (![_player play]) {
        NSLog(@"AudioCenter play failed");
    }
}

- (void)stopPlay {
    [_player stop];
}

@end
