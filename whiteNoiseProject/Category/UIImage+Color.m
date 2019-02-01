//
//  UIImage+Color.m
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//
#import "UIImage+Color.h"
#import <objc/runtime.h>

@implementation UIImage (Color)
+ (UIImage*) imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1.0f, 1.0f)];
}

+ (UIImage*)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //    NSData* imageData = UIImageJPEGRepresentation(image, 1.0f);
    //    image = [UIImage imageWithData:imageData];
    return image;
}


- (UIImage *)changeImageAlpha:(CGFloat)alpha {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, self.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}



- (UIImage *)imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    //设置绘画透明混合模式和透明度
    [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
    if (blendMode == kCGBlendModeOverlay) {
        //保留透明度信息
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    }
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tintedImage;
}

- (void)setBlendMode:(BOOL)blendMode {
    objc_setAssociatedObject(self, @selector(blendMode), @(blendMode), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)blendMode {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (UIImage *)imageWithTintColor:(UIColor*)color {
    if (!color) {
        return self;
    }
    if (self.blendMode) {
        CGBlendMode blendMode = kCGBlendModeOverlay;
        UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
        [color setFill];
        CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
        UIRectFill(bounds);
        [self drawInRect:bounds blendMode:blendMode alpha:1.0f];
        
        if (blendMode != kCGBlendModeDestinationIn)
            [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0];
        
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }else{
        UIImage *newImage = [self imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIGraphicsBeginImageContextWithOptions(self.size, NO, newImage.scale);
        [color set];
        [newImage drawInRect:CGRectMake(0, 0, self.size.width, newImage.size.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
}

@end
