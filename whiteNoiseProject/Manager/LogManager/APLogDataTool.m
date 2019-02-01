
#import "APLogDataTool.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <FCUUID/FCUUID.h>
#import <sys/utsname.h>

@interface APLogDataTool ()

@property (nonatomic, copy) NSString *country_code;
@property (nonatomic, copy) NSString *build;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *systemVersion;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *iphoneType;
@property (nonatomic, copy) NSString *referrer;

@end

@implementation APLogDataTool

+ (instancetype)shareManager{
    static APLogDataTool *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[APLogDataTool alloc]init];
    });
    return _instance;
}


- (NSString *)handleDataKey1:(NSString *)key1 key2:(NSString *)key2 content:(NSDictionary *)content userInfo:(NSDictionary *)userInfo{
    NSString *key1Str = key1 ? key1 : @"";
    NSString *key2Str = key2 ? key2 : @"";
    NSDictionary *contentDic = content ? content : @{};
    NSDictionary *userInfoDic = userInfo ? userInfo : @{};
    
    NSMutableDictionary* resDict = [NSMutableDictionary dictionary];
    [resDict setObject:key1Str forKey:@"key1"];
    [resDict setObject:key2Str forKey:@"key2"];
    if (contentDic && contentDic.allKeys.count) {
        [resDict setObject:contentDic forKey:@"content"];
    }
    if (!userInfoDic) {
        userInfoDic = [NSDictionary dictionary];
    }
    NSMutableDictionary* mutableDict = [NSMutableDictionary dictionaryWithDictionary:userInfoDic];
    
    NSString *countryCode = self.country_code;
    [mutableDict setObject:countryCode?countryCode:@"" forKey:@"country_code"];
    if (self.referrer) {
        [mutableDict setObject:self.referrer forKey:@"referrer"];
    }
    [resDict setObject:mutableDict forKey:@"user"];
    [self addInfoToDict:resDict];
    
    return [self convertToJsonData:resDict];
}

- (NSString *)handleCrashDataDic:(NSDictionary *)dic{
    NSMutableDictionary* resDict = [NSMutableDictionary dictionary];
    [self addInfoToDict:resDict];
    NSString* crashString = [self convertToJsonData:dic];
    [resDict setObject:crashString forKey:@"crash"];
    return [self convertToJsonData:resDict];
}

- (void)appendReferrer:(NSString *)referrer{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:referrer forKey:@"log_referrer"];
    self.referrer = referrer;
}

- (NSString *)readReferrer{
    return self.referrer;
}

- (void)addInfoToDict:(NSMutableDictionary *)dict{
    
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    [dict setObject:@(recordTime) forKey:@"time"];
    NSNumber* network = [self networkStatus:[AFNetworkReachabilityManager sharedManager].networkReachabilityStatus];
    [dict setObject:network forKey:@"network"];
    
    NSString* build = self.build;
    NSString* version = self.version;
    
    [dict setObject:build?build:@"" forKey:@"app_version_code"];
    [dict setObject:version?version:@"" forKey:@"app_version_name"];
    
    NSDictionary* deviceInfo = [NSMutableDictionary dictionary];
    NSString *systemVersion = self.systemVersion;
    NSString* uuid = self.uuid;
    [deviceInfo setValue:systemVersion forKey:@"version"];
    [deviceInfo setValue:uuid forKey:@"mid"];
    NSString* model = self.iphoneType;
    [deviceInfo setValue:model forKey:@"model"];
    [deviceInfo setValue:@"appstore" forKey:@"channel"];
    
    NSString * preferredLang = self.language;
    [deviceInfo setValue:preferredLang?preferredLang:@"" forKey:@"language"];
    
    NSString *countryCode = self.country_code;
    [deviceInfo setValue:countryCode?countryCode:@"" forKey:@"country"];
    [dict setObject:deviceInfo forKey:@"basic"];
}

- (NSString *)handleReferrerWithString:(NSString *)string{
    if (!string || [string isEqualToString:@""]) {
        return nil;
    }
    NSArray *dataArr = [string componentsSeparatedByString:@"---***---"];
    NSString *newStr = nil;
    for (int i=0; i<dataArr.count; i++) {
        NSString *str = dataArr[i];
        if ([str isEqualToString:@""]) {
            continue;
        }
        NSDictionary *dic = [self dictionaryWithJsonString:str];
        NSMutableDictionary *allDic = [[NSMutableDictionary alloc]initWithDictionary:dic];
        NSMutableDictionary *userDic = [[NSMutableDictionary alloc]initWithDictionary: dic[@"user"]];
        NSString *referrerStr = self.referrer;
        if (referrerStr) {
            [userDic setObject:referrerStr forKey:@"referrer"];
        }
        //            NSLog(@"%@",dic);
        [allDic setObject:userDic.copy forKey:@"user"];
        NSString *resultStr = [self convertToJsonData:allDic];
        
        if (i==0) {
            newStr = resultStr;
        }else{
            newStr = [NSString stringWithFormat:@"%@---***---%@",newStr,resultStr];
        }
    }
    return newStr;
}

