//
//  APTranstionAnimationPush.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APTranstionPushAnimation.h"
#import "APHomeVC.h"
#import "APSoundListVC.h"
#import "APCustomListVC.h"


@interface APTranstionPushAnimation ()<CAAnimationDelegate>
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;
@end

@implementation APTranstionPushAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    self.transitionContext = transitionContext;
    APHomeVC *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containView = [transitionContext containerView];
    [containView addSubview:fromVc.view];
    [containView addSubview:toVc.view];
    
    CGRect btnRect = fromVc.startFrame;
    UIBezierPath *startPath = [UIBezierPath bezierPathWithOvalInRect:btnRect];
    //按钮中心离屏幕最远的那个角的点
    CGPoint finalPoint;
    
    if(btnRect.origin.x > (toVc.view.bounds.size.width / 2)){
        finalPoint = CGPointMake(0, 0);
    }else{
        finalPoint = CGPointMake(CGRectGetMaxX(toVc.view.frame), 0);
    }
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(btnRect), CGRectGetMidY(btnRect));
    
    CGFloat radius = sqrt((finalPoint.x-startPoint.x) * (finalPoint.x-startPoint.x) + (finalPoint.y-startPoint.y) * (finalPoint.y-startPoint.y)) - sqrt(btnRect.size.width/2 * btnRect.size.width/2 + btnRect.size.height/2 * btnRect.size.height/2);
    UIBezierPath *endPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(btnRect, -radius, -radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = endPath.CGPath;
    toVc.view.layer.mask = maskLayer;
    
    CABasicAnimation *maskAnimation =[CABasicAnimation animationWithKeyPath:@"path"];
    maskAnimation.fromValue = (__bridge id)startPath.CGPath;
    maskAnimation.toValue = (__bridge id)endPath.CGPath;
    maskAnimation.duration = [self transitionDuration:transitionContext];
    maskAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    maskAnimation.delegate = self;
    [maskLayer addAnimation:maskAnimation forKey:@"path"];
}

#pragma mark -- CAAnimationDelegate --

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self.transitionContext completeTransition:YES];
    [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
    [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view.layer.mask = nil;
    
}

@end
