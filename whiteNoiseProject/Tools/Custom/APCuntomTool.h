//
//  APCuntomTool.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APCustomModel.h"
#import "APSoundModel.h"
#import "APSoundClassModel.h"

@interface APCuntomTool : NSObject

/** 实例化 */
+ (instancetype)sharedCuntomTool;

/** 请求数据 */
- (void)requestData;

/** 保存自定义数据 */
- (BOOL)saveCustormData:(APCustomModel *)model;

/** 删除自定义数据 */
- (BOOL)deleteCustormData:(APCustomModel *)model;

/** 获取本地自定义数据 */
- (NSArray <APCustomModel *>*)getCuntomDataArray;

/** 获取音效列表数据 */
- (NSArray <APSoundClassModel *>*)getSoundClassDataArray;

/** 获取默认数据 */
- (NSArray <APSoundModel *>*)getDefaultSoundDataArray;

/** 获取音效列表数据及默认音效 */
- (void)getSoundClassData:(void(^)(NSArray <APSoundClassModel *>*soundClassDataArray, NSArray <APSoundModel *>*defaultDataArray))dataSource;


@end
