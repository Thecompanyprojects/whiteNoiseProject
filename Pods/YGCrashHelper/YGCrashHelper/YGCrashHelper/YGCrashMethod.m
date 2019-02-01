//
//  YGCrashMethod.m
//  YGCrashHelper
//
//  Created by 许亚光 on 2018/8/6.
//  Copyright © 2018年 xuyagung. All rights reserved.
//

#import "YGCrashMethod.h"
#import "YGCrashHelper.h"

@implementation YGCrashMethod

- (void)yg_crashMethed {
    
}

+ (void)yg_errorHandleWithException:(NSException *)exception {
    //堆栈数据
    NSArray *callStackSymbolsArr = [NSThread callStackSymbols];
    NSString *mainCallStackSymbolMsg = [self yg_mainCallStackSymbolMessageWithCallStackSymbols:callStackSymbolsArr];
    if (mainCallStackSymbolMsg == nil) {
        mainCallStackSymbolMsg = @"请您查看函数调用栈来排查错误原因";
    }
    
    NSString *errorName = exception.name;
    NSString *errorReason = exception.reason;
    //errorReason 可能为 -[__NSCFConstantString avoidCrashCharacterAtIndex:]: Range or index out of bounds
    //将avoidCrash去掉
    errorReason = [errorReason stringByReplacingOccurrencesOfString:@"avoidCrash" withString:@""];
    NSString *errorPlace = [NSString stringWithFormat:@"%@",mainCallStackSymbolMsg];
    NSString *logErrorMessage = [NSString stringWithFormat:@"ErrorName:%@\nErrorReason:%@\nErrorPlace:%@", errorName, errorReason, errorPlace];
    
    NSLog(@"\n\n%@\n\n",logErrorMessage);
    
    NSDictionary *errorInfoDic = @{
                                   @"ErrorName":errorName,
                                   @"ErrorReason":errorReason,
                                   @"ErrorPlace":errorPlace,
//                                   @"Exception":exception,
                                   @"CallStackSymbols":callStackSymbolsArr
                                   };
    
    //将错误信息放在字典里，用通知的形式发送出去
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:YGCrashNotificationName object:nil userInfo:errorInfoDic];
        if ([YGCrashHelper sharedInstance].handleBlock) {
            [YGCrashHelper sharedInstance].handleBlock(errorName, errorReason, errorPlace, callStackSymbolsArr, exception);
        }
    });
}


/**
 获取堆栈主要崩溃精简化的信息<根据正则表达式匹配出来>

 @param callStackSymbols 堆栈主要崩溃信息
 @return 堆栈主要崩溃精简化的信息
 */
+ (NSString *)yg_mainCallStackSymbolMessageWithCallStackSymbols:(NSArray<NSString *> *)callStackSymbols {
    
    //mainCallStackSymbolMsg的格式为   +[类名 方法名]  或者 -[类名 方法名]
    __block NSString *mainCallStackSymbolMsg = nil;
    
    //匹配出来的格式为 +[类名 方法名]  或者 -[类名 方法名]
    NSString *regularExpStr = @"[-\\+]\\[.+\\]";
    
    
    NSRegularExpression *regularExp = [[NSRegularExpression alloc] initWithPattern:regularExpStr options:NSRegularExpressionCaseInsensitive error:nil];
    
    
    for (int index = 2; index < callStackSymbols.count; index++) {
        NSString *callStackSymbol = callStackSymbols[index];
        
        [regularExp enumerateMatchesInString:callStackSymbol options:NSMatchingReportProgress range:NSMakeRange(0, callStackSymbol.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            if (result) {
                NSString* tempCallStackSymbolMsg = [callStackSymbol substringWithRange:result.range];
                
                //get className
                NSString *className = [tempCallStackSymbolMsg componentsSeparatedByString:@" "].firstObject;
                className = [className componentsSeparatedByString:@"["].lastObject;
                
                NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(className)];
                
                //filter category and system class
                if (![className hasSuffix:@")"] && bundle == [NSBundle mainBundle]) {
                    mainCallStackSymbolMsg = tempCallStackSymbolMsg;
                    
                }
                *stop = YES;
            }
        }];
        
        if (mainCallStackSymbolMsg.length) {
            break;
        }
    }
    
    return mainCallStackSymbolMsg;
}



@end
