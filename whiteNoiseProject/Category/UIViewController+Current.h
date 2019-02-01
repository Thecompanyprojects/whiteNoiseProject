//
//  UIViewController+Current.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIViewController (Current)

//找到当前视图控制器
+ (UIViewController *)currentViewController;

//找到当前导航控制器
+ (UINavigationController *)currentNavigatonController;

@end
