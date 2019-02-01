//
//  APSoundModel.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PlayerProtocol.h"

@interface APSoundModel : NSObject <PlayerModelProtocol, NSCopying, NSMutableCopying>

/** 音效所属类ID */
@property (nonatomic, strong) NSNumber *groupId;

/** 音效ID */
@property (nonatomic, strong) NSNumber *soundId;

/** 资源地址 */
@property (nonatomic, copy) NSString *download_url;

/** 音效图标链接 */
@property (nonatomic, copy) NSString *image_url;

/** 音效图标链接 */
@property (nonatomic, copy) NSString *image_select;

/** 音效名称 */
@property (nonatomic, copy) NSString *name_en;

/** 音效是否是Vip订阅用户可用 */
@property (nonatomic, assign) BOOL is_vip;

/** 音效是否是默认播放 */
@property (nonatomic, assign) BOOL is_default;

/** 音效是否已下载 */
@property (nonatomic, assign) BOOL isDownload;





/// 歌曲的文件名，带后缀
@property (nonatomic, strong) NSString *mp3FileName;
/// 根据当前语言环境提供语言
@property (nonatomic, strong) NSString *name;
/// 自然音效用的音量
@property (nonatomic, assign) CGFloat volume;




@end
