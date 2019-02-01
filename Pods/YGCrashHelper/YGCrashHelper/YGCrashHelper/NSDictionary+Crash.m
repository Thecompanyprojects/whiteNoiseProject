//
//  NSDictionary+Crash.m
//  YGCrashHelper
//
//  Created by 许亚光 on 2018/8/6.
//  Copyright © 2018年 xuyagung. All rights reserved.
//

#import "NSDictionary+Crash.h"
#import "YGCrashMethod.h"
@implementation NSDictionary (Crash)

+ (void)yg_crashHandle {
    [self yg_exchangeClassMethod:@selector(dictionaryWithObjects:forKeys:count:) withMethod:@selector(yg_dictionaryWithObjects:forKeys:count:)];
    [self yg_exchangeClassMethod:@selector(dictionaryWithObjects:forKeys:) withMethod:@selector(yg_dictionaryWithObjects:forKeys:)];
}

+ (instancetype)yg_dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray<id<NSCopying>> *)keys {
    id instance = nil;
    @try {
        instance = [self yg_dictionaryWithObjects:objects forKeys:keys];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
        
        NSUInteger index = MIN(objects.count, keys.count);
        NSArray *newObjects = [objects subarrayWithRange:NSMakeRange(0, index)];
        NSArray *newkeys = [keys subarrayWithRange:NSMakeRange(0, index)];
        
        instance = [self yg_dictionaryWithObjects:newObjects forKeys:newkeys];
    }
    @finally {
        return instance;
    }
}


+ (instancetype)yg_dictionaryWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt {
    id instance = nil;
    @try {
        instance = [self yg_dictionaryWithObjects:objects forKeys:keys count:cnt];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
        
        NSUInteger index = 0;
        id  _Nonnull __unsafe_unretained newObjects[cnt];
        id  _Nonnull __unsafe_unretained newkeys[cnt];
        
        for (int i = 0; i < cnt; i++) {
            if (objects[i] && keys[i]) {
                newObjects[index] = objects[i];
                newkeys[index] = keys[i];
                index++;
            }
        }
        instance = [self yg_dictionaryWithObjects:newObjects forKeys:newkeys count:index];
    }
    @finally {
        return instance;
    }
}

@end
