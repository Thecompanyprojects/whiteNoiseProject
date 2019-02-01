//
//  NSMutableString+Crash.m
//  YGCrashHelper
//
//  Created by 许亚光 on 2018/8/6.
//  Copyright © 2018年 xuyagung. All rights reserved.
//

#import "NSMutableString+Crash.h"
#import "YGCrashMethod.h"
@implementation NSMutableString (Crash)

+ (void)yg_crashHandle {
    Class class = objc_getClass("__NSCFString");
    [class yg_exchangeInstanceMethod:@selector(insertString:atIndex:)
                          withMethod:@selector(yg_insertString:atIndex:)];
    [class yg_exchangeInstanceMethod:@selector(deleteCharactersInRange:)
                          withMethod:@selector(yg_deleteCharactersInRange:)];
    [class yg_exchangeInstanceMethod:@selector(replaceCharactersInRange:withString:)
                          withMethod:@selector(yg_replaceCharactersInRange:withString:)];
    
}

- (void)yg_deleteCharactersInRange:(NSRange)range {
    @try {
        [self yg_deleteCharactersInRange:range];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        
    }
}

- (void)yg_replaceCharactersInRange:(NSRange)range withString:(NSString *)aString {
    @try {
        [self yg_replaceCharactersInRange:range withString:aString];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        
    }
}

- (void)yg_insertString:(NSString *)aString atIndex:(NSUInteger)loc {
    @try {
        [self yg_insertString:aString atIndex:loc];
    }
    @catch (NSException *exception) {
        [YGCrashMethod yg_errorHandleWithException:exception];
    }
    @finally {
        
    }
}

@end
