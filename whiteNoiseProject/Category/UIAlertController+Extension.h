//
//  UIAlertController+Extension.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Extension)

/**
 系统弹窗
 
 @param title           标题
 @param message         内容信息
 @param cancelTitle     取消按钮 标题文字
 @param otherTitle      其他按钮 标题文字
 @param cancleBlock     取消按钮 Block
 @param otherBlock      其他按钮 Block
 */
+ (void)showAlertTitle:(NSString *)title
               message:(NSString *)message
           cancelTitle:(NSString *)cancelTitle
            otherTitle:(NSString *)otherTitle
           cancleBlock:(void (^)(void))cancleBlock
            otherBlock:(void (^)(void))otherBlock;



/**
 系统弹窗 内容左对齐
 
 @param title           标题
 @param message         内容信息
 @param cancelTitle     取消按钮 标题文字
 @param otherTitle      其他按钮 标题文字
 @param cancleBlock     取消按钮 Block
 @param otherBlock      其他按钮 Block
 */
+ (void)showTextLeftAlertTitle:(NSString *)title
                       message:(NSString *)message
                   cancelTitle:(NSString *)cancelTitle
                    otherTitle:(NSString *)otherTitle
                   cancleBlock:(void (^)(void))cancleBlock
                    otherBlock:(void (^)(void))otherBlock;



/**
 展示购买提示弹窗
 */
+ (void)showPurchasesAlertViewWithTitle:(NSString *)title message:(NSString *)message actionPayTitle:(NSString *)payTitle actionRestoreTitle:(NSString *)restoreTitle cancelActionTitle:(NSString *)cancelTitle payAction:(void (^)(void))payAction restoreAction:(void (^)(void))restoreAction cancelAction:(void (^)(void))cancelAction;

@end
