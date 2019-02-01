//
//  NSString+Crash.h
//  YGCrashHelper
//
//  Created by 许亚光 on 2018/8/6.
//  Copyright © 2018年 xuyagung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGCrashProtocol.h"
@interface NSString (Crash) <YGCrashProtocol>

+ (void)yg_crashHandle;

@end
