//
//  APLoadingHUD.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface APLoadingHUD : UIView

+ (void)show;

+ (void)dismiss;

+ (UIView *)CreateLoadingViewWithFrame:(CGRect)frame;
+ (UIView *)CreateTarotLoadingViewWithFrame:(CGRect)frame;

@end
