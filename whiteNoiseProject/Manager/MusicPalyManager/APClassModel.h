//
//  ClassModel.h
//  Sound
//
//  Created by 郭连城 on 2018/9/3.
//  Copyright © 2018年 DDTR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APClassModel : NSObject

@property (nonatomic, assign) NSInteger classId;//分类ID，具有标识唯一性 关联字段，对应音乐信息表(resource)的flag字段
@property (nonatomic, assign) NSInteger classIndex; //排序顺序

/// 根据当前语言环境提供语言,不存数据库
@property (nonatomic, strong) NSString * name;

@property (nonatomic, strong) NSString *className_en;
@property (nonatomic, strong) NSString *className_zh;
@property (nonatomic, strong) NSString *classIconUrl; //图标链接
/// ARGB 8位，有透明度
@property (nonatomic, strong) NSString *argb;//透明度和色值

@end
