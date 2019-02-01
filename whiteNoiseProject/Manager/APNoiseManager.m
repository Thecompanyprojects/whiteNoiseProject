
#import "APNoiseManager.h"
#import "APNetworkHelper.h"
#import <whiteNoiseProject-Swift.h>
@interface APNoiseManager ()

@property (nonatomic, strong) MSWeakTimer         *timer;
@property (nonatomic, copy)   TimeCallBack        timeBlock;
@property (nonatomic, copy)   NSString            *dateStr;
@property (nonatomic, copy)   NSString            *amStr;

@property (nonatomic, copy)   NSString            *sleepBgImgUrl;


@end

@implementation APNoiseManager

+ (instancetype)shareInstance{
    static APNoiseManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[APNoiseManager alloc]init];
    });
    return _instance;
}

- (void)createtimerCallBack:(TimeCallBack)callBack{
    self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(observerSystemTime) userInfo:nil repeats:YES dispatchQueue:dispatch_queue_create("systemTime", DISPATCH_QUEUE_CONCURRENT)];
    self.timeBlock = callBack;
}


- (void)observerSystemTime{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *PMFormatter = [[NSDateFormatter alloc] init];
    [PMFormatter setDateFormat:@"a"];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *amStr = [PMFormatter stringFromDate:[NSDate date]];
    if (self.timeBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.timeBlock(currentDateStr, amStr);
        });
    }
}

- (void)requstConfigData {
    __weak typeof(self) weakself = self;
    /*
    {
     code = 1;
     data =    {
     ad =        {
     };
     switch =        {
     ad = 1;
     background =            {
     home = "http://seopic.699pic.com/photo/50035/0520.jpg_wh1200.jpg";
     museList = "http://www.rantapallo.fi/merjanmatkassa/files/2018/04/kalifornia_pixabay1.jpg";
     mwsePlayer = "http://static.obeobe.com/image/blog-image/hen-shi-he-fang-zai-ghost-blog-de-da-tu-pian-3.jpg";
     sleepList = "http://seopic.699pic.com/photo/50031/2015.jpg_wh1200.jpg";
     sleepPlayer = "http://i0.sinaimg.cn/travel/2015/0415/U9385P704DT20150415165004.jpg";
     };
     };
     value =        {
     };
     vip =        {
     };
     };
     timestamp = 1534409046110;
     }
     */
    [APNetworkHelper xt_postRequestWithType:XTNetworkRequestTypeConfig parameters:nil response:^(NSDictionary *dict) {
        NSNumber *code = dict[@"code"];
        if (code.integerValue == 1) {
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary changeType:dict] forKey:kDefaultConfigKey];
            
            NSDictionary *data = dict[@"data"];
            NSDictionary *switchDic = data[@"cloud"];
            NSDictionary *backgroundDic = switchDic[@"background"];
            NSString *homeBgImgUrl = backgroundDic[@"home"];
            NSString *musePlayerUrl = backgroundDic[@"musePlayer"];
            NSArray *themeImageArr = backgroundDic[@"themeImageArr"];
            
            [[ThemeImageManager shared] saveServerConfigWithImageUrls:themeImageArr];
            
            
            if (homeBgImgUrl && [homeBgImgUrl isKindOfClass:[NSString class]]) {
                [weakself loadImageWithUrlStr:homeBgImgUrl key:@"homeBackGround" normalImg:@"首页背景图-1"];
            }
            
            if (musePlayerUrl && [musePlayerUrl isKindOfClass:[NSString class]]) {
                [weakself loadImageWithUrlStr:musePlayerUrl key:@"musePlayerBackGround" normalImg:@"首页背景图模糊"];
            }
        }else{
            
        }
    } error:^(NSError *error) {
        
    }];
    
}

- (void)loadImageWithUrlStr:(NSString *)urlStr key:(NSString *)key normalImg:(NSString *)normalImg{
    
    [[SDWebImageManager sharedManager]loadImageWithURL:[NSURL URLWithString:urlStr] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        NSLog(@"---------%@",[NSThread currentThread]);
        if (finished && image) {
            [[SDImageCache sharedImageCache]storeImage:image forKey:key completion:^{
                
            }];
        }
        if (error) {
            [[SDImageCache sharedImageCache]storeImage:[UIImage imageNamed:normalImg] forKey:key completion:^{
                
            }];
        }
    }];
}

- (UIImage *)homeBgImg{
    UIImage *image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:@"homeBackGround"];
    if (image) {
        return image;
    }else{
        return [UIImage imageNamed:@"首页背景图-1"];
    }
}

- (UIImage *)museBgImg{
    UIImage *image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:@"musePlayerBackGround"];
    if (image) {
        return image;
    }else{
        return [UIImage imageNamed:@"首页背景图模糊"];
    }
}

- (NSArray *)littleAudios{
    if (!_littleAudios) {
        _littleAudios = @[@"静夜",@"雷",@"小雨",@"海豚",@"蝉",@"鸟鸣",@"脚步",@"风铃",@"水滴"];
    }
    return _littleAudios;
}

@end
