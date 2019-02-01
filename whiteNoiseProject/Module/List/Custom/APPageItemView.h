//
//  APPageItemView.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <UIKit/UIKit.h>
@class APSoundClassModel;
@class APSoundModel;
@interface APPageItemView : UIView

@property (nonatomic, strong) APSoundClassModel *model;
@property (nonatomic, copy) BOOL (^ItemSelect)(APSoundModel *model);
@property (nonatomic, copy) void (^ItemSelectShouldVip)(APSoundModel *model);

@end
