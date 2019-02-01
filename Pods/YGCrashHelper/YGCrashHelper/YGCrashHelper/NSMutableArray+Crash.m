//
//  NSMutableArray+Crash.m
//  YGCrashHelper
//
//  Created by 许亚光 on 2018/8/6.
//  Copyright © 2018年 xuyagung. All rights reserved.
//

#import "NSMutableArray+Crash.h"
#import "YGCrashMethod.h"
@implementation NSMutableArray (Crash)
+(void)yg_crashHandle {
    [objc_getClass("__NSArrayM") yg_exchangeInstanceMethod:@selector(removeObject:)
                                                withMethod:@selector(yg_removeObject:) ];
    [objc_getClass("__NSArrayM") yg_exchangeInstanceMethod:@selector(addObject:)
                                                withMethod:@selector(yg_addObject:)];
    [objc_getClass("__NSArrayM") yg_exchangeInstanceMethod:@selector(removeObjectAtIndex:)
                                                withMethod:@selector(yg_removeObjectAtIndex:)];
    [objc_getClass("__NSArrayM") yg_exchangeInstanceMethod:@selector(insertObject:atIndex:)
                                                withMethod:@selector(yg_insertObject:atIndex:)];
    [objc_getClass("__NSArrayM") yg_exchangeInstanceMethod:@selector(objectAtIndex:)
                                                withMethod:@selector(yg_objectAtIndex:)];
    [objc_getClass("__NSArrayM") yg_exchangeInstanceMethod:@selector(objectAtIndexedSubscript:)
                                                withMethod:@selector(yg_objectAtIndexedSubscript:)];
    [objc_getClass("__NSArrayM") yg_exchangeInstanceMethod:@selector(subarrayWithRange:)
                                                withMethod:@selector(yg_subarrayWithRange:)];
}

- (void)yg_removeObject:(id)anObject {
    @try {
        [self yg_removeObject:anObject];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        
    }
}

- (void)yg_addObject:(id)anObject {
    @try {
        [self yg_addObject:anObject];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        
    }
}

- (void)yg_removeObjectAtIndex:(NSUInteger)index {
    @try {
        [self yg_removeObjectAtIndex:index];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        
    }
}

- (void)yg_insertObject:(id)anObject atIndex:(NSUInteger)index {
    @try {
        [self yg_insertObject:anObject atIndex:index];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        
    }
}

- (id)yg_objectAtIndex:(NSUInteger)index {
    id obj = nil;
    @try {
        obj = [self yg_objectAtIndex:index];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        return obj;
    }
}

- (id)yg_objectAtIndexedSubscript:(NSUInteger)index {
    id obj = nil;
    @try {
        obj = [self yg_objectAtIndexedSubscript:index];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        return obj;
    }
}

- (NSArray *)yg_subarrayWithRange:(NSRange)range {
    id obj = nil;
    @try {
        obj = [self yg_subarrayWithRange:range];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        return obj;
    }
}
@end
