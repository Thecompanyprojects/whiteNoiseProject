//
//  APCustomModel.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class APSoundModel;

@interface APCustomModel : NSObject <NSCopying, NSMutableCopying>

/** 自定义音效合集ID */
@property (nonatomic, assign) NSInteger customId;

/** 自定义音乐合集名称 */
@property (nonatomic, copy) NSString *name;

/**< 播放页背景图 */
@property (nonatomic, copy) NSString *icon_bg_name;

/**< 播放页背景图 */
@property (nonatomic, copy) NSString *icon_name;

/** 自定义音乐合集内容,最多可包含三个 */
@property (nonatomic, strong) NSMutableArray <APSoundModel *>*sounds;

/** 是否已经保存 */
@property (nonatomic, assign) BOOL isSaved;


@end
