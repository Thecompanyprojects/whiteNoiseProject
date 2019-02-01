
#import "APNetworkHelper.h"
#import "NSString+Blowfish.h"
#import "APLogTool.h"

static NSString * const kBaseUrlString = @"http://www.inoiseonea.com/api/v3/";

@implementation APNetworkHelper

#pragma mark - 获取完成整请求链接
+ (NSString *)xt_requestUrlWithType:(XTNetworkRequestType)type {
    NSString *subSrl = nil;
    switch (type) {
        case XTNetworkRequestTypeConfig:
            subSrl = @"config/whitenoise_ios";
            break;
        case XTNetworkRequestTypeResource:
            subSrl = @"whitenoise/whitenoise_ios";
            break;
        case XTNetworkRequestTypeDeviceToken:
            subSrl = @"device_token/whitenoise_ios";
            break;
        case XTNetworkRequestTypeFeedBack:
            subSrl = @"feedback/whitenoise_ios";
            break;
        case XTNetworkRequestTypeClasses:
            subSrl = @"whitenoise_class/whitenoise_ios";
            break;
        case XTNetworkRequestTypeCustom:
            subSrl = @"whitenose_second/whitenoise_ios";
            break;
        default:{
            subSrl = @"";
        } break;
    }
    return [NSString stringWithFormat:@"%@%@",kBaseUrlString, subSrl];
}



#pragma mark - 网络请求
+ (void)xt_postRequestWithType:(XTNetworkRequestType)requestType parameters:(NSDictionary *)parameters response:(void (^)(NSDictionary *dict))responseBlock error:(void (^)(NSError *error))errorBlock {
    if (requestType == XTNetworkRequestTypeNone) {
        return;
    }
    
    // 参数处理
    if (parameters) {
        parameters = [self xt_encryptRequestParameters:parameters];
    } else {
        parameters = @{};
    }
    
    // 设置默认请求和响应数据类型
    [YGNetworkHelper setRequestSerializer:YGRequestSerializerHTTP];
    [YGNetworkHelper setResponseSerializer:YGResponseSerializerHTTP];
    
    NSString *url = [self xt_requestUrlWithType:requestType];
    
    // 取消重复请求
    //    [YGNetworkHelper cancelRequestWithURL:url];
    
    [YGNetworkHelper POST:url parameters:parameters responseCache:^(id responseCache) {
        // 缓存数据
        
    } success:^(id responseObject) { // 请求成功
        // 需要先转十六进制的data
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSData *data = [self xt_stringToHexData:responseString];
        // 解密需要时Base64的字符串
        NSString *base64Str = [data base64EncodedStringWithOptions:0];
        // 使用秘钥进行解密,得到的是结果字符串
        NSString *resultStr = [base64Str blowFishDecodingWithKey:BlowFishKey];
        // 解密完成后转成Data以便之后进行序列化
        NSData *resultData = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
        
        if (resultData) { // 解密成功
            // 解析数据
            NSError *serializationError;
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:&serializationError];
            // 解析错误
            if (serializationError) {
                [[APLogTool shareManager] addLogKey1:@"network" key2:@"request" content:@{@"state":@"failed", @"url":url, @"code":@(serializationError.code), @"message":serializationError.localizedDescription?:@""} userInfo:nil upload:NO];
                
                if (errorBlock) {
                    NSError *error_dec = [NSError errorWithDomain:NSCocoaErrorDomain code:-999 userInfo:@{@"reason":@"decrypt failed"}];
                    errorBlock(error_dec);
                }
            } else { // 解析成功
                [[APLogTool shareManager] addLogKey1:@"network" key2:@"request" content:@{@"state":@"success", @"url":url} userInfo:nil upload:NO];
                
                if (responseBlock) {
                    responseBlock(resultDict);
                }
            }
        } else { // 解密失败
            if (errorBlock) {
                NSError *error_dec = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"decrypt failed"}];
                [[APLogTool shareManager] addLogKey1:@"network" key2:@"request" content:@{@"state":@"failed", @"url":url, @"code":@(error_dec.code), @"message":error_dec.localizedDescription?:@""} userInfo:nil upload:NO];
                errorBlock(error_dec);
            }
        }
        
    } failure:^(NSError *error) { // 请求失败
        
        [[APLogTool shareManager] addLogKey1:@"network" key2:@"request" content:@{@"state":@"failed", @"url":url, @"code":@(error.code), @"message":error.localizedDescription?:@""} userInfo:nil upload:NO];
        
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}




#pragma mark - 请求参数加密
+ (NSDictionary *)xt_encryptRequestParameters:(NSDictionary *)parameters {
    if (parameters.allKeys.count <= 0) {
        return @{};
    }
    
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    for (NSString *key in parameters.allKeys) {
        id value = [parameters objectForKey:key];
        
        if ([value isKindOfClass:NSDictionary.class]){
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:nil];
            NSString * str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            value = str;
        }else if (![value isKindOfClass:NSString.class]){
            value = [NSString stringWithFormat:@"%@",value];
        }
        
        NSString *value_bf_base64 = [value blowFishEncodingWithKey:BlowFishKey];
        NSData *value_bf_data = [[NSData alloc] initWithBase64EncodedString:value_bf_base64 options:0];
        NSString *value_bf_hex_str = [self xt_hexStringFromData:value_bf_data];
        if (value_bf_hex_str) {
            [dictM setObject:value_bf_hex_str forKey:key];
        }
    }
    return dictM.copy;
}

#pragma mark - Data转十六进制字符串
+ (NSString *)xt_hexStringFromData:(NSData *)myD {
    Byte *bytes = (Byte *)[myD bytes];
    NSMutableString *hexStr=[NSMutableString new];
    @autoreleasepool{
        for(int i=0;i<[myD length];i++){
            NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
            if([newHexStr length]==1){
                [hexStr appendString:[NSString stringWithFormat:@"0%@",newHexStr]];
            }else{
                [hexStr appendString:[NSString stringWithFormat:@"%@",newHexStr]];
            }
        }
    }
    return hexStr;
}

#pragma mark - 十六进制字符串转Data
+ (NSData *)xt_stringToHexData:(NSString *)hexStr {
    unsigned long len = [hexStr length] / 2;    // Target length
    unsigned char *buf = malloc(len);
    unsigned char *whole_byte = buf;
    char byte_chars[3] = {'\0','\0','\0'};
    
    int i;
    for (i=0; i < [hexStr length] / 2; i++) {
        byte_chars[0] = [hexStr characterAtIndex:i*2];
        byte_chars[1] = [hexStr characterAtIndex:i*2+1];
        *whole_byte = strtol(byte_chars, NULL, 16);
        whole_byte++;
    }
    
    NSData *data = [NSData dataWithBytes:buf length:len];
    free( buf );
    return data;
}


//+ (NSData *)xt_hexStringToData:(NSString *)hexString{
//    const char *chars = [hexString UTF8String];
//    int i = 0;
//    int len = (int)hexString.length;
//    NSMutableData *data = [NSMutableData dataWithCapacity:len/2];
//    char byteChars[3] = {'\0','\0','\0'};
//    unsigned long wholeByte;
//
//    while (i<len) {
//        byteChars[0] = chars[i++];
//        byteChars[1] = chars[i++];
//        wholeByte = strtoul(byteChars, NULL, 16);
//        [data appendBytes:&wholeByte length:1];
//    }
//    return data;
//}


@end
