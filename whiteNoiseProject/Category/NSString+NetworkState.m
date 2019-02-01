//
//  NSString+NetworkState.m
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "NSString+NetworkState.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@implementation NSString (NetworkState)

+ (NSString *)getNetWorkStates {
    
    BOOL isWifi = [AFNetworkReachabilityManager sharedManager].isReachableViaWiFi;
    BOOL isWWAN = [AFNetworkReachabilityManager sharedManager].isReachableViaWWAN;
    NSString *state = @"null";
    if (isWifi) {
        state = @"wifi";
    } else if (isWWAN) {
        CTTelephonyNetworkInfo *_telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
        NSString *currentStatus = _telephonyInfo.currentRadioAccessTechnology;
        if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]){
            state = @"2G";
            
        } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]){
            //2.75G的EDGE网络
            state = @"2G";
            
        } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){
            //3G WCDMA网络
            state = @"3G";
            
        } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){
            //3.5G网络
            state = @"3G";
            
        } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){
            //3.5G网络
            state = @"3G";
            
        } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){
            //CDMA2G网络
            state = @"2G";
            
        } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){
            //CDMA的EVDORev0(应该算3G吧?)
            state = @"3G";
            
        } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){
            //CDMA的EVDORevA(应该也算3G吧?)
            state = @"3G";
            
        } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){
            //CDMA的EVDORev0(应该是算3G吧?)
            state = @"3G";
            
        } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){
            //HRPD网络
            state = @"4G";
            
        } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){
            //LTE4G网络
            state = @"4G";
        }
        
    } else {
        state = @"null";
    }
    
    return state;
}

@end
