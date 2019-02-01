//
//  XYLogManager.m
//  XToolCuteCamera
//
//  Created by 潘志 on 2018/8/22.
//  Copyright © 2018年 nbt. All rights reserved.
//

#import "APLogTool.h"
#import "NSString+Blowfish.h"
#import "APLogDataTool.h"

#define PATH_FOR_DOC      NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
#define FILE_PATH_AT_DOC(fileName)      [PATH_FOR_DOC stringByAppendingPathComponent:fileName]

//#define kBlowFishKey            @"2GIMeS%aJ%"
//kStatisticsLogURL
#define statisticsPath    @"statistics"
#define crashPath         @"crash"

@interface APLogTool ()

@property (nonatomic, strong) NSMutableArray *muArr;
@property (nonatomic, strong) dispatch_group_t group;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) NSString *countryCode;

@end

@implementation APLogTool

+(instancetype)shareManager{
    static APLogTool *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[APLogTool alloc]init];
    });
    return _instance;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}


-(void)addLogKey1:(NSString *)key1 key2:(NSString *)key2 content:(NSDictionary *)content userInfo:(NSDictionary *)userInfo upload:(BOOL)upload{
    NSString *result = [[APLogDataTool shareManager]handleDataKey1:key1 key2:key2 content:content userInfo:userInfo];
    [self addLogWithStr:result path:FILE_PATH_AT_DOC(statisticsPath) URL:kStatisticsLogURL upload:upload];
}

-(void)addCrashLog:(NSDictionary *)dic upload:(BOOL)upload{
    NSString *result = [[APLogDataTool shareManager]handleCrashDataDic:dic];
    [self addLogWithStr:result path:FILE_PATH_AT_DOC(crashPath) URL:kCrashLogURL upload:upload];
}

//写
-(BOOL)writeData:(NSData *)data path:(NSString *)path{
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
    if (handle) {
        [handle seekToEndOfFile];
        @try {
            [handle writeData:data];
        }
        @catch (NSException *exception) {
            NSLog(@"☘☘☘☘☘☘☘☘☘/n写文件错误！！！write fileHandleForWriting fail: %@/n☘☘☘☘☘☘☘☘☘", exception.reason);
            return NO;
        }
        //        @finally {
        //        }
        [handle closeFile];
        return YES;
    }else{
        return NO;
    }
}

//读
-(NSString *)readDataFormPath:(NSString *)path{
    NSData *data = [[NSData alloc]initWithContentsOfFile:path];
    NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return result;
}

//清除所有打点
//-(void)clearDataForLog{
//    [self clearDataForPath:FILE_PATH_AT_DOC(statisticsPath)];
//    [self clearDataForPath:FILE_PATH_AT_DOC(crashPath)];
//}
//
//-(void)clearDataForStatistics{
//    [self clearDataForPath:FILE_PATH_AT_DOC(statisticsPath)];
//}
//
//-(void)clearDataForCrash{
//    [self clearDataForPath:FILE_PATH_AT_DOC(crashPath)];
//}

-(void)clearDataForPath:(NSString *)path{
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isSuccess = [manager removeItemAtPath:path error:nil];
    if (!isSuccess) {
        NSLog(@"清除失败");
    }
}

#pragma  mark  -  添加打点信息

//-(void)addLog:(XYLogInfo *)log{
//    if (log.type == XYLogTypeStatistic) {
//        [self addLogWithStr:[log returnResultString] path:FILE_PATH_AT_DOC(statisticsPath) URL:StatisticsLogURL];
//    }else if(log.type == XYLogTypeCrash){
//        [self addLogWithStr:[log returnResultString] path:FILE_PATH_AT_DOC(crashPath) URL:CrashLogURL];
//    }
//}

