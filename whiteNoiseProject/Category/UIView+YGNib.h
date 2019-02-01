//
//  UIView+YGNib.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (YGNib)
+ (instancetype)yg_loadViewFromNib;
+ (instancetype)yg_loadViewFromNibWithName:(NSString *)nibName;
+ (instancetype)yg_loadViewFromNibWithName:(NSString *)nibName owner:(id)owner;
+ (instancetype)yg_loadViewFromNibWithName:(NSString *)nibName owner:(id)owner bundle:(NSBundle *)bundle;
@end
