//
//  APProgressView.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface APProgressView : UIView


/**
 * 圆形下载进度
 *
 * @param defaultColor  默认圆圈颜色
 * @param progressColor 进度圆圈颜色
 */
- (instancetype)initWithFrame:(CGRect)frame
                 defaultColor:(UIColor *)defaultColor
                progressColor:(UIColor *)progressColor;


/**
 进度值:0.0 - 1.0
 */
@property (nonatomic, assign) CGFloat progress;


@end

