//
//  YGCrashHelper.h
//  YGCrashHelper
//
//  Created by 许亚光 on 2018/8/6.
//  Copyright © 2018年 xuyagung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGCrashMethod.h"

#import "NSObject+Method.h"

#import "NSArray+Crash.h"
#import "NSMutableArray+Crash.h"
#import "NSDictionary+Crash.h"
#import "NSMutableDictionary+Crash.h"
#import "NSString+Crash.h"
#import "NSMutableString+Crash.h"
#import "NSMutableAttributedString+Crash.h"


typedef void(^YGCrashHandle)(NSString *errorName, NSString *errorReason, NSString *errorLocation, NSArray *stackSymbols, NSException *exception);

@interface YGCrashHelper : NSObject

// 异常处理回调,多次赋值会覆盖上一次
@property (nonatomic, copy) YGCrashHandle handleBlock;

+ (instancetype)sharedInstance;
- (void)carshHandle;
- (void)crashHandleAll;
- (void)crashHandle:(YGCrashHandle)handleBlock;
- (void)carshHandleAll:(YGCrashHandle)handleBlock;
// 也可以监听通知 YGCrashNotificationName 获取崩溃信息,以便于上传到自己的服务器



- (void)ignoreClass:(NSArray <NSString *>*)classArray;
- (void)ignoreMethod:(NSArray <NSString *>*)methodArray;

@end
