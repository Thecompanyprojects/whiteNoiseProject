//
//  APSoundClassModel.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class APSoundModel;

@interface APSoundClassModel : NSObject

/**
 音效分类ID
 */
@property (nonatomic, assign) NSNumber *groupId;

/**
 音效分类标题
 */
@property (nonatomic, copy) NSString *groupName;

/**
 分类音效资源数据
 */
@property (nonatomic, strong) NSArray <APSoundModel *>*resource;


@end
