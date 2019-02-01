//
//  APTranstionAnimationPop.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APTranstionPopAnimation.h"
#import "APHomeVC.h"

@interface APTranstionPopAnimation () <CAAnimationDelegate>
@property (nonatomic, strong)id<UIViewControllerContextTransitioning> transitionContext;
@end

@implementation APTranstionPopAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    self.transitionContext = transitionContext;
    
    UIViewController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    APHomeVC *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containView = [transitionContext containerView];
    [containView addSubview:toVc.view];
    [containView addSubview:fromVc.view];
    
    CGRect btnRect = toVc.startFrame;
    UIBezierPath *endPath = [UIBezierPath bezierPathWithOvalInRect:btnRect];
    
    ///按钮中心离屏幕最远的那个角的点
    CGPoint startPoint;
    if(btnRect.origin.x > (toVc.view.bounds.size.width / 2)){
        startPoint = CGPointMake(0, 0);
    }else{
        startPoint = CGPointMake(CGRectGetMaxX(toVc.view.frame), 0);
    }
    
    CGPoint endPoint = CGPointMake(CGRectGetMidX(btnRect), CGRectGetMidY(btnRect));
    CGFloat radius = sqrt((endPoint.x-startPoint.x) * (endPoint.x-startPoint.x) + (endPoint.y-startPoint.y) * (endPoint.y-startPoint.y)) - sqrt((btnRect.size.width/2 * btnRect.size.width/2) + (btnRect.size.height/2 * btnRect.size.height/2));
    
    UIBezierPath *startPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(btnRect, -radius, -radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = endPath.CGPath;
    fromVc.view.layer.mask = maskLayer;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.fromValue = (__bridge id)startPath.CGPath;
    animation.toValue = (__bridge id)endPath.CGPath;
    animation.duration = [self transitionDuration:transitionContext];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.delegate = self;
    [maskLayer addAnimation:animation forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self.transitionContext completeTransition:YES];
    [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
    [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view.layer.mask = nil;
    
}


@end
