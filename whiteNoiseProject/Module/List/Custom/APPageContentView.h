//
//  APPageContentView.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <UIKit/UIKit.h>
@class APSoundClassModel;
@class APSoundModel;

@interface APPageContentView : UIView

@property (nonatomic, strong) NSArray <APSoundClassModel *>*dataArray;
@property (nonatomic, copy) BOOL (^pageContentItemSelect)(APSoundModel *model);
@property (nonatomic, copy) void (^pageContentItemSelectShouldVip)(APSoundModel *model);

@end
