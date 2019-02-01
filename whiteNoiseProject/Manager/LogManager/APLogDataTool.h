
#import <Foundation/Foundation.h>

@interface APLogDataTool : NSObject

+ (instancetype)shareManager;
- (NSString *)handleDataKey1:(NSString *)key1 key2:(NSString *)key2 content:(NSDictionary *)content userInfo:(NSDictionary *)userInfo;
- (NSString *)handleCrashDataDic:(NSDictionary *)dic;
- (NSString *)handleReferrerWithString:(NSString *)string;
- (void)appendReferrer:(NSString *)referrer;
- (NSString *)readReferrer;

@end
