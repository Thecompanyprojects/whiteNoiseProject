//
//  NSString+Crash.m
//  YGCrashHelper
//
//  Created by 许亚光 on 2018/8/6.
//  Copyright © 2018年 xuyagung. All rights reserved.
//

#import "NSString+Crash.h"
#import "YGCrashMethod.h"
@implementation NSString (Crash)

+ (void)yg_crashHandle {
    Class class = objc_getClass("__NSCFConstantString");
    [class yg_exchangeInstanceMethod:@selector(characterAtIndex:)
                                                          withMethod:@selector(yg_characterAtIndex:)];
    [class yg_exchangeInstanceMethod:@selector(substringFromIndex:)
                                                          withMethod:@selector(yg_substringFromIndex:)];
    [class yg_exchangeInstanceMethod:@selector(substringToIndex:)
                                                          withMethod:@selector(yg_substringToIndex:)];
    [class yg_exchangeInstanceMethod:@selector(substringWithRange:)
                                                          withMethod:@selector(yg_substringWithRange:)];
    [class yg_exchangeInstanceMethod:@selector(stringByReplacingOccurrencesOfString:withString:)
                          withMethod:@selector(yg_stringByReplacingOccurrencesOfString:withString:)];
    [class yg_exchangeInstanceMethod:@selector(stringByReplacingOccurrencesOfString:withString:options:range:)
                          withMethod:@selector(yg_stringByReplacingOccurrencesOfString:withString:options:range:)];
    [class yg_exchangeInstanceMethod:@selector(stringByReplacingCharactersInRange:withString:)
                          withMethod:@selector(yg_stringByReplacingCharactersInRange:withString:)];
}

- (unichar)yg_characterAtIndex:(NSUInteger)index {
    unichar characteristic;
    @try {
        characteristic = [self yg_characterAtIndex:index];
    }
    @catch (NSException *exception) {
       [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        return characteristic;
    }
}

- (NSString *)yg_substringFromIndex:(NSUInteger)from {
    NSString *subString = nil;
    @try {
        subString = [self yg_substringFromIndex:from];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
        subString = nil;
    }
    @finally {
        return subString;
    }
}

- (NSString *)yg_substringToIndex:(NSUInteger)to {
    NSString *subString = nil;
    @try {
        subString = [self yg_substringToIndex:to];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
        subString = nil;
    }
    @finally {
        return subString;
    }
}

- (NSString *)yg_substringWithRange:(NSRange)range {
    NSString *subString = nil;
    @try {
        subString = [self yg_substringWithRange:range];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
        subString = nil;
    }
    @finally {
        return subString;
    }
}

- (NSString *)yg_stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement {
    NSString *str = nil;
    @try {
        str = [self yg_stringByReplacingOccurrencesOfString:target withString:replacement];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
        str = nil;
    }
    @finally {
        return str;
    }
}

- (NSString *)yg_stringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange {
    NSString *str = nil;
    @try {
        str = [self yg_stringByReplacingOccurrencesOfString:target withString:replacement options:options range:searchRange];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
        str = nil;
    }
    @finally {
        return str;
    }
}

- (NSString *)yg_stringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement {
    NSString *str = nil;
    @try {
        str = [self yg_stringByReplacingCharactersInRange:range withString:replacement];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
        str = nil;
    }
    @finally {
        return str;
    }
}

@end
