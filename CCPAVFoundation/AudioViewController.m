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

@interface AudioViewController ()<AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIView *musicView;
@property (weak, nonatomic) IBOutlet UIProgressView *musicProgress;
@property (weak, nonatomic) IBOutlet UILabel *musicNameLabel;
@property (strong,nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation AudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)musicActions:(UIButton *)sender {
    switch (sender.tag) {
        case 200:
            
            break;
        case 201:
        {
            sender.selected = !sender.selected;
            if (sender.selected) {
                [self.audioPlayer play];
            }
        }
            break;
        default:
            break;
    }
}

@end
