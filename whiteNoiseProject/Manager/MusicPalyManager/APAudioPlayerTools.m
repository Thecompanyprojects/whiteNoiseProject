//
//  APAudioPlayerTools.m
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <objc/runtime.h>
#import "APAudioPlayerTools.h"
#import "APDownloadPathHelper.h"
#import "APSoundDownloadConfig.h"
#import "APSoundDownloadManager.h"

#import <whiteNoiseProject-Swift.h>

#import <MediaPlayer/MediaPlayer.h>
//static char *musicName;
static char musicName;

const int MaxPlayerCount = 1;

@interface APAudioPlayerTools()<AVAudioPlayerDelegate,APAudioCountDownDelegate>
///当前播放
//@property(nonatomic,strong,readonly)NSObject <PlayerModelProtocol> *currentPaly;

///储存当前播放的音乐
@property(nonatomic,strong) NSMutableDictionary<NSString *,AVAudioPlayer *> *musicPlayers;

@property(nonatomic,strong)APAudioCountDown *timer;

@end


@implementation APAudioPlayerTools

static APAudioPlayerTools *instance;

+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[APAudioPlayerTools alloc]init];
    });
    return instance;
}

//+ (void)initialize{}
- (void)dealloc{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)init{
    __block APAudioPlayerTools *temp = self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ((temp = [super init]) != nil) {
            self->_musicPlayers = [NSMutableDictionary dictionary];
            
            //            self->_currentPaly = [MusicInfo new];
            // 音频会话
            AVAudioSession *session = [AVAudioSession sharedInstance];
            // 设置会话类型（播放类型、播放模式,会自动停止其他音乐的播放）
            [session setCategory:AVAudioSessionCategoryPlayback error:nil];
            // 激活会话
            [session setActive:YES error:nil];
            
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            
            [center addObserver:self
                       selector:@selector(handleInterruption:)
                           name:AVAudioSessionInterruptionNotification
                         object:[AVAudioSession sharedInstance]];
            [center addObserver:self
                       selector:@selector(handleRouteChange:)
                           name:AVAudioSessionRouteChangeNotification
                         object:[AVAudioSession sharedInstance]];
            [center addObserver:self
                       selector:@selector(handleMusicDownloadFinish:)
                           name:MusicDownloadFinishNotification
                         object:nil];
            [center addObserver:self
                       selector:@selector(handleMusicUpdateFinish:)
                           name:MusicInfoUpdateFinishNotification
                         object:nil];
        }
    });
    self = temp;
    return self;
}

- (void)configCountDown:(NSInteger)countDown{
    [self.timer setDelegate:self withCountDown:countDown];
}

- (NSInteger)getCountDown{
    return self.timer.countDown;
}
- (NSInteger)getTimeLeft{
    return [self.timer getTimeLeft];
}

- (void)invalidateTimer{
    [self.timer invalidate];
}

- (void)stopTimer{
    [self.timer stopTimer];
}


- (void)beginTimer{
    [self.timer beginTimer];
}

