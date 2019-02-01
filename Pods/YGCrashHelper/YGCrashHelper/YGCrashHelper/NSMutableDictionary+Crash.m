//
//  NSMutableDictionary+Crash.m
//  YGCrashHelper
//
//  Created by 许亚光 on 2018/8/6.
//  Copyright © 2018年 xuyagung. All rights reserved.
//

#import "NSMutableDictionary+Crash.h"
#import "YGCrashMethod.h"
@implementation NSMutableDictionary (Crash)

+ (void)yg_crashHandle {
    [objc_getClass("__NSDictionaryM") yg_exchangeInstanceMethod:@selector(setObject:forKey:)
                                                     withMethod:@selector(yg_setObject:forKey:)];
    [objc_getClass("__NSDictionaryM") yg_exchangeInstanceMethod:@selector(setValue:forKey:)
                                                     withMethod:@selector(yg_setValue:forKey:)];
    [objc_getClass("__NSDictionaryM") yg_exchangeInstanceMethod:@selector(removeObjectForKey:)
                                                     withMethod:@selector(yg_removeObjectForKey:)];
}

- (void)yg_removeObjectForKey:(id)aKey {
    @try {
        [self yg_removeObjectForKey:aKey];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        
    }
}

- (void)yg_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    @try {
        [self yg_setObject:anObject forKey:aKey];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        
    }
}

- (void)yg_setValue:(id)value forKey:(NSString *)key {
    @try {
        [self yg_setValue:value forKey:key];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        
    }
}

@end
