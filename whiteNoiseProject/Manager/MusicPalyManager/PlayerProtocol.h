
#import <Foundation/Foundation.h>

@protocol APAudioPlayerToolsDelegate <NSObject>

/**
 播放被中断
 */
@optional

- (void)playbackStopped;

/**
 中断结束，开始播放
 */
- (void)playbackBegan;

/**
 某一首歌曲播放完毕
 */
- (void)playerDidFinishPlaying;

/**
 某一首歌曲开始播放
 */
- (void)playerBeginPaly;

/**
 倒计时时间回调(秒)
 */
- (void)playCurrentProgress:(NSInteger)second WithTotalCount:(NSInteger)totalSecond;

@end

@protocol PlayerModelProtocol <NSObject>

/// 歌曲的文件名，带后缀
@property (nonatomic, strong) NSString * mp3FileName;
/// 根据当前语言环境提供语言
@property (nonatomic, strong) NSString * name;
///自然音效用的音量
@property (nonatomic, assign) CGFloat volume;

/// 歌曲播放页背景图片Url
//@property (nonatomic, strong) NSString * backGroundImageUrl;

@end
