//
//  UIView+YGNib.m
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "UIView+YGNib.h"

@implementation UIView (YGNib)
+ (instancetype)yg_loadViewFromNib {
    return [self yg_loadViewFromNibWithName:NSStringFromClass([self class])];
}

+ (instancetype)yg_loadViewFromNibWithName:(NSString *)nibName {
    return [self yg_loadViewFromNibWithName:nibName owner:nil];
}

+ (instancetype)yg_loadViewFromNibWithName:(NSString *)nibName owner:(id)owner {
    return [self yg_loadViewFromNibWithName:nibName owner:owner bundle:[NSBundle mainBundle]];
}

+ (instancetype)yg_loadViewFromNibWithName:(NSString *)nibName owner:(id)owner bundle:(NSBundle *)bundle {
    UIView *result = nil;
    NSArray* elements = [bundle loadNibNamed:nibName owner:owner options:nil];
    for (id object in elements) {
        if ([object isKindOfClass:[self class]]) {
            result = object;
            break;
        }
    }
    return result;
}
@end