//字典转字符串
- (NSString *)convertToJsonData:(NSDictionary *)dict{
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

//字符串转字典
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

- (NSNumber *)networkStatus:(AFNetworkReachabilityStatus)status{
    switch (status) {
        case AFNetworkReachabilityStatusUnknown:
            return @(4096);
            NSLog(@"未知");
            break;
        case AFNetworkReachabilityStatusNotReachable:
            return @(4102);
            NSLog(@"没有网络");
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            return @(4101);
            NSLog(@"3G");
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            return @(4097);
            NSLog(@"WIFI");
            break;
            
        default:
            return @(4096);
            break;
    }
}

- (NSString *) md5String:(NSString *)string{
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

- (NSString *)country_code{
    if (_country_code) {
        return _country_code;
    }else{
        dispatch_async(dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT), ^{
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
            CTCarrier *carrier = info.subscriberCellularProvider;
            NSString *countryCode = [carrier isoCountryCode];
            self->_country_code = countryCode;
        });
        return @"";
    }
}


- (NSString *)build{
    if (!_build) {
        _build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    }
    return _build;
}

- (NSString *)version{
    if (!_version) {
        _version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    }
    return _version;
}

- (NSString *)systemVersion{
    if (!_systemVersion) {
        _systemVersion = [UIDevice currentDevice].systemVersion;
    }
    return _systemVersion;
}

- (NSString *)uuid{
    if (!_uuid) {
        _uuid = [FCUUID uuidForDevice];
    }
    return _uuid;
}

- (NSString *)language{
    if (!_language) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
        NSString * preferredLang = [allLanguages objectAtIndex:0];
        _language = preferredLang;
    }
    return _language;
}

- (NSString *)referrer{
    if (!_referrer) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString *str = [defaults objectForKey:@"log_referrer"];
        //        if (!str || !str.length) {
        //            str =
        //        }
        _referrer = str;
    }
    return _referrer;
}

