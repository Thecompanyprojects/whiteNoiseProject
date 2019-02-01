//
//  UIViewController+Current.m
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//
#import "UIViewController+Current.h"

@implementation UIViewController (Current)

+ (UIViewController *)currentViewController {
    UIViewController *viewController = [[UIApplication sharedApplication].delegate window].rootViewController;
    return [UIViewController findBestViewController:viewController];
}

+ (UINavigationController *)currentNavigatonController {
    UIViewController *currentViewController = [UIViewController currentViewController];
    return currentViewController.navigationController;
}

+ (UIViewController *)findBestViewController:(UIViewController *)vc {
    if (vc.presentedViewController) {
        return [self findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *svc = (UISplitViewController*)vc;
        if (svc.viewControllers.count > 0) {
            return [self findBestViewController:svc.viewControllers.lastObject];
        } else {
            return vc;
        }
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *svc = (UINavigationController*)vc;
        if (svc.viewControllers.count > 0) {
            return [self findBestViewController:svc.topViewController];
        } else {
            return vc;
        }
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *svc = (UITabBarController *)vc;
        if (svc.viewControllers.count > 0) {
            return [self findBestViewController:svc.selectedViewController];
        } else {
            return vc;
        }
    } else {
        return vc;
    }
}

//+ (UIViewController *)topViewController {
//    UIViewController *resultVC;
//    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
//    while (resultVC.presentedViewController) {
//        resultVC = [self _topViewController:resultVC.presentedViewController];
//    }
//    return resultVC;
//}
//
//+ (UIViewController *)_topViewController:(UIViewController *)vc {
//    if ([vc isKindOfClass:[UINavigationController class]]) {
//        return [self _topViewController:[(UINavigationController *)vc topViewController]];
//    } else if ([vc isKindOfClass:[UITabBarController class]]) {
//        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
//    } else {
//        return vc;
//    }
//    return nil;
//}

@end
