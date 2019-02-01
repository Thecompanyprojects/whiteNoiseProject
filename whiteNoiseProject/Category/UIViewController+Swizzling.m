//
//  UIViewController+Swizzling.m
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "UIViewController+Swizzling.h"
#import "NSObject+Swizzling.h"


@implementation UIViewController (Swizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self yg_swizzlingInstanceMethod:@selector(viewWillAppear:) withMethod:@selector(swiz_viewWillAppear:)];
        [self yg_swizzlingInstanceMethod:@selector(viewWillDisappear:) withMethod:@selector(swiz_viewWillDisappear:)];
        [self yg_swizzlingInstanceMethod:@selector(viewDidAppear:) withMethod:@selector(swiz_viewDidAppear:)];
    });
}

- (void)swiz_viewWillAppear:(BOOL)animated {
    NSString *str = [NSString stringWithFormat:@"%@", self.class];
    if(![str containsString:@"UI"] && ![str containsString:@"Navigation"] && ![str containsString:@"TabBar"]){
        
        //        [[APLogManager shareManager] addLogKey1:str.lowercaseString key2:@"enter" content:nil userInfo:nil upload:NO];
        
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
        self.kEnterTimeStamp = [NSString stringWithFormat:@"%.0f", time];
        
    }
    [self swiz_viewWillAppear:animated];
}

- (void)swiz_viewWillDisappear:(BOOL)animated {
    NSString *str = [NSString stringWithFormat:@"%@", self.class];
    if(![str containsString:@"UI"] && ![str containsString:@"Navigation"] && ![str containsString:@"TabBar"]){
        
        // 针对一下页面自定义字段,立即上报;其他页面
        NSString *key_1 = str;
        
        // 是否需要统计该界面
        BOOL isLog = YES;
        
        // 需要统计的j页面
        if ([self isMemberOfClass:NSClassFromString(@"MusicListViewController")] ||
            [self isMemberOfClass:NSClassFromString(@"CustomListViewController")]) {
            
            key_1 = self.kTagString.lowercaseString;
            
        } else {
            isLog = NO;
        }
        
        if (isLog) {
            NSTimeInterval outTime = [[NSDate date] timeIntervalSince1970] * 1000;
            NSTimeInterval enterTime = self.kEnterTimeStamp.doubleValue;
            NSString *duration = [NSString stringWithFormat:@"%.0f",outTime - enterTime];
            
            NSLog(@"\n\n-----------用户在->:%@ 停留->:%@毫秒\n\n",str, duration);
            
            [[APLogTool shareManager] addLogKey1:key_1 key2:@"duration" content:@{@"millisecond":duration} userInfo:nil upload:YES];
        }
    }
    [self swiz_viewWillDisappear:animated];
}


- (void)swiz_viewDidAppear:(BOOL)animated {
    NSString *str = [NSString stringWithFormat:@"%@", self.class];
    if(![str containsString:@"UI"] && ![str containsString:@"Navigation"] && ![str containsString:@"TabBar"]){
        
    }
    [self swiz_viewDidAppear:animated];
}


@end