- (NSString *)iphoneType{
    if (!_iphoneType) {
        NSString *iphoneStr = nil;
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
        if([platform isEqualToString:@"iPhone1,1"])  iphoneStr = @"iPhone 2G";
        if([platform isEqualToString:@"iPhone1,2"])  iphoneStr = @"iPhone 3G";
        if([platform isEqualToString:@"iPhone2,1"])  iphoneStr = @"iPhone 3GS";
        if([platform isEqualToString:@"iPhone3,1"])  iphoneStr = @"iPhone 4";
        if([platform isEqualToString:@"iPhone3,2"])  iphoneStr = @"iPhone 4";
        if([platform isEqualToString:@"iPhone3,3"])  iphoneStr = @"iPhone 4";
        if([platform isEqualToString:@"iPhone4,1"])  iphoneStr = @"iPhone 4S";
        if([platform isEqualToString:@"iPhone5,1"])  iphoneStr = @"iPhone 5";
        if([platform isEqualToString:@"iPhone5,2"])  iphoneStr = @"iPhone 5";
        if([platform isEqualToString:@"iPhone5,3"])  iphoneStr = @"iPhone 5c";
        if([platform isEqualToString:@"iPhone5,4"])  iphoneStr = @"iPhone 5c";
        if([platform isEqualToString:@"iPhone6,1"])  iphoneStr = @"iPhone 5s";
        if([platform isEqualToString:@"iPhone6,2"])  iphoneStr = @"iPhone 5s";
        if([platform isEqualToString:@"iPhone7,1"])  iphoneStr = @"iPhone 6 Plus";
        if([platform isEqualToString:@"iPhone7,2"])  iphoneStr = @"iPhone 6";
        if([platform isEqualToString:@"iPhone8,1"])  iphoneStr = @"iPhone 6s";
        if([platform isEqualToString:@"iPhone8,2"])  iphoneStr = @"iPhone 6s Plus";
        if([platform isEqualToString:@"iPhone8,4"])  iphoneStr = @"iPhone SE";
        if([platform isEqualToString:@"iPhone9,1"])  iphoneStr = @"iPhone 7";
        if([platform isEqualToString:@"iPhone9,3"])  iphoneStr = @"iPhone 7";
        if([platform isEqualToString:@"iPhone9,2"])  iphoneStr = @"iPhone 7 Plus";
        if([platform isEqualToString:@"iPhone9,4"])  iphoneStr = @"iPhone 7 Plus";
        if([platform isEqualToString:@"iPhone10,1"]) iphoneStr = @"iPhone 8";
        if([platform isEqualToString:@"iPhone10,4"]) iphoneStr = @"iPhone 8";
        if([platform isEqualToString:@"iPhone10,2"]) iphoneStr = @"iPhone 8 Plus";
        if([platform isEqualToString:@"iPhone10,5"]) iphoneStr = @"iPhone 8 Plus";
        if([platform isEqualToString:@"iPhone10,3"]) iphoneStr = @"iPhone X";
        if([platform isEqualToString:@"iPhone10,6"]) iphoneStr = @"iPhone X";
        
        if([platform isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
        if([platform isEqualToString:@"iPhone11,4"]) return @"iPhone XS Max";
        if([platform isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
        if([platform isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
        
        if([platform isEqualToString:@"iPod1,1"])  iphoneStr = @"iPod Touch 1G";
        if([platform isEqualToString:@"iPod2,1"])  iphoneStr = @"iPod Touch 2G";
        if([platform isEqualToString:@"iPod3,1"])  iphoneStr = @"iPod Touch 3G";
        if([platform isEqualToString:@"iPod4,1"])  iphoneStr = @"iPod Touch 4G";
        if([platform isEqualToString:@"iPod5,1"])  iphoneStr = @"iPod Touch 5G";
        if([platform isEqualToString:@"iPad1,1"])  iphoneStr = @"iPad 1G";
        if([platform isEqualToString:@"iPad2,1"])  iphoneStr = @"iPad 2";
        if([platform isEqualToString:@"iPad2,2"])  iphoneStr = @"iPad 2";
        if([platform isEqualToString:@"iPad2,3"])  iphoneStr = @"iPad 2";
        if([platform isEqualToString:@"iPad2,4"])  iphoneStr = @"iPad 2";
        if([platform isEqualToString:@"iPad2,5"])  iphoneStr = @"iPad Mini 1G";
        if([platform isEqualToString:@"iPad2,6"])  iphoneStr = @"iPad Mini 1G";
        if([platform isEqualToString:@"iPad2,7"])  iphoneStr = @"iPad Mini 1G";
        if([platform isEqualToString:@"iPad3,1"])  iphoneStr = @"iPad 3";
        if([platform isEqualToString:@"iPad3,2"])  iphoneStr = @"iPad 3";
        if([platform isEqualToString:@"iPad3,3"])  iphoneStr = @"iPad 3";
        if([platform isEqualToString:@"iPad3,4"])  iphoneStr = @"iPad 4";
        if([platform isEqualToString:@"iPad3,5"])  iphoneStr = @"iPad 4";
        if([platform isEqualToString:@"iPad3,6"])  iphoneStr = @"iPad 4";
        if([platform isEqualToString:@"iPad4,1"])  iphoneStr = @"iPad Air";
        if([platform isEqualToString:@"iPad4,2"])  iphoneStr = @"iPad Air";
        if([platform isEqualToString:@"iPad4,3"])  iphoneStr = @"iPad Air";
        if([platform isEqualToString:@"iPad4,4"])  iphoneStr = @"iPad Mini 2G";
        if([platform isEqualToString:@"iPad4,5"])  iphoneStr = @"iPad Mini 2G";
        if([platform isEqualToString:@"iPad4,6"])  iphoneStr = @"iPad Mini 2G";
        if([platform isEqualToString:@"iPad4,7"])  iphoneStr = @"iPad Mini 3";
        if([platform isEqualToString:@"iPad4,8"])  iphoneStr = @"iPad Mini 3";
        if([platform isEqualToString:@"iPad4,9"])  iphoneStr = @"iPad Mini 3";
        if([platform isEqualToString:@"iPad5,1"])  iphoneStr = @"iPad Mini 4";
        if([platform isEqualToString:@"iPad5,2"])  iphoneStr = @"iPad Mini 4";
        if([platform isEqualToString:@"iPad5,3"])  iphoneStr = @"iPad Air 2";
        if([platform isEqualToString:@"iPad5,4"])  iphoneStr = @"iPad Air 2";
        if([platform isEqualToString:@"iPad6,3"])  iphoneStr = @"iPad Pro 9.7";
        if([platform isEqualToString:@"iPad6,4"])  iphoneStr = @"iPad Pro 9.7";
        if([platform isEqualToString:@"iPad6,7"])  iphoneStr = @"iPad Pro 12.9";
        if([platform isEqualToString:@"iPad6,8"])  iphoneStr = @"iPad Pro 12.9";
        if([platform isEqualToString:@"i386"])  iphoneStr = @"iPhone Simulator";
        if([platform isEqualToString:@"x86_64"])   iphoneStr = @"iPhone Simulator";
        if (!iphoneStr) {
            iphoneStr = @"none";
        }
        _iphoneType = iphoneStr;
    }
    return _iphoneType;
}

@end
