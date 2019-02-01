//
//  UIView+category.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UIView (category)

@property (nonatomic, assign) CGFloat xy_width;
@property (nonatomic, assign) CGFloat xy_height;
@property (nonatomic, assign) CGFloat xy_x;
@property (nonatomic, assign) CGFloat xy_y;
@property (nonatomic, assign) CGFloat xy_centerX;
@property (nonatomic, assign) CGFloat xy_centerY;

@property (nonatomic, assign) CGFloat xy_right;
@property (nonatomic, assign) CGFloat xy_bottom;

@property (nonatomic, assign) CGFloat right;

+ (CGFloat)getHeightByWidth:(CGFloat)width title:(NSString *_Nullable)title font:(UIFont*_Nullable)font;

+ (CGFloat)getWidthWithTitle:(NSString *_Nullable)title font:(UIFont *_Nullable)font;

+ (CGFloat)getHeightAttributeByWidth:(CGFloat)width attTitle:(NSAttributedString *_Nullable)attTitle font:(UIFont *_Nullable)font;

+ (instancetype _Nullable )viewFromXib;

- (UIImage *_Nullable)snapshotImage;

- (void)enlargedScaleToSize:(CGSize)size animations:(void (^_Nullable)(void))animations completion:(void (^ __nullable)(BOOL finished))completion;

/**
 开始旋转
 
 @param duration 旋转一周的时间
 */
- (void)startRotateWithDuration:(CGFloat)duration;

@end
