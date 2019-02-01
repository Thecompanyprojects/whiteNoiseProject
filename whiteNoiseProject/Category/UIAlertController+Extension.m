//
//  UIAlertController+Extension.m
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//
#import "UIAlertController+Extension.h"

@implementation UIAlertController (Extension)
+ (void)showAlertTitle:(NSString *)title
               message:(NSString *)message
           cancelTitle:(NSString *)cancelTitle
            otherTitle:(NSString *)otherTitle
           cancleBlock:(void (^)(void))cancleBlock
            otherBlock:(void (^)(void))otherBlock {
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelTitle.length == 0 && otherTitle.length == 0) {
        NSLog(@"🔥🔥🔥confirmTitle 和 cancelTitle至少有一个不为空🔥🔥🔥");
        return;
    }
    
    if (otherTitle || (cancelTitle == nil && otherTitle == nil)) {
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherTitle?:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (otherBlock) {
                otherBlock();
            }
        }];
        [alertController addAction:otherAction];
    }
    
    
    
    if (cancelTitle.length > 0) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (cancleBlock) {
                cancleBlock();
            }
        }];
        [alertController addAction:cancelAction];
    }
    
    [[self topViewController] presentViewController:alertController animated:YES completion:nil];
    
}

+ (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}


+ (void)showTextLeftAlertTitle:(NSString *)title
                       message:(NSString *)message
                   cancelTitle:(NSString *)cancelTitle
                    otherTitle:(NSString *)otherTitle
                   cancleBlock:(void (^)(void))cancleBlock
                    otherBlock:(void (^)(void))otherBlock {
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelTitle.length == 0 && otherTitle.length == 0) {
        NSLog(@"🔥🔥🔥confirmTitle 和 cancelTitle至少有一个不为空🔥🔥🔥");
        return;
    }
    
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherTitle?:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (otherBlock) {
            otherBlock();
        }
    }];
    [alertController addAction:otherAction];
    
    
    if (cancelTitle.length > 0) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (cancleBlock) {
                cancleBlock();
            }
        }];
        [alertController addAction:cancelAction];
    }
    
    
    // 实例化alertcontroller之后，可以遍历view的子视图，子视图title和message嵌套了多层父视图，（需要遍历6层subViews）,下面是取title和message的父视图的代码：
    UIView *subView1 = alertController.view.subviews[0];
    UIView *subView2 = subView1.subviews[0];
    UIView *subView3 = subView2.subviews[0];
    UIView *subView4 = subView3.subviews[0];
    UIView *subView5 = subView4.subviews[0];
    // 取title和message：
    //    UILabel *titleLabel = subView5.subviews[0];
    UILabel *messageLabel = subView5.subviews[1];
    // 然后设置message内容居左：
    messageLabel.textAlignment = NSTextAlignmentLeft;
    
    
    [[self topViewController] presentViewController:alertController animated:YES completion:nil];
    
}

+ (void)showPurchasesAlertViewWithTitle:(NSString *)title message:(NSString *)message actionPayTitle:(NSString *)payTitle actionRestoreTitle:(NSString *)restoreTitle cancelActionTitle:(NSString *)cancelTitle payAction:(void (^)(void))payAction restoreAction:(void (^)(void))restoreAction cancelAction:(void (^)(void))cancelAction {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOne = [UIAlertAction actionWithTitle:payTitle?:NSLocalizedString(@"Purchases Now", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (payAction) {
            payAction();
        }
    }];
    [alertController addAction:actionOne];
    
    UIAlertAction *actionTwo = [UIAlertAction actionWithTitle:restoreTitle?:NSLocalizedString(@"Restore Purchases", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (restoreAction) {
            restoreAction();
        }
    }];
    [alertController addAction:actionTwo];
    
    UIAlertAction *actionThree = [UIAlertAction actionWithTitle:cancelTitle?:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (cancelAction) {
            cancelAction();
        }
    }];
    [alertController addAction:actionThree];
    
    [[self topViewController] presentViewController:alertController animated:YES completion:nil];
}


@end

