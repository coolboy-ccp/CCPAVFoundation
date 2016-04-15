//
//  WaveView.h
//  CCPAVFoundation
//
//  Created by liqunfei on 16/4/15.
//  Copyright © 2016年 chuchengpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaveView : UIView

@property (nonatomic,copy) void (^waveLevelCallBack)(WaveView *wave);
@property (nonatomic) NSUInteger numberOfWave;
@property (nonatomic) UIColor *waveColor;
@property (nonatomic) CGFloat level;
@property (nonatomic) CGFloat mainWaveWidth;
@property (nonatomic) CGFloat decorativeWavesWidth;
@property (nonatomic) CGFloat idleAmplitude;
@property (nonatomic) CGFloat frequency;
@property (nonatomic,readonly) CGFloat amplitude;
@property (nonatomic) CGFloat density;
@property (nonatomic) CGFloat phaseShift;
@property (nonatomic,readonly) NSMutableArray *waves;
@end
