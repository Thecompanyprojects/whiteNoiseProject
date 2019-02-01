//
//  APSoundsContentView.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <UIKit/UIKit.h>
@class APSoundModel;

@interface APSoundsContentView : UIView

/***********************************数据源********************************************/
@property (nonatomic, strong) NSMutableArray <APSoundModel *>*dataArrM;


/****************************以下两个回调是用户内部操作引起的变化****************************/
// 音量改变
@property (nonatomic, copy) void (^volumeChanged)(APSoundModel *sound, CGFloat voloum);
// 点击删除
@property (nonatomic, copy) void (^deleteSound)(APSoundModel *sound);





/****************************以下方法是用户外部操作引起的变化****************************/

// 增加音效
- (void)addSoundItem:(APSoundModel *)model;

// 删除音效
- (void)deleteSoundItem:(APSoundModel *)model;

@end
