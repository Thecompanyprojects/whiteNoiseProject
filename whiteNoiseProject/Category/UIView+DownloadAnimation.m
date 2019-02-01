//
//  UIView+DownloadAnimation.m
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//


#import "UIView+DownloadAnimation.h"
#import <objc/runtime.h>

const char kBgLayer;
const char kAnimationLayer;

@interface UIView () <CAAnimationDelegate>
@property (nonatomic, strong) CAShapeLayer *bgLayer;
@property (nonatomic, strong) CAShapeLayer *animationLayer;
@end
@implementation UIView (DownloadAnimation)

- (void)addDownloadlayer {
    [self addBgLayer];
    [self addAnimationLayer];
}

- (void)setDownloadProgress:(CGFloat)progress {
    if (progress < 0.0 || progress > 1) {
        return;
    }
    
    if (!self.bgLayer && !self.animationLayer) {
        return;
    }
    
    [self.animationLayer setAffineTransform:CGAffineTransformScale(CGAffineTransformIdentity, progress, progress)];
}

- (void)downloadFinished {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    scaleAnimation.fromValue = @1.0;
    scaleAnimation.toValue = @1.1;
    scaleAnimation.duration = 0.2f;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.removedOnCompletion = NO;
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    alphaAnimation.fromValue = @1.0;
    alphaAnimation.toValue = @0;
    alphaAnimation.duration = 0.2f;
    alphaAnimation.fillMode = kCAFillModeForwards;
    alphaAnimation.removedOnCompletion = NO;
    
    CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc] init];
    animationGroup.duration = 0.2;
    animationGroup.removedOnCompletion = NO;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animationGroup.autoreverses = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.animations = @[scaleAnimation, alphaAnimation];
    
    [self.animationLayer addAnimation:animationGroup forKey:@"kGroupAnimation"];
    [self.bgLayer addAnimation:alphaAnimation forKey:@"kBgAlphaAnimation"];
}

- (void)removeDownloadlayer {
    [self.bgLayer removeAllAnimations];
    [self.animationLayer removeAllAnimations];
    [self.bgLayer removeFromSuperlayer];
    [self.animationLayer removeFromSuperlayer];
    self.bgLayer = nil;
    self.animationLayer = nil;
}

- (void)addBgLayer {
    if (self.bgLayer) {
        return;
    }
    
    CGFloat width = MIN(self.bounds.size.width, self.bounds.size.height);
    
    CAShapeLayer *bglayer = [[CAShapeLayer alloc] init];
    self.bgLayer = bglayer;
    bglayer.backgroundColor = [kHexColor(0xFA6BEA) colorWithAlphaComponent:0.4].CGColor;
    bglayer.bounds = CGRectMake(0, 0, width, width);
    bglayer.cornerRadius = width / 2.0;
    bglayer.position = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
    [self.layer addSublayer:bglayer];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    scaleAnimation.fromValue = @0;
    scaleAnimation.toValue = @1;
    scaleAnimation.duration = 0.2f;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.removedOnCompletion = NO;
    [bglayer addAnimation:scaleAnimation forKey:@"scale"];
}

- (void)addAnimationLayer {
    if (self.animationLayer) {
        return;
    }
    
    CGFloat width = MIN(self.bounds.size.width, self.bounds.size.height);
    
    CAShapeLayer *animationLayer = [[CAShapeLayer alloc] init];
    self.animationLayer = animationLayer;
    animationLayer.backgroundColor = [kHexColor(0xA269FE) colorWithAlphaComponent:1].CGColor;
    animationLayer.bounds = CGRectMake(0, 0, width, width);
    animationLayer.cornerRadius = width / 2.0;
    animationLayer.position = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
    [self.layer addSublayer:animationLayer];
}



#pragma mark - CAAnimationDelegate
// 开始动画
- (void)animationDidStart:(CAAnimation *)anim {
    NSLog(@"进度动画开始");
}

// 移除动画或者动画结束
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSLog(@"进度动画结束");
    [self removeDownloadlayer];
}



#pragma mark - set / get
- (void)setBgLayer:(CAShapeLayer *)bgLayer {
    objc_setAssociatedObject(self, &kBgLayer, bgLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CAShapeLayer *)bgLayer {
    return objc_getAssociatedObject(self, &kBgLayer);
}

- (void)setAnimationLayer:(CAShapeLayer *)animationLayer {
    objc_setAssociatedObject(self, &kAnimationLayer, animationLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CAShapeLayer *)animationLayer {
    return objc_getAssociatedObject(self, &kAnimationLayer);
}

@end

