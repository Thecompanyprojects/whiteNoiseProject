//
//  AppDelegate.m
//  whiteNoiseProject
//
//  Created by 郝锐 on 2018/12/10.
//  Copyright © 2018年 skunkworks. All rights reserved.
//

#import "APAppDelegate.h"

#import "APLogTool.h"
#import "APLogDataTool.h"
#import "APMenuVC.h"
#import "APPushTool.h"
#import "APTool.h"
#import "APCuntomTool.h"

#import "APHomeVC.h"
#import "APMenuVC.h"
#import "APNavVC.h"

@interface APAppDelegate ()
@property(nonatomic,strong) MMDrawerController * drawerController;
@end

@implementation APAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[APLogTool shareManager] uploadLocalLogData];
    
    // 异常捕获
    [APTool abortExceptionIntercept];
    
    // 监听网络状态
    [APTool monitorNetworkStatus];
    
    // 第三方异常捕获
    [APTool buglySdkStart];
    
    // SVHUD默认设置
    [APTool svProgressHUDSetup];
    
    // 请求配置信息
    [APTool requestConfigData];
    
    // 更新本地数据库
    [APTool musicSQLUpdate];
    
    // 主界面目录信息配置网络请求
    [APTool requestHomeListData];
    
    // 注册远程通知
    [APPushTool registerRemoteNoti];
    
    // 请求自定义数据
    [[APCuntomTool sharedCuntomTool] requestData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self aliveLogOptions:launchOptions];
    });
    
    [self ap_windowSetup];
    return YES;
}

#pragma mark - 设置主Window
- (void)ap_windowSetup {
    // Window设置
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    APMenuVC *menuController = [APMenuVC new];
    APHomeVC *homeController = [[APHomeVC alloc] init];
    APNavVC *mainNavigationController = [[APNavVC alloc] initWithRootViewController:homeController];

    menuController.selectBlock = homeController.selectBlock_tabbar;
    
    self.drawerController = [[MMDrawerController alloc] initWithCenterViewController:mainNavigationController leftDrawerViewController:menuController];
    self.drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
    self.drawerController.shouldStretchDrawer = NO;
    self.drawerController.showsShadow = NO;
    self.drawerController.maximumLeftDrawerWidth = 230*KWIDTH;
    // 动画视差
    [self.drawerController setDrawerVisualStateBlock:[MMDrawerVisualState parallaxVisualStateBlockWithParallaxFactor:3.0]];
    
    self.window.rootViewController = self.drawerController;
    [self.window makeKeyAndVisible];
}

/** 监听远程事件 */
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotifLockScreenCenterOperate"
                                                        object:nil
                                                      userInfo:@{@"event":event}];
}


- (void)aliveLogOptions:(NSDictionary *)launchOptions{
    NSString* version_def = [[NSUserDefaults standardUserDefaults] objectForKey:@"version_def"];
    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSString *key_2 = @"icon";
    // 判断启动方式
    if (launchOptions) {
        
        // 远程通知
        NSDictionary *payload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (payload) {
            key_2 = @"notification_remote";
        }
        
        // 有本地通知
        UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (localNotification) {
            key_2 = @"notification_local";
        }
        
        // 有第三方APP调用
        NSURL* launchURL = (NSURL*)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
        if (launchURL) {
            key_2 = @"other";//scheme
        }
        
    }
    
    [[APLogTool shareManager] addLogKey1:@"start" key2:key_2 content:@{@"net":[NSString getNetWorkStates]} userInfo:nil upload:YES];
    
    
    
    if (!version_def) {
        // 新用户
        [[APLogTool shareManager] addLogKey1:@"alive" key2:@"new" content:nil userInfo:nil upload:YES];
        [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"version_def"];
    } else {
        if (![version isEqualToString:version_def]) {
            // 升级用户
            [[APLogTool shareManager] addLogKey1:@"alive" key2:@"update" content:nil userInfo:nil upload:YES];
            [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"version_def"];
        } else {
            // 活跃用户
            [[APLogTool shareManager] addLogKey1:@"alive" key2:@"application" content:nil userInfo:nil upload:YES];
        }
    }
}


- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler{
    BOOL handled = [[FIRDynamicLinks dynamicLinks] handleUniversalLink:userActivity.webpageURL
                                                            completion:^(FIRDynamicLink * _Nullable dynamicLink,
                                                                         NSError * _Nullable error) {
                                                                
                                                            }];
    if (@available(iOS 11.0, *)) {
        [[FIRDynamicLinks dynamicLinks] handleUniversalLink:userActivity.referrerURL
                                                 completion:^(FIRDynamicLink * _Nullable dynamicLink,
                                                              NSError * _Nullable error) {
                                                     
                                                 }];
    } else {
        // Fallback on earlier versions
    }
    return handled;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options{
    
    return [self application:app
                     openURL:url
           sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                  annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    FIRDynamicLink *dynamicLink = [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
    
    if (dynamicLink) {
        if (dynamicLink.url && dynamicLink.matchType == FIRDLMatchTypeUnique) {
            
            [[APLogDataTool shareManager]appendReferrer:[NSString stringWithFormat:@"utm_source=google&utm_medium=%@",dynamicLink.url]];
            [[APLogTool shareManager] addLogKey1:@"source" key2:[NSString stringWithFormat:@"google"] content:@{@"deeplink":[NSString stringWithFormat:@"utm_source=google&utm_medium=%@",dynamicLink.url]} userInfo:@{} upload:NO];
            
            // Handle the deep link. For example, show the deep-linked content,
            // apply a promotional offer to the user's account or show customized onboarding view.
            // ...
        } else {
            // Dynamic link has empty deep link. This situation will happens if
            // Firebase Dynamic Links iOS SDK tried to retrieve pending dynamic link,
            // but pending link is not available for this device/App combination.
            // At this point you may display default onboarding view.
        }
        return YES;
    }
    return NO;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[APLogTool shareManager] addLogKey1:@"start" key2:@"background_out" content:@{@"net":[NSString getNetWorkStates]} userInfo:nil upload:YES];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[APLogTool shareManager] addLogKey1:@"start" key2:@"background_enter" content:@{@"net":[NSString getNetWorkStates]} userInfo:nil upload:YES];
    [FBSDKAppEvents activateApp];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [[APLogTool shareManager] addLogKey1:@"start" key2:@"terminate" content:@{@"net":[NSString getNetWorkStates]} userInfo:nil upload:YES];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [APPushTool registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
}


//MARK:- iOS10以下，应用在前台的时候，有推送来，会直接来到这个方法。但是通知栏不会有提示，角标也不会有。应用如果在后台或者在关闭状态，点击推送来的消息也会来到这个方法。在这里处理业务逻辑。（静默推送）
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [APPushTool handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}


@end
