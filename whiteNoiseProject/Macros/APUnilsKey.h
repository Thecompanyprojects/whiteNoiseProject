//
//  APUnilsKey.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#ifndef APUnilsKey_h
#define APUnilsKey_h

//appDelegate
#define kApplication            [UIApplication sharedApplication]
#define kAppDelegate            [UIApplication sharedApplication].delegate
#define kKeyWindow              [UIApplication sharedApplication].delegate.window
#define kUserDefaults           [NSUserDefaults standardUserDefaults]
#define kNotificationCenter     [NSNotificationCenter defaultCenter]

//获取屏幕宽高
#define KScreenWidth            [[UIScreen mainScreen] bounds].size.width
#define KScreenHeight           [[UIScreen mainScreen] bounds].size.height
#define kScreenBounds           [UIScreen mainScreen].bounds
#define kNavBarHeight           (isIPhoneX?88.0:64.0)
#define kTabBarHeight           (isIPhoneX?83.0:49.0)


//6s比例
#define KWIDTH                  [UIScreen mainScreen].bounds.size.width/375.0
#define KHEIGHT                 [UIScreen mainScreen].bounds.size.height/667.0

#define IS_IPAD                 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE               (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define WINDOW_MAX_LENGTH       (MAX(KScreenWidth, KScreenHeight))
#define IS_IPHONE_4             (IS_IPHONE && WINDOW_MAX_LENGTH < 568.0)
#define IS_IPHONE_5             (IS_IPHONE && WINDOW_MAX_LENGTH == 568.0)
#define IS_IPHONE_6             (IS_IPHONE && WINDOW_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P            (IS_IPHONE && WINDOW_MAX_LENGTH == 736.0)


//判断iPHoneXR
#define isIPhoneXR      ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)

//判断iPHoneX、iPHoneXs
#define isIPhoneX_XS      ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

//判断iPhoneXs Max
#define isIPhoneXSMAX   ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)

//判断iPhoneX系列
#define isIPhoneX       (isIPhoneX_XS || isIPhoneXR || isIPhoneXSMAX)// X全系列


//ios 系统
#define isIOS9                  ([[UIDevice currentDevice].systemVersion intValue]>=9?YES:NO)
#define isIOS10                 ([[UIDevice currentDevice].systemVersion intValue]==10?YES:NO)
#define isIOS11                 ([[UIDevice currentDevice].systemVersion intValue]==11?YES:NO)

//获取view的frame某值
#define ViewWidth(v)            v.frame.size.width
#define ViewHeight(v)           v.frame.size.height
#define ViewX(v)                v.frame.origin.x
#define ViewY(v)                v.frame.origin.y
#define MakeHeightTo(v, h)     { CGRect f = v.frame; f.size.height = h; v.frame = f; }
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

/** 颜色 */
#define kRGBAColor(r,g,b,a)    \
[UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define kRGBColor(r,g,b)  \
[UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.f]

#define kRandomColor \
[UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0]

/**
 rgb颜色转换（16进制->10进制）
 示例:
 kHexColor(0xffffff)
 */
#define kHexColor(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s %s:%d\t%s\n",__TIME__,[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif



/**
 对象的强引用若引用,在Block中使用.
 
 Example:
 @weakify(self)
 [self doSomething^{
 @strongify(self)
 if (!self) return;
 ...
 }];
 
 */
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif


#endif /* APUnilsKey_h */
