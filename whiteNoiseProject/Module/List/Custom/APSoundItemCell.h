//
//  APSoundItemCell.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APMusicDownloadDelegate.h"

@class APSoundModel;
@interface APSoundItemCell : UICollectionViewCell

// 数据
@property (nonatomic, copy) APSoundModel *model;

// 下载完成回调
@property (nonatomic, copy) void (^downloadFinished)(BOOL isSuccess, NSError *error);

// 开始下载
- (void)downloadSound;

@end
