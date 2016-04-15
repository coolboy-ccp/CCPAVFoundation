//
//  WaveView.m
//  CCPAVFoundation
//
//  Created by liqunfei on 16/4/15.
//  Copyright © 2016年 chuchengpeng. All rights reserved.
//

#import "WaveView.h"

@interface WaveView()
@property (nonatomic)CGFloat phase;
@property (nonatomic)CGFloat amplitude;
@property (nonatomic)CGFloat waveHeight;
@property (nonatomic)CGFloat waveWidth;
@property (nonatomic)CGFloat waveMid;
@property (nonatomic)CGFloat maxAmplitude;
@property (nonatomic)NSMutableArray *waves;
@property (nonatomic,strong) CADisplayLink *displayLink;

@end

@implementation WaveView

- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.waves = [NSMutableArray new];
        self.frequency = 1.2f;
        self.amplitude = 1.0f;
        self.numberOfWave = 5;
        self.phaseShift = -0.25f;
        self.density = 1.0f;
        self.waveColor = [UIColor whiteColor];
        self.mainWaveWidth = 2.0f;
        self.decorativeWavesWidth = 1.0f;
        self.waveHeight = CGRectGetHeight(self.bounds);
        self.waveWidth = CGRectGetWidth(self.bounds);
        self.waveMid = self.waveWidth / 2;
        self.maxAmplitude = self.waveHeight - 4.0f;
    }
    return self;
}

- (void)setWaveLevelCallBack:(void (^)(WaveView *))waveLevelCallBack {
    _waveLevelCallBack = waveLevelCallBack;
    [self.displayLink invalidate];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(invokeWaveCallback)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    for (int i = 0; i < self.numberOfWave; i++) {
        CAShapeLayer *waveLine = [CAShapeLayer layer];
        waveLine.lineCap = kCALineCapButt;
        waveLine.lineJoin = kCALineJoinRound;
        waveLine.strokeColor = [UIColor clearColor].CGColor;
        waveLine.fillColor = [UIColor clearColor].CGColor;
        [waveLine setLineWidth:(i == 0 ? self.mainWaveWidth : self.decorativeWavesWidth)];
        CGFloat progress = 1.0f - (CGFloat)i / self.numberOfWave;
        CGFloat multiplier = MIN(1.0,(progress / 3.0 * 2.0) + (1.0 / 3.0));
        UIColor *color = [self.waveColor colorWithAlphaComponent:(i == 0 ? 1.0 : multiplier * 0.4)];
        waveLine.strokeColor = color.CGColor;
        [self.layer addSublayer:waveLine];
        [self.waves addObject:waveLine];
    }
}

- (void)setLevel:(CGFloat)level {
    _level = level;
    self.phase += self.phaseShift;
    self.amplitude = fmax(level, self.idleAmplitude);
    [self updataMeters];
}

- (void)invokeWaveCallback {
    self.waveLevelCallBack(self);
}

- (void)updataMeters {
    self.waveHeight = CGRectGetHeight(self.bounds);
    self.waveWidth = CGRectGetWidth(self.bounds);
    self.waveMid = self.waveWidth / 2.0f;
    self.maxAmplitude = self.waveHeight - 4.0f;
    UIGraphicsBeginImageContext(self.bounds.size);
    for (int i = 0; i < self.numberOfWave; i++) {
        UIBezierPath *wavePath = [UIBezierPath bezierPath];
        CGFloat progress = 1.0f - (CGFloat)i / self.numberOfWave;
        CGFloat normedAmplitude = (1.5f * progress - 0.5f) * self.amplitude;
        for (CGFloat x = 0; x < self.waveHeight + self.density; x += self.density) {
            CGFloat scal = -pow(x / self.waveMid - 1, 2) + 1;
            CGFloat y  = scal * self.maxAmplitude * normedAmplitude * sinf(2 * M_PI * (x / self.waveWidth) * self.frequency + self.phase) + self.waveHeight * 0.5;
            if (x == 0) {
                [wavePath moveToPoint:CGPointMake(x, y)];
            }
            else {
                [wavePath addLineToPoint:CGPointMake(x, y)];
            }
        }
        CAShapeLayer *waveLine = [self.waves objectAtIndex:i];
        waveLine.path = wavePath.CGPath;
    }
    UIGraphicsEndImageContext();
}

- (void)dealloc {
    [_displayLink invalidate];
}

@end
