//
//  UIView+category.m
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//
//

#import "UIView+category.h"

@implementation UIView (category)

- (CGFloat)xy_width {
    return self.frame.size.width;
}

- (CGFloat)xy_height {
    return self.frame.size.height;
}

- (void)setXy_width:(CGFloat)xy_width {
    CGRect frame = self.frame;
    frame.size.width = xy_width;
    self.frame = frame;
}

- (void)setXy_height:(CGFloat)xy_height {
    CGRect frame = self.frame;
    frame.size.height = xy_height;
    self.frame = frame;
}

- (CGFloat)xy_x {
    return self.frame.origin.x;
}

- (CGFloat)xy_y {
    return self.frame.origin.y;
}

- (void)setXy_x:(CGFloat)xy_x {
    CGRect frame = self.frame;
    frame.origin.x = xy_x;
    self.frame = frame;
}

- (void)setXy_y:(CGFloat)xy_y {
    CGRect frame = self.frame;
    frame.origin.y = xy_y;
    self.frame = frame;
}

- (CGFloat)xy_centerX {
    return self.center.x;
}

- (CGFloat)xy_centerY {
    return self.center.y;
}

- (void)setXy_centerX:(CGFloat)xy_centerX {
    CGPoint center = self.center;
    center.x = xy_centerX;
    self.center = center;
}

- (void)setXy_centerY:(CGFloat)xy_centerY {
    CGPoint center = self.center;
    center.y = xy_centerY;
    self.center = center;
}

- (CGFloat)xy_right {
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)xy_bottom {
    return CGRectGetMaxY(self.frame);
}

- (void)setXy_right:(CGFloat)xj_right {
    self.xy_x = xj_right - self.xy_width;
}

- (void)setXy_bottom:(CGFloat)xj_bottom {
    self.xy_y = xj_bottom - self.xy_height;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

+ (CGFloat)getHeightByWidth:(CGFloat)width title:(NSString *)title font:(UIFont *)font{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    label.text = title;
    label.font = font;
    label.numberOfLines = 0;
    [label sizeToFit];
    CGFloat height = label.frame.size.height;
    return height;
}

+ (CGFloat)getWidthWithTitle:(NSString *)title font:(UIFont *)font {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 0)];
    label.text = title;
    label.font = font;
    [label sizeToFit];
    return label.frame.size.width;
}

+ (CGFloat)getHeightAttributeByWidth:(CGFloat)width attTitle:(NSAttributedString *)attTitle font:(UIFont *)font{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    label.attributedText = attTitle;
    label.font = font;
    label.numberOfLines = 0;
    [label sizeToFit];
    CGFloat height = label.frame.size.height;
    return height;
}

+ (instancetype)viewFromXib {
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
}

- (UIImage *)snapshotImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size,NO, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (void)enlargedScaleToSize:(CGSize)size animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion{
    CGRect rect = self.frame;
    rect.origin.y -= ((size.height - self.frame.size.height)*0.5);
    rect.origin.x -= ((size.width - self.frame.size.width)*0.5);
    rect.size.width = size.width;
    rect.size.height = size.height;
    [UIView animateWithDuration:0.25
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.frame = rect;
                         if (animations) {
                             animations();
                         }
                     }
                     completion:completion];
}

- (void)startRotateWithDuration:(CGFloat)duration{
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI*2.0];
    rotationAnimation.duration = duration;
    rotationAnimation.repeatCount = HUGE_VALF;
    [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

@end
