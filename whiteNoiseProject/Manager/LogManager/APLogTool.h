//
//  APLogManager.h
//  XToolCuteCamera
//
//  Created by CDR on 2018/8/22.
//  Copyright © 2018年 nbt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APLogTool : NSObject

@property (nonatomic, strong) NSNumber *networkStatusNum;

+ (instancetype)shareManager;

- (void)addLogKey1:(NSString *)key1 key2:(NSString *)key2 content:(NSDictionary *)content userInfo:(NSDictionary *)userInfo upload:(BOOL)upload;
- (void)addCrashLog:(NSDictionary *)dic upload:(BOOL)upload;
- (void)uploadLocalLogData;


@end
