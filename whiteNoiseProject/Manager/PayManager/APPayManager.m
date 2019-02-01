//
//  APPayManager.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/25.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APPayManager.h"
#import <StoreKit/StoreKit.h>
#import <AFNetworking/AFNetworking.h>
#import "NSDictionary+DeleteNull.h"

#import "APDataHelper.h"

#import "APNetworkHelper.h"


//沙盒测试环境验证
#define SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"
//正式环境验证
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt"

@interface APPayManager () <SKPaymentTransactionObserver, SKProductsRequestDelegate, SKRequestDelegate>

@property (nonatomic, copy)   NSString     *ProductID;
@property (nonatomic, copy)   void(^verifyFinsh)(void);
@property (nonatomic, assign) NSString     *isExpires;
@property (nonatomic, assign) NSInteger    verifyCount;// 验证票据次数
@property (nonatomic, assign) long long    timeDF;//时差 ms
@property (nonatomic, assign) BOOL         isTime;//是否有时差
@property (nonatomic, assign) BOOL         isAdjust;//时间是否已校正
@property (nonatomic, assign) NSInteger    adjustCount;

@end

@implementation APPayManager

+ (instancetype) shareInstance{
    static APPayManager* _instance = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
        _instance.adjustCount = 0;
        _instance.verifyCount = 0;
        _instance.isTime = NO;
        [_instance getNewestServerTime:^(NSString *time) {
            NSString *currentTime = [_instance currentTimeStr];
            _instance.timeDF = time.longLongValue - currentTime.longLongValue;
        }];
    }) ;
    return _instance ;
}

-(void)addPayTransactionObserver{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

-(void)removePayTransactionObserver{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

-(void)paymentWithProductID:(NSString *)ProductID{
    
    self.ProductID = ProductID;
    if ([SKPaymentQueue canMakePayments]) {
        [self requestProductData:ProductID];
    }else{
        NSLog(@"不允许程序内付费");
        [self paymentStatusWithType:not_allowed_pay_status];
    }
}

// 去苹果服务器请求产品信息
- (void)requestProductData:(NSString *)productId {
    NSArray *productArr = [[NSArray alloc]initWithObjects:productId, nil];
    NSSet *productSet = [NSSet setWithArray:productArr];
    SKProductsRequest *request = [[SKProductsRequest alloc]initWithProductIdentifiers:productSet];
    request.delegate = self;
    [request start];
}

// 收到产品返回信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *productArr = response.products;
    
    if ([productArr count] == 0) {
        [self paymentStatusWithType:no_product_status];
        NSLog(@"没有该商品");
        return;
    }
    
    NSLog(@"productId = %@",response.invalidProductIdentifiers);
    NSLog(@"产品付费数量 = %zd",productArr.count);
    
    SKProduct *p = nil;
    
    for (SKProduct *pro in productArr) {
        NSLog(@"description:%@",[pro description]);
        NSLog(@"localizedTitle:%@",[pro localizedTitle]);
        NSLog(@"localizedDescription:%@",[pro localizedDescription]);
        NSLog(@"price:%@",[pro price]);
        NSLog(@"productIdentifier:%@",[pro productIdentifier]);
        
        if ([pro.productIdentifier isEqualToString:self.ProductID]) {
            p = pro;
        }
    }
    
    if (p) {
        SKPayment *payment = [SKPayment paymentWithProduct:p];
        //发送内购请求
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    
}

// 监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *tran in transactions) {
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased: //交易完成
                // 发送到苹果服务器验证凭证
                [self verifyPurchaseWithPaymentTransactionUrlStr:AppStore];
                [[SKPaymentQueue defaultQueue]finishTransaction:tran];
                break;
            case SKPaymentTransactionStatePurchasing: //商品添加进列表
                
                break;
            case SKPaymentTransactionStateRestored: //购买过
                // 发送到苹果服务器验证凭证
                [self verifyPurchaseWithPaymentTransactionUrlStr:AppStore];
                [[SKPaymentQueue defaultQueue]finishTransaction:tran];
                break;
            case SKPaymentTransactionStateFailed: //交易失败
                [[SKPaymentQueue defaultQueue]finishTransaction:tran];
                if (tran.error.code != SKErrorPaymentCancelled) {
                    [self paymentStatusWithType:app_store_connect_fail_status error:tran.error];
                } else {
                    [self paymentStatusWithType:user_cancel error:tran.error];
                }
                break;
            default:
                break;
        }
    }
}


