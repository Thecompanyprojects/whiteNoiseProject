//
//  APSoundPlayerViewController.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <UIKit/UIKit.h>
@class APCustomModel;
@class APSoundClassModel;
@interface APSoundPlayerVC : APBaseVC

// 一般单首音乐:播放
- (instancetype)initWithModel:(MusicInfo *)model;

// 自定义合集音效:播放 isSelect:YES标识是用户正在组合选择,NO表示已经保存过的组合只是进来播放
- (instancetype)initWithSoundClassDataArray:(NSArray <APSoundClassModel *>*)soundClassDataArray
                           cuntormDataModel:(APCustomModel *)cuntormDataModel
                                   isSelect:(BOOL)isSelect;

@end
