//
//  APCrashHandleTool.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface APTool : NSObject


/**
 异常拦截处理
 */
+ (void)abortExceptionIntercept;

/**
 添加网络状态监听
 */
+ (void)monitorNetworkStatus;

/**
 数据库升级
 */
+ (void)musicSQLUpdate;

/**
 请求配置信息
 */
+ (void)requestConfigData;

/**
 网络资源初始化请求
 */
+ (void)requestHomeListData;

/**
 根据相应目录类型获取音乐 从服务器
 
 @param model ClassModel
 @param finishedBlock finishedBlock description
 */
+ (void)getServiceMusicListForModel:(APClassModel *)model finished:(void (^)(NSDictionary *))finishedBlock;
/**
 异常统计上报
 */
+ (void)buglySdkStart;

/**
 SVProgressHUDM默认设置
 */
+ (void)svProgressHUDSetup;




@end
