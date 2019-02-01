//
//  AudioCountDown.m
//  XToolWhiteNoiseIOS
//
//  Created by 郭连城 on 2018/8/1.
//  Copyright © 2018年 小叶科技. All rights reserved.
// 定时器功能

/*
 1 定时
 2 暂停
 3 恢复
 */

#import "APAudioPlayerTools.h"
#import "APAudioCountDown.h"

typedef NS_ENUM(NSInteger,AudioCountDownStatus) {
    AudioCountDownStatusIsNone,
    AudioCountDownStatusIsStop,
    AudioCountDownStatusIsRun
};


@interface APAudioCountDown(){
    NSDate *_beginTime;
    
    NSDate *_pauseTime;  //暂停时刻的时间
    NSDate *_resumeTimer; //恢复时刻的时间 开始之后要 _beginTime = _beginTime +（_resumeTimer - _pauseTime）
    BOOL _isAutoClose;//是否是自动关闭
    
    AudioCountDownStatus _countDownStatus;//计时器当前状态
}

@property (nonatomic, strong) NSTimer *timer;



@property (nonatomic, weak) id<APAudioCountDownDelegate>delegate;

@end

@implementation APAudioCountDown

-(void)beginTimer{
    [self resumeTimer];
}


-(void)stopTimer{
    [self pauseTimer];
}

//暂停
-(void)pauseTimer{
    if (![self.timer isValid]) {
        return ;
    }
    if (_countDownStatus == AudioCountDownStatusIsStop){
        return;
    }
    
    _pauseTime = [NSDate date];
    [self.timer setFireDate:[NSDate distantFuture]];
    _countDownStatus = AudioCountDownStatusIsStop;
}

//恢复
-(void)resumeTimer{
    if (![self.timer isValid]) {
        return ;
    }
    if (_countDownStatus == AudioCountDownStatusIsNone){//开始
        _beginTime = [NSDate date];
    }else{
        
        //        NSInteger timeLeft = [self getTimeLeft];
        //        if (timeLeft <= 0){  return; }
        
        _resumeTimer = [NSDate date];
        
        NSTimeInterval newBeginTime = _beginTime.timeIntervalSince1970 + (_resumeTimer.timeIntervalSince1970 - _pauseTime.timeIntervalSince1970);
        
        _beginTime = [[NSDate alloc]initWithTimeIntervalSince1970:newBeginTime];
    }
    //    _beginTime = _beginTime +（_resumeTimer - _pauseTime）
    [self.timer setFireDate:[NSDate date]];
    
    _countDownStatus = AudioCountDownStatusIsRun;
}



- (void)invalidate{
    _countDownStatus = AudioCountDownStatusIsNone;
    [self.timer invalidate];
}

- (void)setDelegate:(id<APAudioCountDownDelegate>)delegate withCountDown:(NSInteger)countDown{
    if (countDown == -1) {
        _isAutoClose = YES;
        int value = (arc4random() % 10) + 45*60*60;
        self.countDown = value;
    }else{
        self.countDown = countDown;
        self.timeSpent = 0;
    }
    
    _countDownStatus = AudioCountDownStatusIsNone;
    self.delegate = delegate;
    
    
    _beginTime = [NSDate date];
    
    [self initTimer:0.5];
    [self.timer setFireDate:[NSDate distantFuture]];
    [self handleTimer];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        
        NSNotificationCenter * notif = [NSNotificationCenter defaultCenter];
        [notif addObserver:self
                  selector:@selector(becomeActive)
                      name:UIApplicationDidBecomeActiveNotification
                    object:nil];
        
        [notif addObserver:self
                  selector:@selector(enterBackGround) name:UIApplicationDidEnterBackgroundNotification
                    object:nil];
        
        [notif addObserver:self
                  selector:@selector(becomeUnavailable) name:UIApplicationProtectedDataWillBecomeUnavailable
                    object:nil];
        [notif addObserver:self
                  selector:@selector(becomeAvailable) name:UIApplicationProtectedDataDidBecomeAvailable
                    object:nil];
        _countDownStatus = AudioCountDownStatusIsNone;
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)becomeUnavailable{
    NSLog(@"锁屏");
    if (_isAutoClose){
        //监听锁屏通知，每次锁屏把自动关闭时间置成50分钟
        _beginTime = [NSDate date];
    }
}

-(void)becomeAvailable{
    NSLog(@"解锁");
}


-(void)becomeActive{
    if (_countDownStatus == AudioCountDownStatusIsRun){
        [self initTimer:0.5];
    }
    NSLog(@"程序进入前台");
    
    if(_countDownStatus == AudioCountDownStatusIsStop){
        NSLog(@"音乐暂停中，不更新界面");
        return;
    }
    
    NSTimeInterval timeBetween = [[NSDate date]timeIntervalSinceDate:_beginTime];
    if (timeBetween >self.countDown){
        timeBetween = self.countDown;
    }
    if ([self.delegate respondsToSelector:@selector(audioCurrentProgress:WithTotalCount:)]){
        [self.delegate audioCurrentProgress:timeBetween WithTotalCount:self.countDown];
    }
}

-(void)enterBackGround{
    if (_countDownStatus == AudioCountDownStatusIsRun){
        [self.timer invalidate];
        [self initTimer:60];
    }
    NSLog(@"程序进入后台");
}
//获取剩余倒计时
- (NSInteger)getTimeLeft{
    NSTimeInterval timeBetween = [[NSDate date]timeIntervalSinceDate:_beginTime];
    if (timeBetween >= self.countDown){
        return 0;
    }else{
        return self.countDown - timeBetween;
    }
}

//定时操作，更新UI
- (void)handleTimer {
    
    NSTimeInterval timeBetween = [[NSDate date]timeIntervalSinceDate:_beginTime];
    
    
    //    NSLog(@"两时间差值%f",timeBetween);
    if (timeBetween >= self.countDown){
        NSLog(@"倒计时结束");
        timeBetween = self.countDown;
        [self.timer invalidate];
    }else{
        if (!self.countDown){
            [self.timer invalidate];
        }
    }
    
    if ((int)(timeBetween) > self.timeSpent || (int)(timeBetween) == 0){
        
        //        NSLog(@"倒计时%d,总时间%ld",(int)(timeBetween),(long)self.countDown);
        self.timeSpent = timeBetween;
        if ([self.delegate respondsToSelector:@selector(audioCurrentProgress:WithTotalCount:)]){
            [self.delegate audioCurrentProgress:timeBetween WithTotalCount:self.countDown];
        }
    }
}

- (void)initTimer:(NSTimeInterval)timeInterval{
    
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
    
}

//-(BOOL)didUserPressLockButton{
//    //获取屏幕亮度
//    CGFloat oldBrightness = [UIScreen mainScreen].brightness;
//    //以较小的数量改变屏幕亮度
//    [UIScreen mainScreen].brightness = oldBrightness + (oldBrightness <= 0.01 ? (0.01) : (-0.01));
//    CGFloat newBrightness  = [UIScreen mainScreen].brightness;
//    //恢复屏幕亮度
//    [UIScreen mainScreen].brightness = oldBrightness;
//    //判断屏幕亮度是否能够被改变
//    return oldBrightness != newBrightness;
//}

@end
