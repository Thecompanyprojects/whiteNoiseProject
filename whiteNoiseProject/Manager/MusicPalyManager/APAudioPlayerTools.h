//
//  APAudioPlayerTools.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>
#import "MusicListTool.h"
#import "MusicInfo.h"


#import "APSQLiteManager.h"
#import "PlayerProtocol.h"
#import "APAudioPlayerToolsBlock.h"

#import "APAudioCountDown.h"

@interface APAudioPlayerTools : NSObject

@property(nonatomic,assign)MusicPlayType playType;

@property(nonatomic,weak)id<APAudioPlayerToolsDelegate> delegate;


+ (instancetype)shared;

/**
 播放音乐
 
 @param model model description
 @return return value description
 */

- (BOOL)playMusicFor:(NSObject <PlayerModelProtocol>*)model;

- (BOOL)playMusicForArr:(NSArray <NSObject <PlayerModelProtocol>*>*)model;
//- (void)pauseTimer;
//- (void)resumeTimer;
/**
 暂停播放
 
 */
- (void)pauseMusic;

/**
 继续播放
 */
- (void)resumePlay;


/**
 停止播放(停止和暂停，注意区分)
 
 */
- (void)stopMusic;

- (void)stopForModel:(NSObject <PlayerModelProtocol>*)model;
/**
 调节音量
 
 @param volume volume description
 */
- (void)adjustVolume:(float)volume WithlModel:(NSObject <PlayerModelProtocol>*)model;
//- (void)adjustVolume:(float)volume;

/**
 设置倒计时
 
 @param countDown 秒
 */
- (void)configCountDown:(NSInteger)countDown;

- (void)configCountDownIsAuto;

/**
 获取剩余倒计时时间
 
 @return return value description
 */
- (NSInteger)getTimeLeft;
- (NSInteger)getCountDown;
//销毁定时器
- (void)invalidateTimer;
//暂停定时器
- (void)stopTimer;
//恢复或者开始定时器
- (void)beginTimer;

@end