-(void)verifyPurchaseWithPaymentTransactionUrlStr:(NSString *)urlStr{
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSLog(@"验证中.....");
    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
    
    NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
    if (!receiptString) {
        return;
    }
    NSDictionary* param = @{@"receipt-data":receiptString, @"password":IAP_SECRET};
    //    [APDataHelper saveReceiptInfo:receiptString];//保存收据
    [APDataHelper saveLatestReceiptStr:receiptString];
    NSError* jsonError;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:&jsonError];
    if (jsonError) {
        return;
    }
    NSURLSession *session = [NSURLSession sharedSession];
    //创建请求到苹果官方进行购买验证
    NSURL *url=[NSURL URLWithString:urlStr];
    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
    requestM.HTTPBody=bodyData;
    requestM.HTTPMethod=@"POST";
    
    NSURLSessionDataTask* task = [session dataTaskWithRequest:requestM completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        if (error) {
            NSLog(@"验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
            self.verifyCount++;
            if (self.verifyCount<2) {
                NSLog(@"第%zd次验证........",self.verifyCount);
                [self verifyPurchaseWithPaymentTransactionUrlStr:AppStore];
            }else{
                NSLog(@"不再尝试........");
                self.verifyCount = 0;
                [self paymentStatusWithType:verify_timeout_status];
            }
            return;
        }
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"resp:%@",dic);
        if([dic[@"status"] intValue]==0){
            [APDataHelper saveTransactionInfo:dic];
            [APDataHelper saveLatestReceiptStr:dic[@"latest_receipt"]];
            //latest_receipt
            NSLog(@"购买成功！");
            
            [self logExpiresTimetype:3];
            if ([self isExpiresMethod]) {
                self.isExpires = nil;
                [self paymentStatusWithType:payment_succeed_status];
            }else{
                //                [APDataHelper saveReceiptInfo:@""];
                [APDataHelper saveLatestReceiptStr:@""];
                [self paymentStatusWithType:vip_Expires_status];
            }
        }else{
            
            if ([dic[@"status"] intValue] == 21007) {
                NSLog(@"appstore验证转沙盒验证");
                // [self showerrorInfoWithstr:@"沙盒环境"];
                
                [self verifyPurchaseWithPaymentTransactionUrlStr:SANDBOX];
            }else{
                NSLog(@"购买失败，未通过验证！");
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",error.localizedDescription]];
                [self paymentStatusWithType:verify_fail_status];
            }
        }
    }];
    [task resume];
    return;
}

- (void)requestDidFinish:(SKRequest *)request {
    if ([request isMemberOfClass:[SKReceiptRefreshRequest class]]) {
        [self verifyPurchaseWithPaymentTransactionUrlStr:AppStore complete:^(BOOL isVip) {
        }];
    }
}
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(paymentTransactionFailureType:)]) {
        [self.delegate paymentTransactionFailureType:app_store_connect_fail_status];
    }
}

-(void)paymentStatusWithType:(XYPaymentStatus)type{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (type == payment_succeed_status || type == bought_status) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(paymentTransactionSucceedType:)]) {
                [self.delegate paymentTransactionSucceedType:type];
            }
        }else{
            if (self.delegate && [self.delegate respondsToSelector:@selector(paymentTransactionFailureType:)]) {
                [self.delegate paymentTransactionFailureType:type];
            }
        }
    });
    
}

-(void)paymentStatusWithType:(XYPaymentStatus)type error:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    });
    [self paymentStatusWithType:type];
}

-(void)checkSubscriptionStatusComplete:(void(^)(BOOL isVip))complete{
    __weak typeof(self) weakself = self;
    
    
    //    NSString *receiptStr = [APDataHelper readReceiptInfo];
    NSString *receiptStr = [APDataHelper readLatestReceipt];
    if (!(receiptStr && receiptStr.length)) {
        self.isVip = false;
        if (complete) {
            complete(false);
        }
        return;
    }
    
    if ([self isExpiresMethod]) {
        [self logExpiresTimetype:1];
        if (complete) {
            self.isVip = true;
            complete(true);
        }
    }else{
        [self verifyPurchaseWithPaymentTransactionUrlStr:AppStore complete:^(BOOL isVip) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    weakself.isVip = isVip;
                    complete(isVip);
                }
            });
        }];
    }
}

-(void)verifyPurchaseWithPaymentTransactionUrlStr:(NSString *)urlStr complete:(void(^)(BOOL isVip))complete{
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
    
    NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
    if (!receiptData) {
        //       receiptString = [APDataHelper readReceiptInfo];
        receiptString = [APDataHelper readLatestReceipt];
    }
    
    NSDictionary* param = @{@"receipt-data":receiptString, @"password":IAP_SECRET};
    [APDataHelper saveReceiptInfo:receiptString];//保存收据
    NSError* jsonError;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:&jsonError];
    if (jsonError) {
        return;
    }
    NSURLSession *session = [NSURLSession sharedSession];
    //创建请求到苹果官方进行购买验证
    NSURL *url=[NSURL URLWithString:urlStr];
    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
    requestM.HTTPBody=bodyData;
    requestM.HTTPMethod=@"POST";
