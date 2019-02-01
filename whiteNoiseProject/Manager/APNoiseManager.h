
#import <Foundation/Foundation.h>

typedef void(^TimeCallBack)(NSString *timeStr,NSString *amStr);

@interface APNoiseManager : NSObject

@property (nonatomic, copy)   NSArray             *littleAudios;
@property (nonatomic, strong) UIImage             *homeBgImg;
@property (nonatomic, strong) UIImage             *museBgImg;
@property (nonatomic, copy)   NSString            *deepLinkPush;
@property (nonatomic, assign) BOOL                isFromTabbar;

+ (instancetype)shareInstance;
- (void)createtimerCallBack:(TimeCallBack)callBack;
- (void)requstConfigData;

@end
