//
//  APSoundClassModel.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APSoundClassModel.h"
#import "APSoundModel.h"

@implementation APSoundClassModel

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass {
    return @{
             @"resource":[APSoundModel class]
             };
}

@end