#ifdef DEBUG
    //    [SVProgressHUD showWithStatus:@"verifyPurchaseWithPaymentTransactionUrlStr"];
#endif
    NSURLSessionDataTask* task = [session dataTaskWithRequest:requestM completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        if (error) {
            NSLog(@"验证过期失败，请求超时 ⚠️⚠️⚠️  错误信息：%@",error.localizedDescription);
            //   [SVProgressHUD showInfoWithStatus:error.localizedDescription];
            if (complete) {
                complete(false);
            }
            return;
        }
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if([dic[@"status"] intValue]==0){
            [SVProgressHUD dismiss];
            [APDataHelper saveTransactionInfo:dic];
            [APDataHelper saveLatestReceiptStr:dic[@"latest_receipt"]];
            //            NSDictionary *dicReceipt= dic[@"receipt"];
            if ([self isExpiresMethod]) {
                if (complete) {
                    complete(true);
                }
            }else{
                //                    [APDataHelper saveReceiptInfo:@""];
                [APDataHelper saveLatestReceiptStr:@""];
                if (complete) {
                    complete(false);
                }
            }
            [self logExpiresTimetype:2];
        }else{
            if ([dic[@"status"] intValue] == 21007) {
                NSLog(@"沙河票据发送到线上环境验证   code:%@",dic[@"status"]);
                // [self showerrorInfoWithstr:@"沙盒环境"];
                [self verifyPurchaseWithPaymentTransactionUrlStr:SANDBOX complete:complete];
            }else{
                [SVProgressHUD dismiss];
                [self refreshReceipt];
                NSLog(@"验证失败 code=:%@",dic[@"status"]);
                if ([dic[@"status"] integerValue] == 21006) {
                    complete(false);
                }else{
                    complete(false);
                }
            }
        }
    }];
    [task resume];
    return;
    
}

-(BOOL)isExpiresMethod{
    
    //    if (!self.isAdjust) {
    //        return NO;
    //    }
    if (self.isTime) {  // 有时差
        return [APDataHelper getExpiresDate_ms] > ([self currentTimeStr].longLongValue + self.timeDF);
    }else{  //无时差
        return [APDataHelper getExpiresDate_ms] > [self currentTimeStr].longLongValue;
    }
    
}

//获取当前时间戳
- (NSString *)currentTimeStr{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

- (NSString *)timeWithTimeIntervalString:(NSString *)timeString
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]/ 1000.0];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}

-(void)logExpiresTimetype:(NSInteger)type{
#ifdef DEBUG
    NSString *expiresStr = [NSString stringWithFormat:@"%lld",[APDataHelper getExpiresDate_ms]];
    NSString *currentStr = [NSString stringWithFormat:@"%lld",[self currentTimeStr].longLongValue];
    if (self.isTime) {
        currentStr = [NSString stringWithFormat:@"%lld",[self currentTimeStr].longLongValue + self.timeDF];
    }
    NSLog(@"===========到期时间: %@  ===========当前时间: %@=====%zd  ⚠️⚠️⚠️",[self timeWithTimeIntervalString:expiresStr],[self timeWithTimeIntervalString:currentStr],type);
#endif
}

