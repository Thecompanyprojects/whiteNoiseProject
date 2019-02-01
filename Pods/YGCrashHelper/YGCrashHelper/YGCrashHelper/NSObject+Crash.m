//
//  NSObject+Crash.m
//  YGCrashHelper
//
//  Created by 许亚光 on 2018/8/6.
//  Copyright © 2018年 xuyagung. All rights reserved.
//

#import "NSObject+Crash.h"
#import "YGCrashMethod.h"

static NSMutableArray *kIgnoreClassArrayM; // 需要忽略的类
static NSMutableArray *kIgnoreMethodArrayM; // 需要忽略的的方法

@implementation NSObject (Crash)

+ (void)yg_crashHandle {
    [self yg_exchangeInstanceMethod:@selector(setValue:forKey:)
                         withMethod:@selector(yg_setValue:forKey:)];
    [self yg_exchangeInstanceMethod:@selector(setValue:forKeyPath:)
                         withMethod:@selector(yg_setValue:forKeyPath:)];
    [self yg_exchangeInstanceMethod:@selector(setValue:forUndefinedKey:)
                         withMethod:@selector(yg_setValue:forUndefinedKey:)];
    [self yg_exchangeInstanceMethod:@selector(setValuesForKeysWithDictionary:)
                         withMethod:@selector(yg_setValuesForKeysWithDictionary:)];
    [self yg_exchangeInstanceMethod:@selector(methodSignatureForSelector:)
                         withMethod:@selector(yg_methodSignatureForSelector:)];
    [self yg_exchangeInstanceMethod:@selector(forwardInvocation:)
                         withMethod:@selector(yg_forwardInvocation:)];
}

+ (void)yg_setIgnoreClassArrayM:(NSArray <NSString *>*)ignoreClassArray {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kIgnoreClassArrayM = [NSMutableArray array];
        [kIgnoreClassArrayM addObjectsFromArray:ignoreClassArray];
    });
}

+ (void)yg_setIgnoreMethodArrayM:(NSArray <NSString *>*)ignoreMethodArray {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kIgnoreMethodArrayM = [NSMutableArray array];
        [kIgnoreMethodArrayM addObjectsFromArray:ignoreMethodArray];
    });
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

- (void)yg_setValue:(id)value forKeyPath:(NSString *)keyPath {
    @try {
        [self yg_setValue:value forKeyPath:keyPath];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        
    }
}

- (void)yg_setValue:(id)value forUndefinedKey:(NSString *)key {
    @try {
        [self yg_setValue:value forUndefinedKey:key];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        
    }
}

- (void)yg_setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues {
    @try {
        [self yg_setValuesForKeysWithDictionary:keyedValues];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        
    }
}

- (NSMethodSignature *)yg_methodSignatureForSelector:(SEL)aSelector {
    
    NSString *sel = NSStringFromSelector(aSelector);
    
    BOOL ignoreFlag = NO;
    
    if ([sel hasSuffix:@"_"]) {
        ignoreFlag = YES;
    }
    
    if ([self respondsToSelector:aSelector]) {
        ignoreFlag = YES;
    }
    
    for (NSString *method in kIgnoreMethodArrayM) {
        if ([sel isEqualToString:method]) {
            ignoreFlag = YES;
        }
    }
    
    for (NSString *class in kIgnoreClassArrayM) {
        if ([self isKindOfClass:NSClassFromString(class)]) {
            ignoreFlag = YES;
        }
    }
    
    if (!ignoreFlag) {
        for (NSString *class in kIgnoreClassArrayM) {
            NSArray *methodArray = [NSClassFromString(class) yg_getAllMethods];
            for (NSString *method in methodArray) {
                if ([method isEqualToString:sel] || [method containsString:sel]) {
                    ignoreFlag = YES;
                }
            }
        }
    }
    
    if (ignoreFlag) {
        return [self yg_methodSignatureForSelector:aSelector];
    }
    
    NSMethodSignature *methodSignature = [self yg_methodSignatureForSelector:aSelector];
    if (!methodSignature) {
        methodSignature = [YGCrashMethod instanceMethodSignatureForSelector:@selector(yg_crashMethed)];
    }
    return methodSignature;
}

- (void)yg_forwardInvocation:(NSInvocation *)anInvocation {
    @try {
        [self yg_forwardInvocation:anInvocation];
    } @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    } @finally {
        
    }
}
@end
