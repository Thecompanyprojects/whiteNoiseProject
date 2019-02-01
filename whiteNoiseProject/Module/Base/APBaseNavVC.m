//
//  APBaseNavigationController.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APBaseNavVC.h"

@interface APBaseNavVC () <UIGestureRecognizerDelegate>

@end

@implementation APBaseNavVC

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.topViewController.preferredStatusBarStyle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interactivePopGestureRecognizer.delegate = self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.viewControllers.count <= 1 ) {
        return NO;
    }
    
    UIViewController *topVC = self.topViewController;
    if ([topVC isKindOfClass:[APBaseVC class]]) {
        APBaseVC *baseClassVC = (APBaseVC *)topVC;
        return [baseClassVC ap_backScreenGestureShouldEnabled];
    }
    
    return YES;
}

+ (void)initialize {
    UINavigationBar* appearance =[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[APBaseNavVC class]]];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    appearance.translucent = YES;
    appearance.backgroundColor = [UIColor clearColor];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
}

- (void)ap_blackTitleStyle{
    [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName:FontPingFangR(17*KWIDTH),NSForegroundColorAttributeName:[UIColor blackColor]}];
}

- (void)ap_whiteTitleStyle{
    [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName:FontPingFangR(17*KWIDTH),NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

@end