-(void)addLogWithStr:(NSString *)str path:(NSString *)path URL:(NSString *)url upload:(BOOL)upload{
    __weak typeof(self) weakself = self;
    if (upload) {//立即上传
        NSLog(@"开始立即上传");
        [self postRequestByServiceUrl:url andParams:@{@"data":str} andCallBack:^(NSDictionary *obj) {
            if (obj) {
                NSNumber *code = obj[@"code"];
                if (code.integerValue == 1) {//上传成功 清除打点数据
                    NSLog(@"++++++++++++++++++++立即上传成功+++++");
                }else{
                    [weakself addLogWithStr:str path:path URL:url upload:NO];
                }
            }else{
                [weakself addLogWithStr:str path:path URL:url upload:NO];
            }
            
        }];
        return;
    }
    
    dispatch_async(dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT), ^{
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        //        [testobject sharedInstance].count ++;
        //        NSLog(@"***开始写入  %zd",[testobject sharedInstance].count);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isExists = [fileManager fileExistsAtPath:path];
        if (isExists) {
            NSData *data = [[NSString stringWithFormat:@"---***---%@",str] dataUsingEncoding:NSUTF8StringEncoding];
            BOOL isSucces = [self writeData:data path:path];
            if (!isSucces) {
                //文件打开失败 上传日志
                [self postRequestByServiceUrl:url andParams:@{@"data":str} andCallBack:nil];
            }
        }else{
            BOOL isSucces = [[NSString stringWithFormat:@"%@",str] writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
            if (!isSucces) {
                //如果写入失败 上传日志
                [self postRequestByServiceUrl:url andParams:@{@"data":str} andCallBack:nil];
            }
        }
        //        NSLog(@"***写入完成 %zd",[testobject sharedInstance].count);
        dispatch_semaphore_signal(self.semaphore);
    });
    
}

#pragma mark   -    上传打点

-(void)uploadLocalLogData{
    [self upLoadStatisticsLog];
    [self upLoadCrashLog];
}

-(void)upLoadStatisticsLog{
    [self upLoadStatisticsDataFromPath:FILE_PATH_AT_DOC(statisticsPath) url:kStatisticsLogURL];
}

-(void)upLoadCrashLog{
    [self upLoadStatisticsDataFromPath:FILE_PATH_AT_DOC(crashPath) url:kCrashLogURL];
}

-(void)upLoadStatisticsDataFromPath:(NSString *)path url:(NSString *)url{
    dispatch_async(dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT), ^{
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        //        [testobject sharedInstance].count ++;
        //        NSLog(@"***开始上传 %zd",[testobject sharedInstance].count);
        
        NSString *dataStr = [self readDataFormPath:path];
        
        if ([path isEqualToString:FILE_PATH_AT_DOC(statisticsPath)]) { //添加referrer
            //            NSString *newStr = [[XYLogDataHelper shareManager]handleReferrerWithString:dataStr];
            [self upLoadStatisticsDataFromPath:path url:url params:dataStr];
        }else {
            [self upLoadStatisticsDataFromPath:path url:url params:dataStr];
        }
        
    });
    
}

-(void)upLoadStatisticsDataFromPath:(NSString *)path url:(NSString *)url params:(NSString *)params{
    if (!params || [params isEqualToString:@""]) {
        //        NSLog(@"***上传完成 %zd",[testobject sharedInstance].count);
        dispatch_semaphore_signal(self.semaphore);
        return;
    }
    __weak typeof(self) weakself = self;
    [self postRequestByServiceUrl:url andParams:@{@"data":params} andCallBack:^(NSDictionary *obj) {
        if (obj) {
            NSNumber *code = obj[@"code"];
            if (code.integerValue == 1) {//上传成功 清除打点数据
                [weakself clearDataForPath:path];
#ifdef DEBUG
                //                [self showinfopath:path];
#endif
                NSLog(@"++++++++++++++++++++上传成功+++++");
            }
        }
        //        NSLog(@"***上传完成 %zd",[testobject sharedInstance].count);
        dispatch_semaphore_signal(self.semaphore);
    }];
}

