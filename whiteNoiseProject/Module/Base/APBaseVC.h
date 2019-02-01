//
//  APBaseVC.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "whiteNoiseProject-Swift.h"

@interface APBaseVC : UIViewController

@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) APHomeAnimationView *baseImgV;

// 点击导航栏返回上一页
- (void)ap_navigationBarBackButtonItemActionHandle;

// 是否允许边缘手势返回上一页
- (BOOL)ap_backScreenGestureShouldEnabled;


@end


