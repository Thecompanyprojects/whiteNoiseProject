//
//  CustomListCell.h
//  Sound
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018年 DDTR. All rights reserved.
//

#import <UIKit/UIKit.h>
@class APCustomModel;
@interface APCustomSoundListCell : UICollectionViewCell

@property (nonatomic, strong) APCustomModel *model;
@property (nonatomic, copy) void (^deleteAction)(APCustomModel *model);

@end
