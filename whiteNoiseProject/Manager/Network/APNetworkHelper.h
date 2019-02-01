
#import <Foundation/Foundation.h>
#import <YGNetworkHelper/YGNetworkHelper.h>


typedef NS_ENUM(NSInteger, XTNetworkRequestType) {
    XTNetworkRequestTypeNone = -1,      // 无
    XTNetworkRequestTypeConfig = 0,     // 配置
    XTNetworkRequestTypeResource,       // 贴图,背景,文字等资源
    XTNetworkRequestTypeFeedBack,       // 用户反馈
    XTNetworkRequestTypeDeviceToken,    // deviceToken
    XTNetworkRequestTypeClasses,        // 主界面的目录信息
    XTNetworkRequestTypeCustom          // 自定义音效数据
};

@interface APNetworkHelper : NSObject


/**
 POST 请求
 
 @param requestType     请求类型
 @param parameters      参数
 @param responseBlock   成功回调
 @param errorBlock      失败回调
 */
+ (void)xt_postRequestWithType:(XTNetworkRequestType)requestType parameters:(NSDictionary *)parameters response:(void (^)(NSDictionary *dict))responseBlock error:(void (^)(NSError *error))errorBlock;

@end
