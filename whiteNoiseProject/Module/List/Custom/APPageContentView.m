//
//  APPageContentView.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APPageContentView.h"
#import "APPageItemView.h"

#import "APSoundClassModel.h"
#import "APSoundModel.h"
#import "UIColor+Extension.h"
#import <JXCategoryView/JXCategoryView.h>

@interface APPageContentView () <UIScrollViewDelegate, JXCategoryViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) JXCategoryTitleView *titleView;
@property (nonatomic, strong) NSMutableArray <NSString *>*pageTitleArrayM;
@property (nonatomic, strong) NSMutableArray <APPageItemView *>*pageItemViewArrayM;

@end

@implementation APPageContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (NSMutableArray<NSString *> *)pageTitleArrayM {
    if (!_pageTitleArrayM) {
        _pageTitleArrayM = [NSMutableArray array];
    }
    return _pageTitleArrayM;
}

- (NSMutableArray<APPageItemView *> *)pageItemViewArrayM {
    if (!_pageItemViewArrayM) {
        _pageItemViewArrayM = [NSMutableArray array];
    }
    return _pageItemViewArrayM;
}

// 赋值
- (void)setDataArray:(NSArray<APSoundClassModel *> *)dataArray {
    _dataArray = dataArray;
    
    // 设置滚动范围
    CGFloat view_w = [UIScreen mainScreen].bounds.size.width * 0.95;
    self.scrollView.contentSize = CGSizeMake(view_w * self.dataArray.count, 0);
    
    // 创建
    NSInteger difference = dataArray.count - self.pageItemViewArrayM.count;
    
    if (difference > 0) {
        for (NSInteger i = 0; i < difference; i++) {
            APPageItemView *itemView = [[APPageItemView alloc] init];
            itemView.backgroundColor = [UIColor clearColor];
            itemView.translatesAutoresizingMaskIntoConstraints = NO;
            [self.pageItemViewArrayM addObject:itemView];
            [self.scrollView addSubview:itemView];
        }
    }
    
    // 布局/回调
    for (NSInteger i = 0; i < self.pageItemViewArrayM.count; i++) {
        APPageItemView *itemView = self.pageItemViewArrayM[i];
        itemView.translatesAutoresizingMaskIntoConstraints = NO;
        [itemView.leftAnchor constraintEqualToAnchor:self.scrollView.leftAnchor constant:(i * view_w)].active = YES;
        [itemView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor].active = YES;
        [itemView.heightAnchor constraintEqualToAnchor:self.scrollView.heightAnchor].active = YES;
        [itemView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor].active = YES;
        itemView.ItemSelect = ^BOOL(APSoundModel *model) {
            if (self.pageContentItemSelect) {
                return self.pageContentItemSelect(model);
            } else {
                return NO;
            }
        };
        itemView.ItemSelectShouldVip = ^(APSoundModel *model) {
            if (self.pageContentItemSelectShouldVip) {
                self.pageContentItemSelectShouldVip(model);
            }
        };
    }
    
    for (NSInteger i = 0; i < self.dataArray.count; i++) {
        APSoundClassModel *model = self.dataArray[i];
        [self.pageTitleArrayM  addObject:model.groupName];
        APPageItemView *itemView = self.pageItemViewArrayM[i];
        itemView.model = model;
    }
    self.titleView.titles = self.pageTitleArrayM.copy;
}

- (void)initSubviews {
    
    self.scrollView = ({
        UIScrollView *scView = [[UIScrollView alloc] init];
        scView.delegate = self;
        scView.pagingEnabled = YES;
        scView.bounces = YES;
        scView.backgroundColor = [UIColor clearColor];
        scView.showsHorizontalScrollIndicator = NO;
        scView.showsVerticalScrollIndicator = NO;
        scView;
    });
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.scrollView];
    
    self.titleView = ({
        JXCategoryTitleView *titleView = [[JXCategoryTitleView alloc] init];
        titleView.delegate = self;
        titleView.titleFont = FontPingFangL(15);
        titleView.titleColor = [UIColor blackColor];
        titleView.titleSelectedColor = kHexColor(0xFA6BEA);
        titleView.titleColorGradientEnabled = YES;
        titleView.contentScrollView = self.scrollView;
        
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.indicatorLineWidth = JXCategoryViewAutomaticDimension;
        lineView.indicatorLineViewHeight = 2.0;
        lineView.indicatorLineViewColor = kHexColor(0xFA6BEA);

        
        lineView.clipsToBounds = YES;
        titleView.indicators = @[lineView];
        
        titleView;
    });
    self.titleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.titleView];
    [self.titleView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [self.titleView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.titleView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [self.titleView.heightAnchor constraintEqualToConstant:32].active = YES;
    
    [self.scrollView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [self.scrollView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [self.scrollView.topAnchor constraintEqualToAnchor:self.titleView.bottomAnchor constant:10.0].active = YES;
    [self.scrollView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
}


#pragma mark - JXCategoryViewDelegate
//为什么会把选中代理分为三个，因为有时候只关心点击选中的，有时候只关心滚动选中的，有时候只关心选中。所以具体情况，使用对应方法。
/**
 点击选择或者滚动选中都会调用该方法，如果外部不关心具体是点击还是滚动选中的，只关心选中这个事件，就实现该方法。
 
 @param categoryView categoryView description
 @param index 选中的index
 */
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    
}

/**
 点击选中的情况才会调用该方法
 
 @param categoryView categoryView description
 @param index 选中的index
 */
- (void)categoryView:(JXCategoryBaseView *)categoryView didClickSelectedItemAtIndex:(NSInteger)index {
    
}

/**
 滚动选中的情况才会调用该方法
 
 @param categoryView categoryView description
 @param index 选中的index
 */
- (void)categoryView:(JXCategoryBaseView *)categoryView didScrollSelectedItemAtIndex:(NSInteger)index {
    
}

/**
 正在滚动中的回调
 
 @param categoryView categoryView description
 @param leftIndex 正在滚动中，相对位置处于左边的index
 @param rightIndex 正在滚动中，相对位置处于右边的index
 @param ratio 百分比
 */
- (void)categoryView:(JXCategoryBaseView *)categoryView scrollingFromLeftIndex:(NSInteger)leftIndex toRightIndex:(NSInteger)rightIndex ratio:(CGFloat)ratio {
    
}
@end

