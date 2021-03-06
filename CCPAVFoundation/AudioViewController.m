//
//  AudioViewController.m
//  CCPAVFoundation
//
//  Created by liqunfei on 16/4/14.
//  Copyright © 2016年 chuchengpeng. All rights reserved.
//

#import "AudioViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

void (^blockForTip)(NSString *message) = ^(NSString *str) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tips:" message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
};

@interface AudioViewController ()<AVAudioPlayerDelegate,AVAudioRecorderDelegate>
@property (weak, nonatomic) IBOutlet UIView *musicView;
@property (weak, nonatomic) IBOutlet UIProgressView *musicProgress;
@property (weak, nonatomic) IBOutlet UILabel *musicNameLabel;
@property (strong,nonatomic) AVAudioPlayer *audioPlayer;
@property (strong,nonatomic) NSString *musicName;
@property (strong,nonatomic) NSTimer *progressTimer;
@property (weak, nonatomic) IBOutlet UIView *recorderView;
@property (strong,nonatomic) AVAudioRecorder *recorder;
@property (strong,nonatomic) AVAudioPlayer *recorderPlayer;

@end

@implementation AudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAudioSession];
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [touches.anyObject locationInView:self.view];
    if (!CGRectContainsPoint(self.musicView.frame, point)) {
        [UIView animateWithDuration:0.5 animations:^{
            self.musicView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.musicView.hidden = YES;
        }];
    }
    if (!CGRectContainsPoint(self.recorderView.frame, point)) {
        [UIView animateWithDuration:0.5 animations:^{
            self.recorderView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.recorderView.hidden = YES;
        }];
    }
}


- (IBAction)soundEffectAction:(UIButton *)sender {
    switch (sender.tag) {
        case 100:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 101:
            [self playSoundEffect:@"soundEffect.wav"];
            break;
        case 102:
        {
            self.musicView.hidden = NO;
            [UIView animateWithDuration:0.5 animations:^{
                self.musicView.alpha = 0.9f;
            }];
        }
            break;
        case 103:
        {
            self.recorderView.hidden = NO;
            [UIView animateWithDuration:0.5 animations:^{
                self.recorderView.alpha = 0.9f;
            }];
        }
        default:
            break;
    }
    
}

/*
 音效
 AudioToolbox.framework,基于c语言的框架，使用限制:
 1.时长不能超过30s
 2.数据为PCM || IMA4格式
 3.音频文件必须打包成.caf、.aif、.wav中的一种(.mp3也可以播放)
 */

void soundCompletedCallBack(SystemSoundID soundID,void *clientData) {
    blockForTip(@"soundPlayed");
}

- (void)playSoundEffect:(NSString *)name {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundID);
    //注册播放完成后执行操作的回调函数
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompletedCallBack, NULL);
    //播放音效
    AudioServicesPlaySystemSound(soundID);
    //播放音效并震动
    //AudioServicesPlayAlertSound(soundID)；
}

/*
 音乐
 AVAudioPlayer
 */

- (void)createPlayerWithName:(NSString *)name {
    if (!_audioPlayer) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:nil];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        NSError *error = nil;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
        _audioPlayer.numberOfLoops = 0;
        _audioPlayer.delegate = self;
        [_audioPlayer prepareToPlay];
        if (error) {
            blockForTip([NSString stringWithFormat:@"error:%@",error.localizedDescription]);
        }
    }
}

- (NSTimer *)progressTimer {
    if (!_progressTimer) {
        _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updataProgress:) userInfo:nil repeats:YES];
    }
    return _progressTimer;
}

- (void)updataProgress:(NSTimer *)timer {
    float progress = self.audioPlayer.currentTime / self.audioPlayer.duration;
    [self.musicProgress setProgress:progress];
}

- (NSString *)musicName {
    _musicName = [_musicName isEqualToString:@"年轮.mp3"] ? @"月亮可以代表我的心.mp3" : @"年轮.mp3";
    self.musicNameLabel.text = _musicName;
    return _musicName;
}

- (IBAction)musicActions:(UIButton *)sender {
    switch (sender.tag) {
        case 200:
        {
            _musicName = _musicName ? _musicName : @"年轮.mp3";
            UIButton *btn = [self.musicView viewWithTag:201];
            btn.selected = YES;
            self.audioPlayer = nil;
            self.musicProgress.progress = 0.0;
            [self createPlayerWithName:self.musicName];
            [self.audioPlayer play];
            self.progressTimer.fireDate = [NSDate distantPast];
        }
            break;
        case 201:
        {
            sender.selected = !sender.selected;
            if (sender.selected) {
                [self createPlayerWithName:self.musicName];
                [self.audioPlayer play];
                self.progressTimer.fireDate = [NSDate distantPast];
            }
            else {
                [self.audioPlayer pause];
                self.progressTimer.fireDate = [NSDate distantFuture];
            }
        }
            break;
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    blockForTip([NSString stringWithFormat:@"%@播放完成",self.musicName]);
    self.progressTimer.fireDate = [NSDate distantFuture];
    UIButton *btn = [self.musicView viewWithTag:201];
    btn.selected = NO;
}

/*
 录音
 
 */

- (void)setAudioSession {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:YES error:nil];
}

- (NSURL *)getSavePath {
    NSString *urlStr = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"ccp/recoderDemo.caf"];
    return [NSURL fileURLWithPath:urlStr];
}

- (NSDictionary *)getAudioSetting {
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    //录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //录音采样率
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //录音通道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数，分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    return dicM;
}

- (AVAudioRecorder *)recorder {
    if (!_recorder) {
        NSError *error = nil;
        _recorder = [[AVAudioRecorder alloc] initWithURL:[self getSavePath] settings:[self getAudioSetting] error:&error];
        _recorder.delegate = self;
        //声波检测
        _recorder.meteringEnabled = YES;
        if (error) {
            blockForTip([NSString stringWithFormat:@"error:%@",error.localizedDescription]);
            return nil;
        }
    }
    return _recorder;
}

- (IBAction)recorderController:(UIButton *)sender {
    switch (sender.tag) {
        case 301:
        {
            if (![self.recorder isRecording]) {
                [self.recorder record];
            }
        }
            break;
        case 302:
        {
            sender.selected = !sender.selected;
            if (sender.selected) {
                [self.recorder pause];
            }
            else {
                UIButton *btn = [self.recorderView viewWithTag:301];
                [self recorderController:btn];
            }
        }
            break;
        case 303:
        {
            [self.recorder stop];
        }
            break;
            
        default:
            break;
    }
}

- (AVAudioPlayer *)recorderPlayer {
    if (!_recorderPlayer) {
        NSError *error = nil;
        _recorderPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[self getSavePath] error:&error];
        _recorderPlayer.numberOfLoops = 0;
        [_recorderPlayer prepareToPlay];
        if (error) {
            blockForTip([NSString stringWithFormat:@"error:%@",error.localizedDescription]);
            return nil;
        }
    }
    return _recorderPlayer;
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (![self.recorderPlayer isPlaying]) {
        [self.recorderPlayer play];
    }
    
}

- (void)dealloc {
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}

@end
