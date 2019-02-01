//
//  APSleepCollectionViewCell.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicInfo.h"
#import "APSoundCellProtocol.h"
@interface APSoundListCell : UICollectionViewCell

@property (nonatomic, strong) MusicInfo *model;
@property (nonatomic, assign) BOOL playing;


@property (nonatomic, copy) void (^purchaseAction)(MusicInfo *model);
@property (nonatomic, copy) void (^downloadAction)(NSString *productId);
@property (nonatomic, assign) CGFloat downloadProgress;
@property (nonatomic, weak, nullable) id <APSleepCollectionViewCellDelegate> delegate;
@end
