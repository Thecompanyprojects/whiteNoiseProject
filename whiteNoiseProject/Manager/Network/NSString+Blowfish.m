//
//  NSString+Blowfish.m
//  Sound
//
//  Created by 许亚光 on 2018/8/22.
//  Copyright © 2018年 DDTR. All rights reserved.
//

#import "NSString+Blowfish.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSString (Blowfish)

// 核心代码
+ (NSData *)doBlowfish:(NSData *)dataIn context:(CCOperation)kCCEncrypt_or_kCCDecrypt key:(NSData *)key options:(CCOptions)options iv:(NSData *)iv error:(NSError **)error {
    
    CCCryptorStatus ccStatus   = kCCSuccess;
    size_t          cryptBytes = 0;
    NSMutableData  *dataOut    = [NSMutableData dataWithLength:dataIn.length + kCCBlockSizeBlowfish];
    
    ccStatus = CCCrypt(kCCEncrypt_or_kCCDecrypt,
                       kCCAlgorithmBlowfish,
                       options,
                       key.bytes,
                       key.length,
                       (iv.bytes)?iv.bytes:nil,
                       dataIn.bytes,
                       dataIn.length,
                       dataOut.mutableBytes,
                       dataOut.length,
                       &cryptBytes);
    
    if (ccStatus == kCCSuccess) {
        dataOut.length = cryptBytes;
    } else {
        if (error) {
            *error = [NSError errorWithDomain:@"kEncryptionError" code:ccStatus userInfo:nil];
        }
        dataOut = nil;
    }
    return dataOut;
}


// 加密
- (NSString *)blowFishEncodingWithKey:(NSString *)pkey{
    
    
    
    
    
    if (pkey.length < 8 || pkey.length > 56) {
        NSLog(@"key值的长度必须在[8,56]之间");
        return nil;
    }
    NSError *error;
    NSData *key = [pkey dataUsingEncoding:NSUTF8StringEncoding];
    NSString *stringOriginal = self;
    NSData *dataOriginal = [stringOriginal dataUsingEncoding:NSUTF8StringEncoding];;
    NSData *dataEncrypted = [NSString doBlowfish:dataOriginal
                                         context:kCCEncrypt
                                             key:key
                                         options:kCCOptionPKCS7Padding | kCCOptionECBMode
                                              iv:nil
                                           error:&error];
    
    NSString *encryptedBase64String = [dataEncrypted base64EncodedStringWithOptions:0];
    return encryptedBase64String;
}


// 解密
- (NSString *)blowFishDecodingWithKey:(NSString *)pkey {
    if (pkey.length < 8 || pkey.length > 56) {
        NSLog(@"key值的长度必须在[8,56]之间");
        return nil;
    }
    NSError *error;
    NSData *key = [pkey dataUsingEncoding:NSUTF8StringEncoding];
    NSData *dataToDecrypt = [[NSData alloc] initWithBase64EncodedString:self options:0];
    NSData *dataDecrypted = [NSString doBlowfish:dataToDecrypt
                                         context:kCCDecrypt
                                             key:key
                                         options:kCCOptionPKCS7Padding | kCCOptionECBMode
                                              iv:nil
                                           error:&error];
    
    NSString *stringDecrypted = [[NSString alloc] initWithData:dataDecrypted encoding:NSUTF8StringEncoding];
    return stringDecrypted;
}




@end
