//
//  APBaseNavigationController.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface APBaseNavVC : UINavigationController
// 导航栏两侧按钮颜色:黑色样式
- (void)ap_blackTitleStyle;

// 导航栏两侧按钮颜色:白色样式
- (void)ap_whiteTitleStyle;
@end

NS_ASSUME_NONNULL_END
