//
//  APSoundsItemView.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <UIKit/UIKit.h>
@class APSoundModel;
@interface APSoundsItemView : UIView

@property (nonatomic, strong) APSoundModel *model;
@property (nonatomic, copy) void(^volumeChaneged)(APSoundModel *model, NSInteger volume);

@end
