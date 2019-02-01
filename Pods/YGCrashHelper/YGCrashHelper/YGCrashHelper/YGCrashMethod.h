//
//  YGCrashMethod.h
//  YGCrashHelper
//
//  Created by 许亚光 on 2018/8/6.
//  Copyright © 2018年 xuyagung. All rights reserved.
//

#import <Foundation/Foundation.h>

// 错误通知
static NSString * const YGCrashNotificationName = @"YGCrashNotificationName";

@interface YGCrashMethod : NSObject
/**
 未识别方法替换为用该方法
 */
- (void)yg_crashMethed;


/**
 处理错误信息

 @param exception 错误信息
 */
+ (void)yg_errorHandleWithException:(NSException *)exception;






@end
