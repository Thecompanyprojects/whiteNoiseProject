//
//  UIImage+Color.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)

/**
 纯色图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color;


/**
 指定尺寸的纯色图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;


/**
 改变图片的透明度
 */
- (UIImage *)changeImageAlpha:(CGFloat)alpha;



- (UIImage *)imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode;


//使用颜色叠加（彩色图片）
@property (nonatomic,assign) BOOL blendMode;
- (UIImage *)imageWithTintColor:(UIColor*)color;

@end
