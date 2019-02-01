//
//  APTextAlertView.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface APTextAlertView : UIView

+ (void)showSaveAlertViewWithComplete:(void(^)(NSString *text))complete;
+ (void)dismissSaveAlertView;

@end

NS_ASSUME_NONNULL_END
