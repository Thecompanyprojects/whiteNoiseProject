//
//  APPayManager.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/25.
//  Copyright © 2018 skunkworks. All rights reserved.
//


#define IAP_SECRET @"4e92985956da4090aab6dfbf189eb54c"


#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    payment_succeed_status,//购买成功
    verify_timeout_status, //购买成功 验证超时
    verify_fail_status,    //购买成功 验证失败
    payment_fail_status,   //支付超时
    no_product_status,     //没有商品
    bought_status,         //购买过
    Transaction_fail_status,//交易失败
    vip_Expires_status,    //vip已过期
    app_store_connect_fail_status, //App Store连接失败
    not_allowed_pay_status, //该设备不允许支付或不能支付
    user_cancel // 用户中途取消了
} XYPaymentStatus;

@protocol APPayManagerDelegate <NSObject>

- (void)paymentTransactionSucceedType:(XYPaymentStatus)SucceedType;
- (void)paymentTransactionFailureType:(XYPaymentStatus)failtype;

@end


@interface APPayManager : NSObject

@property (nonatomic, weak)   id<APPayManagerDelegate>delegate;
@property (nonatomic, assign) BOOL                       isVip;


+ (instancetype) shareInstance;

- (void)addPayTransactionObserver;
- (void)removePayTransactionObserver;
- (void)paymentWithProductID:(NSString *)ProductID;
- (void)refreshReceipt;


-(void)checkSubscriptionStatusComplete:(void(^)(BOOL isVip))complete;

@end