- (void)configCountDownIsAuto{
    [self.timer setDelegate:self withCountDown:-1];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

//MARK:- 模型属性更新数据库后通知
- (void)handleMusicUpdateFinish:(NSNotification *)notification{
    
}

//MARK:-音乐下载完成通知
- (void)handleMusicDownloadFinish:(NSNotification *) notification{
    NSDictionary *info = notification.object;
    if (info == nil){ return; }
}

#pragma todo:- 播放音乐
- (BOOL)playMusicForArr:(NSArray <NSObject <PlayerModelProtocol>*>*)models{
    //    [self stopMusic];
    BOOL playSuccess = false;
    for (NSObject <PlayerModelProtocol>* model in models){
        playSuccess =  [self playMusic:model];
    }
    return  playSuccess;
}


- (BOOL)playMusicFor:(NSObject <PlayerModelProtocol>*)model{
    
    //    _currentPaly.isPlay = NO;
    //    [self stopMusic];//清空之前的播放。
    //    model.isPlay = YES;
    //    _currentPaly = model;
    return [self playMusic:model];
    
}

- (BOOL)playMusic:(NSObject <PlayerModelProtocol>*)playMusic{
    
    AVAudioPlayer *player = self.musicPlayers[playMusic.name];
    
    if (!player){//如果没有缓存，需要创建并加到缓存中
        NSURL *url = [[NSBundle mainBundle] URLForResource:playMusic.mp3FileName withExtension:nil];
        if (!url){
            NSString *path = [APDownloadPathHelper downloadPath];
            // NSString * encodingString = [playMusic.mp3FileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
            NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
            NSString * encodingString = [playMusic.mp3FileName stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
            
            path = [path stringByAppendingPathComponent:encodingString];
            
            url = [NSURL URLWithString:path];
        }
        
        if (!url) {
            NSLog(@"音乐URL为空");
            return NO;
        }
        NSError *error;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        if (![player prepareToPlay]) return NO;
        if (error) NSLog(@"player Error:%@",error.description);
        
        objc_setAssociatedObject(player, &musicName, playMusic.name, OBJC_ASSOCIATION_COPY_NONATOMIC);
        player.volume = playMusic.volume;
        if (playMusic.volume >1){
            NSLog(@"--------------音量过大:%f",playMusic.volume);
        }
        player.numberOfLoops = -1;//循环播放
        self.musicPlayers[playMusic.name] = player;
        
        player.delegate = self;
    }
    
    if ([self.delegate respondsToSelector:@selector(playerBeginPaly)]){
        [self.delegate playerBeginPaly];
    }
    
    if (![player isPlaying]) {  //如果没有正在播放，那么开始播放，如果正在播放，那么不需要改变什么
        [player lc_play];
    }
    return YES;
}


- (void)resumePlay{
    for (AVAudioPlayer *player in self.musicPlayers.allValues){
        if (![player isPlaying]) {
            [player lc_play];
        }
    }
    [self.timer beginTimer];
}

- (void)pauseMusic{
    for (AVAudioPlayer *player in self.musicPlayers.allValues){
        if ([player isPlaying]) {
            [player pause];
        }
    }
    [self.timer stopTimer];
}

- (void)stopMusic{
    for (AVAudioPlayer *player in self.musicPlayers.allValues){
        [player lc_stop];
    }
    //    [self.timer invalidate];
    [self.musicPlayers removeAllObjects];
}

- (void)stopForModel:(NSObject <PlayerModelProtocol>*)model{
    [self.musicPlayers[model.name] lc_stop];
    //        [self.timer invalidate];
    [self.musicPlayers removeObjectForKey:model.name];
}


- (void)adjustVolume:(float)volume WithlModel:(NSObject <PlayerModelProtocol>*)model{
    if (volume >1){
        NSLog(@"--------------音量过大:%f",volume);
    }
    AVAudioPlayer *player = self.musicPlayers[model.name];
    [player setVolume:volume];
}


//MARK:-线路变化通知
- (void)handleRouteChange:(NSNotification *) notification{
    NSLog(@"进入线路变化通知");
    NSDictionary *info = notification.userInfo;
    AVAudioSessionRouteChangeReason reason = [info[AVAudioSessionRouteChangeReasonKey] unsignedIntValue];
    /****************************************/
    switch (reason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            NSLog(@"耳机插入(蓝牙音响不知道算不算)");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            NSLog(@"耳机拔出，停止播放操作");
            
            [self pauseMusic];
            if ([self.delegate respondsToSelector:@selector(playbackStopped)]){
                [self.delegate playbackStopped];
            }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
        default:  break;
    }
}

//MARK:- 线路中断通知
- (void)handleInterruption:(NSNotification *)notification{
    
    NSLog(@"进入线路中断通知");
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType type =  [info[AVAudioSessionInterruptionTypeKey] unsignedIntValue];
    
    if (type == AVAudioSessionInterruptionTypeBegan){
        //        [self pauseMusic];
        if ([self.delegate respondsToSelector:@selector(playbackStopped)]){
            [self.delegate playbackStopped];
        }
        NSLog(@"中断开始");
    }else{
        AVAudioSessionInterruptionOptions options = [info[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume){
            //            [self resumePlay];
            NSLog(@"中断结束");
            if ([self.delegate respondsToSelector:@selector(playbackBegan)]){
                [self.delegate playbackBegan];
            }
        }
    }
}


//MARK:- AVAudioPlayerDelegate

// 音频播放完成时
//- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
//    // 音频播放完成时，调用该方法。
//    // 参数flag：如果音频播放无法解码时，该参数为NO。
//    //当音频被中断时，可以实现AVAudioSessionDelegate ，也可以监听通知
//    NSString *name = objc_getAssociatedObject(player, &musicName);
//    NSLog(@"%@音频播放完成%@",name,player);
//    switch (self.playType) {
//        case MusicPlayType_SingleCycle:
//            [self playMusicFor:Switch_current];
//            break;
//        case MusicPlayType_ListCycle:
//            [self playMusicFor:Switch_next];
//            break;
//        case MusicPlayType_PlayInOrder:{
//            if (self.playList.lastObject != _currentPaly){
//                [self playMusicFor:Switch_next];
//            };} break;
//    }
//
//    if ([self.delegate respondsToSelector:@selector(playerDidFinishPlaying)]){
//        [self.delegate playerDidFinishPlaying];
//    }
//}


- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSString *name = objc_getAssociatedObject(player, &musicName);
    NSLog(@"%@解码错误%@",name,error.description);
}

//MARK:- 倒计时回调
- (void)audioCurrentProgress:(NSInteger)count WithTotalCount:(NSInteger)totalCount{
    if ([self.delegate respondsToSelector:@selector(playCurrentProgress:WithTotalCount:)]){
        [self.delegate playCurrentProgress:count WithTotalCount:totalCount];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo]];
    
    [dict setObject:[NSNumber numberWithDouble:count] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime]; //音乐当前已经过时间
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    
}

//MARK:- Lazy loading Method  懒加载
- (MusicPlayType)playType{
    if (!_playType){
        _playType = MusicPlayType_PlayInOrder;
    }
    return _playType;
}

- (APAudioCountDown *)timer{
    if (!_timer){
        _timer = [APAudioCountDown new];
    }
    return _timer;
}
@end
