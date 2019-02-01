//
//  APSoundSlider.h
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APSoundSlider : UIControl

@property (nonatomic, copy) dispatch_block_t startTouchBlock;
@property (nonatomic, copy) dispatch_block_t endTouchBlock;

@property (nonatomic, assign, readonly) CGFloat max;
@property (nonatomic, assign, readonly) CGFloat min;
@property (nonatomic, assign, readwrite) CGFloat value;


@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) UIView *numberView;
@property (nonatomic, strong) UILabel *numberLabel;




@property (nonatomic, assign) BOOL isEnable;


- (instancetype)initWithFrame:(CGRect)frame value:(CGFloat)value;

// 1...100
@property (nonatomic, copy) void (^valueChanged)(NSInteger volume);
@end
