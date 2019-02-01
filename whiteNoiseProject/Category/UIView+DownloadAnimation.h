//
//  UIView+DownloadAnimation.h
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UIView (DownloadAnimation)

// 1:添加动画图层
- (void)addDownloadlayer;

// 2:设置进度动画,progress取值0~1,大于1时自动执行完成动画并移除控件
- (void)setDownloadProgress:(CGFloat)progress;

// 3:完成动画图层
- (void)downloadFinished;

// 3:移除动画图层
- (void)removeDownloadlayer;

@end
