//
//  APCrashHandleTool.m
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//
#import "APTool.h"
#import "APNetworkHelper.h"
#import "APAudioPlayerTools.h"
#import "APNoiseManager.h"
#import <Bugly/Bugly.h>
#import <YGNetworkHelper.h>
#import <YGCrashHelper.h>
@implementation APTool

// 闪退异常
+ (void)abortExceptionIntercept {
    [[YGCrashHelper sharedInstance] ignoreMethod:@[@"loadProductWithParameters",@"setShowsStoreButton"]];
    [[YGCrashHelper sharedInstance] carshHandleAll:^(NSString *errorName, NSString *errorReason, NSString *errorLocation, NSArray *stackSymbols, NSException *exception) {
        [[APLogTool shareManager] addCrashLog:@{@"errorName":errorName, @"errorReason":errorReason, @"errorLocation":errorLocation, @"stackSymbols":stackSymbols} upload:NO];
    }];
    
}


+ (void)monitorNetworkStatus {
    [YGNetworkHelper networkStatusWithBlock:^(YGNetworkStatusType status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkStateDidChanged object:nil userInfo:@{@"state":@(status)}];
    }];
}

+ (void)buglySdkStart {
    [Bugly startWithAppId:kBuglyAppId];
}


+ (void)requestConfigData {
    [[APNoiseManager shareInstance] requstConfigData];
}

+ (void)musicSQLUpdate {
    [[APSQLiteManager shared] updateSQL];
}

+ (void)getServerClasses:(void (^)(NSDictionary *))finishedBlock {
    [APNetworkHelper xt_postRequestWithType:XTNetworkRequestTypeClasses parameters:nil response:^(NSDictionary *dict) {
        [[APSQLiteManager shared]saveClassesInfo:dict];
        if (finishedBlock) {
            finishedBlock(dict);
        }
    } error:^(NSError *error) {
        if (finishedBlock) {
            finishedBlock(nil);
        }
        NSLog(@"请求错误，%@",error);
    }];
}

+ (void)getServiceMusicListForModel:(APClassModel *)model finished:(void (^)(NSDictionary *))finishedBlock {
    //根据传入数据获取对应type的列表
    NSString *str = [NSString stringWithFormat:@"%ld",(long)model.classId];
    [APNetworkHelper xt_postRequestWithType:XTNetworkRequestTypeResource parameters:@{@"data":str} response:^(NSDictionary *dict) {
        
        [[APLogTool shareManager] addLogKey1:@"network" key2:@"request" content:@{@"state":@"success", @"type":model.className_en} userInfo:nil upload:NO];
        
        [[APSQLiteManager shared] saveInfo:dict];
        
        if (finishedBlock) {
            finishedBlock(dict);
        }
        
    } error:^(NSError *error) {
        if (finishedBlock) {
            finishedBlock(nil);
        }
        NSLog(@"请求错误，%@",error);
        
        [[APLogTool shareManager] addLogKey1:@"network" key2:@"request" content:@{@"state":@"failed", @"type":model.className_en,@"code":@(error.code), @"message":error.localizedDescription?:@""} userInfo:nil upload:NO];
    }];
    
}



+ (void)requestHomeListData {
    [self getServerClasses: nil];
}

+ (void)svProgressHUDSetup {
    [SVProgressHUD setInfoImage:[UIImage imageNamed:@""]];
    [SVProgressHUD setErrorImage:[UIImage imageNamed:@""]];
    [SVProgressHUD setSuccessImage:[UIImage imageNamed:@""]];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setMinimumDismissTimeInterval:1];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
