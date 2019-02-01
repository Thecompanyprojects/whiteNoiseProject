//
//  ClassModel.m
//  Sound
//
//  Created by 郭连城 on 2018/9/3.
//  Copyright © 2018年 DDTR. All rights reserved.
//

#import "APClassModel.h"

@implementation APClassModel


- (NSString *)name{

//    NSArray *languages = [NSLocale preferredLanguages];
//    NSString *currentLanguage = [languages objectAtIndex:0];
    //        if ([currentLanguage hasPrefix:@"zh"]) {
    //            _name = _className_zh;
    //        }else{
    //        }
    if (!_name){
            _name = _className_en;
    }
    return _name;
    
}


- (NSString *)description{
    return self.yy_modelDescription;
}
@end
