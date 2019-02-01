//
//  NSObject+Swizzling.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (Swizzling)
/**
 类方法交换
 
 @param originalSelector    原始类方法名
 @param newSelector         新类方法名
 */
+ (void)yg_swizzlingClassMethod:(SEL)originalSelector withMethod:(SEL)newSelector;


/**
 实例方法交换
 
 @param originalSelector    原始实例方法名
 @param newSelector         新实例方法名
 */
+ (void)yg_swizzlingInstanceMethod:(SEL)originalSelector withMethod:(SEL)newSelector;

@end
