//
//  MusicInfo.m
//  Sound
//
//  Created by 郭连城 on 2018/7/26.
//  Copyright © 2018年 DDTR. All rights reserved.
//

#import "MusicInfo.h"

@implementation MusicInfo 
- (CGFloat)volume{
    if(!_volume){
        _volume = 0.8;
    }
    return _volume;
}

- (NSString *)name{
    
//    NSArray *languages = [NSLocale preferredLanguages];
//    NSString *currentLanguage = [languages objectAtIndex:0];
//    if ([currentLanguage hasPrefix:@"zh"]) {
//        return _name_zh;
//    }else{
    //    }
    if(!_name){
        _name = _name_en;
    }
    return _name;
}



//- (NSString *)productId{
//    return @"xtools_vip_one_month";
//}


- (NSInteger)isFree{
    if(!_isCharge){
        _isCharge = 0;
    }
    return _isCharge;
}

- (BOOL)isSelected{
    if(!_isSelected){
        _isSelected = NO;
    }
    return  _isSelected;
}


- (NSString *)mainKey {
    return @"ID";
}

+ (NSString *)mainKey {
    return @"ID";
}
//往数据库存的时候一定会忽略的字段
+ (NSArray *)transients {
    return @[@"isPlay",@"name",@"isDownloading",
             @"flagImage_1",@"flagImage_2",@"volume",@"isSelected"];
}
    
- (NSString *)description{
    return self.yy_modelDescription;
}
    /*!
     *  1.该方法是 `字典里的属性Key` 和 `要转化为模型里的属性名` 不一样 而重写的
     *  前：模型的属性   后：字典里的属性
     */

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper{
    return @{@"imageUrl":@"image_url",
             @"downloadUrl":@"download_url",
             @"productId":@"product_id",
             @"ID":@"id",
             @"backGroundImageUrl":@"background_img_url"
             };
}

@end
