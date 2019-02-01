//
//  APCustomModel.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APCustomModel.h"
#import "APSoundModel.h"

@implementation APCustomModel

// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)。
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"sounds" : [APSoundModel class]};
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    APCustomModel *newModel = [[APCustomModel allocWithZone:zone] init];
    newModel.customId = self.customId;
    newModel.name = self.name;
    newModel.icon_name = self.icon_name;
    newModel.icon_bg_name = self.icon_bg_name;
    newModel.isSaved = NO;
    NSMutableArray *arrM = [NSMutableArray array];
    for (APSoundModel *sound in self.sounds) {
        APSoundModel *newSound = sound.copy;
        [arrM addObject:newSound];
    }
    newModel.sounds = arrM;
    return newModel;
}


- (id)copyWithZone:(NSZone *)zone {
    APCustomModel *newModel = [[APCustomModel allocWithZone:zone] init];
    newModel.customId = self.customId;
    newModel.name = self.name;
    newModel.icon_name = self.icon_name;
    newModel.icon_bg_name = self.icon_bg_name;
    newModel.isSaved = NO;
    NSMutableArray *arrM = [NSMutableArray array];
    for (APSoundModel *sound in self.sounds) {
        APSoundModel *newSound = sound.copy;
        [arrM addObject:newSound];
    }
    newModel.sounds = arrM;
    return newModel;
}
@end

