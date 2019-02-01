//
//  APCustomCardView.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APSoundClassModel;
@class APCustomModel;
@class APSoundModel;

@interface APCustomCardView : UIView


/**
 自定义音效弹窗
 
 @param dataArray 备选数据
 @param APCustomModel 默认选择数据
 @param addHandle 添加新的音效处理回调
 @param deleteHandle 删除音效t回调
 @param volumeHandle 音量调节回调
 @param confirmHandle 确认修改
 @return 自定义音效弹窗
 */
- (instancetype)initWithCustomSourceDataArray:(NSMutableArray <APSoundClassModel *>*)dataArray
                              customDataModel:(APCustomModel *)APCustomModel
                                addSoundBlock:(void(^)(APSoundModel *))addHandle
                             deleteSoundBlock:(void(^)(APSoundModel *))deleteHandle
                           volumeChangedBlock:(void(^)(APSoundModel *))volumeHandle
                                 confirmBlock:(void(^)(APCustomModel *))confirmHandle;

/**
 展示
 */
- (void)showCuntomSelectView;


/**
 隐藏
 */
- (void)dismissCuntomSelectView;


@end

