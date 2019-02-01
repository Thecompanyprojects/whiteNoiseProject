//
//  NSArray+Crash.m
//  YGCrashHelper
//
//  Created by 许亚光 on 2018/8/6.
//  Copyright © 2018年 xuyagung. All rights reserved.
//

#import "NSArray+Crash.h"
#import "YGCrashMethod.h"
@implementation NSArray (Crash)
+ (void)yg_crashHandle {
    // Class Method
    [self yg_exchangeClassMethod:@selector(arrayWithObjects:count:)
                      withMethod:@selector(yg_arrayWithObjects:count:)];
    
    Class __NSArray = objc_getClass("NSArray");
    Class __NSArrayI = objc_getClass("__NSArrayI");
    Class __NSSingleObjectArrayI = objc_getClass("__NSSingleObjectArrayI");
    Class __NSArray0 = objc_getClass("__NSArray0");
    
    // Instance Method
    // objectsAtIndexes:
    [__NSArray yg_exchangeInstanceMethod:@selector(objectsAtIndexes:)
                              withMethod:@selector(yg_objectsAtIndexes:)];
    
    // objectAtIndex:
    [__NSArrayI yg_exchangeInstanceMethod:@selector(objectAtIndex:)
                                                withMethod:@selector(yg1_objectAtIndex:)];
    [__NSSingleObjectArrayI yg_exchangeInstanceMethod:@selector(objectAtIndex:)
                                                withMethod:@selector(yg2_objectAtIndex:)];
    [__NSArray0 yg_exchangeInstanceMethod:@selector(objectAtIndex:)
                                                withMethod:@selector(yg3_objectAtIndex:)];
    
    // getObjects:range:
    [__NSArray yg_exchangeInstanceMethod:@selector(getObjects:range:)
                              withMethod:@selector(yg1_getObjects:range:)];
    [__NSSingleObjectArrayI yg_exchangeInstanceMethod:@selector(getObjects:range:)
                              withMethod:@selector(yg2_getObjects:range:)];
    [__NSArrayI yg_exchangeInstanceMethod:@selector(getObjects:range:)
                              withMethod:@selector(yg3_getObjects:range:)];
    
    //objectAtIndexedSubscript:
    [__NSArrayI yg_exchangeInstanceMethod:@selector(objectAtIndexedSubscript:)
                               withMethod:@selector(yg_objectAtIndexedSubscript:)];
    
    // subarrayWithRange:
    [__NSArrayI yg_exchangeInstanceMethod:@selector(subarrayWithRange:)
                               withMethod:@selector(yg_subarrayWithRange:)];
}

+ (instancetype)yg_arrayWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt {
    id instance = nil;
    @try {
        instance = [self yg_arrayWithObjects:objects count:cnt];
    }
    @catch (NSException *exception) {
        NSInteger newObjsIndex = 0;
        id  _Nonnull __unsafe_unretained newObjects[cnt];
        for (int i = 0; i < cnt; i++) {
            if (objects[i] != nil) {
                newObjects[newObjsIndex] = objects[i];
                newObjsIndex++;
            }
        }
        instance = [self yg_arrayWithObjects:newObjects count:newObjsIndex];
    }
    @finally {
        return instance;
    }
}


- (id)yg1_objectAtIndex:(NSUInteger)index {
    id obj = nil;
    @try {
        obj = [self yg1_objectAtIndex:index];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        return obj;
    }
}

- (id)yg2_objectAtIndex:(NSUInteger)index {
    id obj = nil;
    @try {
        obj = [self yg2_objectAtIndex:index];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        return obj;
    }
}

- (id)yg3_objectAtIndex:(NSUInteger)index {
    id obj = nil;
    @try {
        obj = [self yg3_objectAtIndex:index];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        return obj;
    }
}

- (NSArray *)yg_objectsAtIndexes:(NSIndexSet *)indexes {
    NSArray *arr = nil;
    @try {
        arr = [self yg_objectsAtIndexes:indexes];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        return arr;
    }
}

- (NSArray *)yg_subarrayWithRange:(NSRange)range {
    NSArray *arr = nil;
    @try {
        arr = [self yg_subarrayWithRange:range];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        return arr;
    }
}

- (void)yg1_getObjects:(__unsafe_unretained id  _Nonnull [])objects range:(NSRange)range {
    @try {
        [self yg1_getObjects:objects range:range];
    } @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    } @finally {
        
    }
}

- (void)yg2_getObjects:(__unsafe_unretained id  _Nonnull [])objects range:(NSRange)range {
    @try {
        [self yg2_getObjects:objects range:range];
    } @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    } @finally {
        
    }
}

- (void)yg3_getObjects:(__unsafe_unretained id  _Nonnull [])objects range:(NSRange)range {
    @try {
        [self yg3_getObjects:objects range:range];
    } @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    } @finally {
        
    }
}

- (id)yg_objectAtIndexedSubscript:(NSUInteger)idx {
    id obj = nil;
    @try {
        obj = [self yg_objectAtIndexedSubscript:idx];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        return obj;
    }
}



@end

