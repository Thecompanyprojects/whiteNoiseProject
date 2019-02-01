//
//  NSObject+Crash.h
//  YGCrashHelper
//
//  Created by 许亚光 on 2018/8/6.
//  Copyright © 2018年 xuyagung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGCrashProtocol.h"

@interface NSObject (Crash) <YGCrashProtocol>

/**
 防止闪退
 */
+ (void)yg_crashHandle;

/**
 要忽略的类
 */
+ (void)yg_setIgnoreClassArrayM:(NSArray <NSString *>*)ignoreClassArray;

/**
 要忽略的方法
 */
+ (void)yg_setIgnoreMethodArrayM:(NSArray <NSString *>*)ignoreMethodArray;
@end
