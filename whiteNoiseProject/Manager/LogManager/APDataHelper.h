//
//  APDataHelper.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//
//
#import <Foundation/Foundation.h>

@interface APDataHelper : NSObject
+ (void)saveDataToKeyChainWithKey:(NSString *)key value:(id)value;
+ (NSString *)readDataFromKeyChainWithKey:(NSString *)key;
+ (NSArray *)readMonthArray;
+ (NSString *)readPrivacyStr;
+ (NSString *)readUUIDFromKeyChain;
+ (void)saveUUIDToKeyChain;
+ (void)saveZodiacIndex:(NSString *)indexStr;
+ (NSString *)readZodiacIndex;
+ (NSString *)readTipsImageStrIndex:(NSInteger)index;
+ (void)saveLatestReceiptStr:(NSString *)ReceiptStr;
+ (NSString *)readLatestReceipt;
+ (void)saveReceiptInfo:(NSString *)ReceiptInfo;
+ (void)saveTransactionInfo:(NSDictionary *)dic;
+ (long long)getExpiresDate_ms;
+ (NSDictionary *)getLatestReceiptInfo;
+ (NSDictionary *)getTransactionInfo;
+ (NSString *)getUUIDString;

+ (void)unusablePayProduck;
//---------------

//保存home页背景图  url
+ (void)saveHomeImageUrl:(NSString *)imageUrl;
//读取home页背景图  url
+ (NSString *)readHomeImageUrl;
//保存home页背景图模糊  url
+ (void)saveVagueHomeImageUrl:(NSString *)imageUrl;
//读取home页背景图模糊  url
+ (NSString *)readVagueHomeImageUrl;
@end