- (void)postRequestByServiceUrl:(NSString *)service
                      andParams:(NSDictionary *)params
                    andCallBack:(void (^)(NSDictionary *obj))callback{
    NSLog(@"+++++++++++++++++++开始上传+++++");
    
    NSURL *url = [NSURL URLWithString:service];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString *body = [self dealWithParam:params];
    NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    if (!bodyData) {
        if (callback) {
            callback(nil);
        }
        return;
    }
    // 设置请求体
    [request setHTTPBody:bodyData];
    // 设置本次请求的提交数据格式
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    // 设置本次请求请求体的长度(因为服务器会根据你这个设定的长度去解析你的请求体中的参数内容)
    [request setValue:[NSString stringWithFormat:@"%ld",(unsigned long)bodyData.length] forHTTPHeaderField:@"Content-Length"];
    
    // 设置本次请求的最长时间
    request.timeoutInterval = 20;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@",[NSThread currentThread]);
        if (error) {
            if (callback) {
                callback(nil);
            }
            return;
        }
        if (!data) {
            if (callback) {
                callback(nil);
            }
            return;
        }else{
            NSString* responseString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            if (!responseString) {
                if (callback) {
                    callback(nil);
                }
                return;
            }
            NSData* dataString = [APLogTool stringToHexData:responseString];
            if (!dataString) {
                if (callback) {
                    callback(nil);
                }
                return;
            }
            // 解密需要时Base64的字符串
            NSString *base64Str_bf = [dataString base64EncodedStringWithOptions:0];
            // 使用秘钥进行解密,得到的是结果字符串
            NSString *resultStr_bf = [base64Str_bf blowFishDecodingWithKey:BlowFishKey];
            // 解密完成后转成Data以便之后进行序列化
            NSData *resultData_bf = [resultStr_bf dataUsingEncoding:NSUTF8StringEncoding];
            
            if (!resultData_bf) {
                if (callback) {
                    callback(nil);
                }
                return;
            }
            NSError* error_json;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:resultData_bf options:NSJSONReadingMutableContainers error:&error_json];
            if (dic && !error_json && callback) {
                callback(dic);
            }
        }
        
    }];
    [task resume];
}


#pragma mark - 数据加密

//字符串转十六进制
+ (NSData *)stringToHexData:(NSString *)hexStr{
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

//加密请求参数
-(NSString *)dealWithParam:(NSDictionary *)param{
    if (!param) {
        return @"";
    }
    NSMutableDictionary* mutableParam = [NSMutableDictionary dictionaryWithDictionary:param];
    NSArray *allkeys = [mutableParam allKeys];
    if (!allkeys.count) {
        return @"";
    }
    [self encryptAllValues:mutableParam];
    NSMutableString *result = [NSMutableString string];
    for (NSString *key in allkeys) {
        NSString *str;
        if (key == allkeys.lastObject) {
            str = [NSString stringWithFormat:@"%@=%@",key,mutableParam[key]];
        }else{
            str = [NSString stringWithFormat:@"%@=%@&",key,mutableParam[key]];
        }
        [result appendString:str];
    }
    return [result substringWithRange:NSMakeRange(0, result.length)];
}


- (void)encryptAllValues:(NSMutableDictionary *)param{
    if (!param.allKeys.count) {
        return;
    }
    for (NSString* key in param.allKeys) {
        NSString* value = [param objectForKey:key];
        NSString* a = [value stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        NSString *value_bf_base64 = [a blowFishEncodingWithKey:BlowFishKey];
        NSData *value_bf_data = [[NSData alloc] initWithBase64EncodedString:value_bf_base64 options:0];
        
        NSString* valueString_enc = [APLogTool hexStringFromData:value_bf_data];
        [param setObject:valueString_enc forKey:key];
    }
}

//十六进制转 字符串
+ (NSString *)hexStringFromData:(NSData *)myD{
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



//  test

//-(void)showinfopath:(NSString *)path{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@上传成功",path]];
//    });
//}

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

-(NSString *)convertToJsonData:(NSDictionary *)dict{
    if (!dict || !dict.allKeys.count) {
        return @"";
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *jsonString = @"";
    if (!jsonData) {
        return @"";
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

@end
