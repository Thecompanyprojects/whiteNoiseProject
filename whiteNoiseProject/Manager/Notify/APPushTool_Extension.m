//
//  APPushTool_Extension.m
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//


#import "APPushTool_Extension.h"

@implementation APPushTool (Extension)
//MARK:- 发送本地通知
+ (void)registLocalNotificationTitle:(NSString *)title
                            WithBody:(NSString *)subTitle
                            WithBody:(NSString *)body
                      WithIdentifier:(NSString *)identifier{
    
    //1.创建通知中心
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //2.检查当前用户授权
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@"当前授权状态：%zd",[settings authorizationStatus]);
            //3.创建通知
            UNMutableNotificationContent *notification = [[UNMutableNotificationContent alloc] init];
            //3.1通知标题
            notification.title = [NSString localizedUserNotificationStringForKey:title arguments:nil];
            //3.2小标题
            notification.subtitle = subTitle;
            //3.3通知内容
            notification.body = body;
            //3.4通知声音
            notification.sound = [UNNotificationSound defaultSound];
            //3.5通知小圆圈数量
            //        notification.badge = @2;
            //4.创建触发器(相当于iOS9中通知触发的时间)
            /**通知触发器主要有三种
             UNTimeIntervalNotificationTrigger  指定时间触发
             UNCalendarNotificationTrigger  指定日历时间触发
             UNLocationNotificationTrigger 指定区域触发
             */
            
            UNTimeIntervalNotificationTrigger * timeTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
            //5.指定通知的分类  (1)identifer表示创建分类时的唯一标识符
            //（2）该代码一定要在创建通知请求之前设置，否则无效
            notification.categoryIdentifier = @"category";
            
            //给通知添加附件(图片 音乐 电影都可以)
            //            NSString *path = [[NSBundle mainBundle] pathForResource:@"logo" ofType:@"png"];
            //            UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"image" URL:[NSURL fileURLWithPath:path] options:nil error:nil];
            //            notification.attachments = @[attachment];
            
            //7.创建通知请求
            /**
             Identifier:通知请求标识符，用于删除或者查找通知
             content：通知的内容
             trigger：通知触发器
             */
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:notification trigger:timeTrigger];
            
            //8.通知中心发送通知请求
            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                if (error == nil) {
                    NSLog(@"本地通知发送成功");
                }else {
                    NSLog(@"%@",error);
                }
            }];
        }];
    }
}
@end
