//
//  YGCrashProtocol.h
//  YGCrashHelper
//
//  Created by 许亚光 on 2018/8/6.
//  Copyright © 2018年 xuyagung. All rights reserved.
//

#import "NSObject+Method.h"

@protocol YGCrashProtocol <NSObject>

@required
+ (void)yg_crashHandle;

@end

