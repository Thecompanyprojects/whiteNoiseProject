//
//  YGCrashHelper.m
//  YGCrashHelper
//
//  Created by 许亚光 on 2018/8/6.
//  Copyright © 2018年 xuyagung. All rights reserved.
//

#import "YGCrashHelper.h"
#import "NSObject+Crash.h"

@implementation YGCrashHelper

+ (instancetype)sharedInstance {
    static YGCrashHelper *crashHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        crashHelper = [[super alloc] init];
    });
    return crashHelper;
}

- (void)carshHandle {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSArray yg_crashHandle];
        [NSMutableArray yg_crashHandle];
        [NSDictionary yg_crashHandle];
        [NSMutableDictionary yg_crashHandle];
        [NSString yg_crashHandle];
        [NSMutableString yg_crashHandle];
        [NSMutableAttributedString yg_crashHandle];
    });
}

- (void)crashHandleAll {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSObject yg_crashHandle];
        [NSArray yg_crashHandle];
        [NSMutableArray yg_crashHandle];
        [NSDictionary yg_crashHandle];
        [NSMutableDictionary yg_crashHandle];
        [NSString yg_crashHandle];
        [NSMutableString yg_crashHandle];
        [NSMutableAttributedString yg_crashHandle];
    });
}

- (void)crashHandle:(YGCrashHandle)handleBlock {
    [self carshHandle];
    self.handleBlock = handleBlock;
}

- (void)carshHandleAll:(YGCrashHandle)handleBlock {
    [self crashHandleAll];
    self.handleBlock = handleBlock;
}

- (void)ignoreClass:(NSArray<NSString *> *)classArray {
    [NSObject yg_setIgnoreClassArrayM:classArray];
}

- (void)ignoreMethod:(NSArray<NSString *> *)methodArray {
    [NSObject yg_setIgnoreMethodArrayM:methodArray];
}

@end