-(void)getNewestServerTime:(void(^)(NSString *))complete{
    __weak typeof(self) weakself = self;
    
    [APNetworkHelper xt_postRequestWithType:XTNetworkRequestTypeConfig parameters:nil response:^(NSDictionary *dict) {
        NSString *time = dict[@"timestamp"];
        if (time && complete) {
            NSLog(@"%@",[self currentTimeStr]);
            long long timeDi = time.longLongValue - [self currentTimeStr].longLongValue;
            NSString *timeDiStr = [NSString stringWithFormat:@"%lld",timeDi];
            NSString *unTimediStr = [timeDiStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
            if (unTimediStr.longLongValue<(60*1000)) {
                weakself.isTime = NO;
            }else{
                weakself.isTime = YES;
            }
            complete(time);
            self.isAdjust = YES;
            [self checkSubscriptionStatusComplete:nil];
        }
        if ([dict[@"code"] integerValue] == 1) {
            NSDictionary* data = [dict objectForKey:@"data"];
            [[NSUserDefaults standardUserDefaults]setObject:[NSDictionary changeType:data] forKey:@"config_dict"];
            
        }else{
            
        }
    } error:^(NSError *error) {
        if (self.adjustCount < 3) {
            self.adjustCount++;
            [self getNewestServerTime:complete];
        }
        
    }];
    
}

-(void)refreshReceipt{
    SKReceiptRefreshRequest *receiptRrfreshRequest = [[SKReceiptRefreshRequest alloc]init];
    receiptRrfreshRequest.delegate = self;
    [receiptRrfreshRequest start];
}

#pragma - mark  代码优化

-(void)purchaseCompleteVerifyUrlStr:(NSString *)urlStr{
    [self verifyPaymentTransactionUrlStr:urlStr success:^(NSDictionary *responseObject) {
        if([responseObject[@"status"] intValue]==0){
            [APDataHelper saveTransactionInfo:responseObject];
            [APDataHelper saveLatestReceiptStr:responseObject[@"latest_receipt"]];
            //latest_receipt
            NSLog(@"购买成功！");
#ifdef DEBUG
            [SVProgressHUD showSuccessWithStatus:@"success"];
#endif
            [self logExpiresTimetype:3];
            if ([self isExpiresMethod]) {
                self.isExpires = nil;
                [self paymentStatusWithType:payment_succeed_status];
            }else{
                [APDataHelper saveLatestReceiptStr:@""];
                [self paymentStatusWithType:vip_Expires_status];
            }
        }else{
            
            if ([responseObject[@"status"] intValue] == 21007) {
                NSLog(@"appstore验证转沙盒验证");
                // [self showerrorInfoWithstr:@"沙盒环境"];
#ifdef DEBUG
                [SVProgressHUD showErrorWithStatus:@"appstore验证转沙盒验证"];
#endif
                [self purchaseCompleteVerifyUrlStr:SANDBOX];
            }else{
                NSLog(@"购买失败，未通过验证！");
                [self paymentStatusWithType:verify_fail_status];
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
        
        if (self.verifyCount<2) {
            self.verifyCount++;
#ifdef DEBUG
            [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"错误:%@,重新验证, 验证第%zd次",error.localizedDescription,self.verifyCount]];
#endif
            [self purchaseCompleteVerifyUrlStr:AppStore];
        }else{
#ifdef DEBUG
            [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"不再尝试"]];
#endif
            self.verifyCount = 0;
            [self paymentStatusWithType:verify_timeout_status];
        }
    }];
}

-(void)purchaseCompleteVerifyUrlStr:(NSString *)urlStr complete:(void(^)(BOOL isVip))complete{
    [self verifyPaymentTransactionUrlStr:urlStr success:^(NSDictionary *responseObject) {
        if([responseObject[@"status"] intValue]==0){
            [SVProgressHUD dismiss];
            [APDataHelper saveTransactionInfo:responseObject];
            [APDataHelper saveLatestReceiptStr:responseObject[@"latest_receipt"]];
            //            NSDictionary *dicReceipt= dic[@"receipt"];
            if ([self isExpiresMethod]) {
                if (complete) {
                    self.isVip = YES;
                    complete(true);
                }
            }else{
                //                    [APDataHelper saveReceiptInfo:@""];
                [APDataHelper saveLatestReceiptStr:@""];
                if (complete) {
                    complete(false);
                }
            }
            [self logExpiresTimetype:2];
        }else{
            if ([responseObject[@"status"] intValue] == 21007) {
                NSLog(@"沙河票据发送到线上环境验证   code:%@",responseObject[@"status"]);
                // [self showerrorInfoWithstr:@"沙盒环境"];
                [self verifyPurchaseWithPaymentTransactionUrlStr:SANDBOX complete:complete];
            }else{
                [SVProgressHUD dismiss];
                [self refreshReceipt];
                NSLog(@"验证失败 code=:%@",responseObject[@"status"]);
                if ([responseObject[@"status"] integerValue] == 21006) {
                    complete(false);
                }else{
                    complete(false);
                }
            }
        }
    } failure:^(NSError *error) {
        if (complete) {
            complete(false);
        }
    }];
}

-(void)verifyPaymentTransactionUrlStr:(NSString *)urlStr success:(void (^)(NSDictionary* responseObject))success failure:(void (^)(NSError *error))failure{
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSLog(@"验证中.....");
    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
    
    NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
    if (!receiptString) {
        receiptString = [APDataHelper readLatestReceipt];
        if (!receiptString) {
            return;
        }
    }
    NSDictionary* param = @{@"receipt-data":receiptString, @"password":IAP_SECRET};
    [APDataHelper saveLatestReceiptStr:receiptString];
    NSError* jsonError;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:&jsonError];
    if (jsonError) {
        failure(jsonError);
        return;
    }
    NSURLSession *session = [NSURLSession sharedSession];
    //创建请求到苹果官方进行购买验证
    NSURL *url=[NSURL URLWithString:urlStr];
    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
    requestM.HTTPBody=bodyData;
    requestM.HTTPMethod=@"POST";
    NSURLSessionDataTask* task = [session dataTaskWithRequest:requestM completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        if (error) {
            NSLog(@"验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
            failure(error);
            return;
        }
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"resp:%@",dic);
        if([dic[@"status"] intValue]==0){
            success(dic);
        }else{
            success(dic);
        }
    }];
    [task resume];
    return;
}

@end
