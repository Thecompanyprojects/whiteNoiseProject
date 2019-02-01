//
//  APPushTool.m
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APPushTool.h"
#import "APPushTool_Extension.h"
#import <FCUUID/FCUUID.h>
#import "APNetworkHelper.h"
@interface APPushTool()<UNUserNotificationCenterDelegate>

@end

@implementation APPushTool
//MARK:- 删除所有通知
+ (void)removeAllNotification{
    if (@available(iOS 10.0, *)){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllPendingNotificationRequests];
        [center removeAllDeliveredNotifications];
    }else{
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}
//MARK:- 删除指定通知
+ (void)removeNotification:(NSString *)requestIdentifier{
    if (@available(iOS 10.0, *)) {
        //iOS10以后
        // 删除某个指定通知
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        // iOS10以后,requestIdentifier就变成了通知本身的一个属性,可以通过系统提供的方法进行查询获取,不用再遍历所有的通知了,方便了很多。修改通知只要创建一个同样requestIdentifier的通知覆盖原通知即可。
        [center removePendingNotificationRequestsWithIdentifiers:@[requestIdentifier]];
        [center removeDeliveredNotificationsWithIdentifiers:@[requestIdentifier]];
        return;
    }
    // iOS10以前
    // 删除某个指定通知
    // 首先获取所有通知
    NSArray *notificaitons = [[UIApplication sharedApplication] scheduledLocalNotifications];
    if (!notificaitons || notificaitons.count <= 0) {
        return;
    }
    for (UILocalNotification *notify in notificaitons) {
        // 这里的requestIdentifier是保存在userInfo当中的一个自己定义的字段,用来区分每个通知,每次删除或修改都需要从所有的通知中进行遍历
        if ([[notify.userInfo objectForKey:@"requestIdentifier"] isEqualToString:requestIdentifier]) {
            // 取消一个特定的通知
            [[UIApplication sharedApplication] cancelLocalNotification:notify];
            break;
        }
    }
}


//{"aps":{"alert":"This is some fancy message.","badge":4,"sound": "default"}}

//MARK:- 通知调用这个方法
+ (void)handleRemoteNotification:(NSDictionary *)dic{
    UIApplication *application = [UIApplication sharedApplication];
    /*
     UIApplicationStateActive 应用程序处于前台
     UIApplicationStateBackground 应用程序在后台，用户从通知中心点击消息将程序从后台调至前台
     UIApplicationStateInactive 用用程序处于关闭状态(不在前台也不在后台)，用户通过点击通知中心的消息将客户端从关闭状态调至前台 */
    //应用程序在前台给一个提示特别消息
    
    //    NSDictionary *aps = dic[@"aps"];
    //    NSDictionary *alert = aps[@"alert"];
    
    //    [self sendLocalNotificationTitle:@"本地通知"
    //                            WithBody:alert[@"subtitle"]
    //                            WithBody:alert[@"body"]
    //                      WithIdentifier:@"loacl"];
    
    if (application.applicationState == UIApplicationStateActive) {
        //应用程序在前台
        NSLog(@"通知来了,在前台 %@",dic);
        //        [self createAlertViewControllerWithPushDict:userInfo];
    }else{
        NSLog(@"通知来了,从后台进入 %@",dic);
        //其他两种情况，一种在后台程序没有被杀死，另一种是在程序已经杀死。用户点击推送的消息进入app的情况处理。
        //        [self handlePushMessage:userInfo];
    }
}


//MARK:- 注册deviceToken
+ (void)registerDeviceToken:(NSData *)deviceToken{
    NSString *deviceString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceString = [deviceString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"%@", [NSString stringWithFormat:@"设备Token: %@", deviceString]);
    
    NSString *uuid = [FCUUID uuidForDevice];
    
    NSDictionary *param = @{@"mid":uuid,
                            @"token":deviceString};
    
    NSDictionary *param1 = @{@"data":param};
    
    [APNetworkHelper xt_postRequestWithType:XTNetworkRequestTypeDeviceToken parameters:param1 response:^(NSDictionary *dict) {
        NSLog(@"上报Device成功:\n%@", dict)
    } error:^(NSError *error) {
        NSLog(@"上报Device失败:\n%@", error)
    }];
}

//MARK:- 注册远程通知
+ (void)registerRemoteNoti{
    
    [self shared];
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter * center = [UNUserNotificationCenter currentNotificationCenter];
        
        [center setDelegate:[self shared]];
        
        UNAuthorizationOptions type = UNAuthorizationOptionBadge|UNAuthorizationOptionSound|UNAuthorizationOptionAlert;
        [center requestAuthorizationWithOptions:type completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                NSLog(@"remoteNotification注册成功");
            }else{
                NSLog(@"remoteNotification注册失败");
            }
        }];
    }else if (@available(iOS 8.0, *)){
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound |
        UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    [application registerForRemoteNotifications];
}


static APPushTool *shared = nil;
+ (APPushTool *)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[APPushTool alloc] init];
    });
    return shared;
}


//willPresentNotification:withCompletionHandler 用于前台运行
//didReceiveNotificationResponse:withCompletionHandler 用于后台及程序退出
//didReceiveRemoteNotification:fetchCompletionHandler用于静默推送
//静默推送通知 会调用的方法
//静默推送: iOS7以后出现, 不会出现提醒及声音.
//要求:
//推送的payload中不能包含alert及sound字段
//需要添加content-available字段, 并设置值为1
//例如: {"aps":{"content-available":"1"},"PageKey”":"2"}


//MARK:- UNUserNotificationCenterDelegate  iOS 10之后会调用 用于前台运行
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [APPushTool handleRemoteNotification:userInfo];
    }
    //completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

///用于后台及程序退出
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [APPushTool handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}
@end
