//
//  NSMutableAttributedString+Crash.m
//  YGCrashHelper
//
//  Created by 许亚光 on 2018/8/6.
//  Copyright © 2018年 xuyagung. All rights reserved.
//

#import "NSMutableAttributedString+Crash.h"
#import "YGCrashMethod.h"
@implementation NSMutableAttributedString (Crash)
+ (void)yg_crashHandle {
    Class class = NSClassFromString(@"NSConcreteMutableAttributedString");
    [class yg_exchangeInstanceMethod:@selector(initWithString:)
                          withMethod:@selector(yg_initWithString:)];
    [class yg_exchangeInstanceMethod:@selector(initWithString:attributes:)
                          withMethod:@selector(yg_initWithString:attributes:)];
}

- (instancetype)yg_initWithString:(NSString *)str {
    id obj = nil;
    @try {
        obj = [self yg_initWithString:str];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        return obj;
    }
}

- (instancetype)yg_initWithString:(NSString *)str attributes:(NSDictionary<NSAttributedStringKey,id> *)attrs {
    id obj = nil;
    @try {
        obj = [self yg_initWithString:str attributes:attrs];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        return obj;
    }
}
@end
