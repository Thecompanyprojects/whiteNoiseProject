//
//  APPushTool.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
@interface APPushTool: NSObject

//+ (APPushTool *)shared;

///注册通知
+ (void)registerRemoteNoti;

///注册设备token
+ (void)registerDeviceToken:(NSData *)deviceToken;

///收到推送
+ (void)handleRemoteNotification:(NSDictionary *)dic;
@end
