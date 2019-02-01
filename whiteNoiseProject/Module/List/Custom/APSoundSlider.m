//
//  APSoundSlider.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#define kProgress_H  6.0
#define kCenter_W    12.0
#define kCenter_H    12.0
#define kLeft_M      (kCenter_W/2.0)
#define kRight_M     (kCenter_W/2.0)


#import "APSoundSlider.h"
#import "UIColor+Extension.h"

@interface APSoundSlider ()

@property (nonatomic, strong) NSLayoutConstraint *topViewRightConstraint;

@end
@implementation APSoundSlider


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 初始值
        _value = 0.5;
        _min = 0.0;
        _max = 1.0;
        [self initSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame value:(CGFloat)value {
    self = [super initWithFrame:frame];
    if (self) {
        _value = value;
        _min = 0.0;
        _max = 1.0;
        [self initSubviews];
    }
    return self;
}

- (void)setValue:(CGFloat)value {
    if (value < 0 || value > 1.0) {
        return;
    }
    _value = value;
    
    [self layoutIfNeeded];
    
    CGFloat x = value * (self.frame.size.width - kLeft_M - kRight_M) + kLeft_M;
    [self changeWithX:x];
}

- (void)setIsEnable:(BOOL)isEnable {
    _isEnable = isEnable;
    self.userInteractionEnabled = isEnable;
    
    self.topViewRightConstraint.active = NO;
    self.topViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.topView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bgView attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0];
    self.topViewRightConstraint.active = YES;
    
    if (isEnable) {
        _topView.backgroundColor = [UIColor colorGradientWithSize:CGSizeMake(280*KWIDTH, 6) direction:GradientDirection_Horizontal startColor:kHexColor(0xFA6BEA) endColor:kHexColor(0xA269FE)];
        _centerView.backgroundColor = [UIColor colorGradientWithSize:CGSizeMake(kCenter_W, kCenter_H) direction:GradientDirection_Horizontal startColor:kHexColor(0xFA6BEA) endColor:kHexColor(0xA269FE)];
    } else {
        _topView.backgroundColor = [UIColor colorGradientWithSize:CGSizeMake(280*KWIDTH, 6) direction:GradientDirection_Horizontal startColor:kHexColor(0xE5E5E5) endColor:kHexColor(0xE5E5E5)];
        _centerView.backgroundColor = [UIColor colorGradientWithSize:CGSizeMake(kCenter_W, kCenter_H) direction:GradientDirection_Horizontal startColor:kHexColor(0xE5E5E5) endColor:kHexColor(0xE5E5E5)];
    }
}



- (void)initSubviews {
    
    self.bgView = ({
        UIView *view = [[UIView alloc] init];
        view.layer.cornerRadius = 3.0;
        view.backgroundColor = kHexColor(0xF4F4F4);
        view.userInteractionEnabled = NO;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view;
    });
    [self addSubview:self.bgView];
    [self.bgView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:kLeft_M].active = YES;
    [self.bgView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-kRight_M].active = YES;
    [self.bgView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:0].active = YES;
    [self.bgView.heightAnchor constraintEqualToConstant:kProgress_H].active = YES;
    
    self.topView = ({
        UIView *view = [[UIView alloc] init];
        view.layer.cornerRadius = 3.0;
        view.userInteractionEnabled = NO;
        view.backgroundColor = [UIColor colorGradientWithSize:CGSizeMake(280*KWIDTH, 6) direction:GradientDirection_Horizontal startColor:kHexColor(0xE5E5E5) endColor:kHexColor(0xE5E5E5)];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view;
    });
    [self addSubview:self.topView];
    [self.topView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:kLeft_M].active = YES;
    [self.topView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:0].active = YES;
    [self.topView.heightAnchor constraintEqualToConstant:kProgress_H].active = YES;
    self.topViewRightConstraint = [self.topView.widthAnchor constraintEqualToAnchor:self.bgView.widthAnchor multiplier:0.5];
    self.topViewRightConstraint.active = YES;
    
    
    
    self.centerView = ({
        UIView *view = [[UIView alloc] init];
        view.layer.cornerRadius = kCenter_W / 2.0;
        view.userInteractionEnabled = NO;
        view.layer.shadowOffset = CGSizeMake(0, 0);
        view.layer.shadowRadius = 1;
        view.layer.shadowOpacity = 0.2;
        view.backgroundColor = [UIColor colorGradientWithSize:CGSizeMake(kCenter_W, kCenter_H) direction:GradientDirection_Horizontal startColor:kHexColor(0xE5E5E5) endColor:kHexColor(0xE5E5E5)];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view;
    });
    [self addSubview:self.centerView];
    [self.centerView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [self.centerView.widthAnchor constraintEqualToConstant:kCenter_W].active = YES;
    [self.centerView.heightAnchor constraintEqualToConstant:kCenter_H].active = YES;
    [self.centerView.centerXAnchor constraintEqualToAnchor:self.topView.rightAnchor].active = YES;
    
    
    
    CGFloat numberView_w = 28.0;
    CGFloat numberView_h = 32.0;
    self.numberView = ({
        UIView *view = [[UIView alloc] init];
        view.hidden = YES;
        view.userInteractionEnabled = NO;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view.backgroundColor = [UIColor colorGradientWithSize:CGSizeMake(numberView_w, numberView_h) direction:GradientDirection_Horizontal startColor:kHexColor(0xFA6BEA) endColor:kHexColor(0xA269FE)];
        view.layer.cornerRadius = numberView_w / 2.0;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path addArcWithCenter:CGPointMake(numberView_w / 2.0, numberView_w / 2.0) radius:numberView_w / 2.0 startAngle:-1.25 * M_PI endAngle:0.25 * M_PI clockwise:YES];
        [path addLineToPoint:CGPointMake(numberView_w / 2.0, numberView_h)];
        [path closePath];
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.strokeColor = [UIColor clearColor].CGColor;
        layer.fillColor = [UIColor whiteColor].CGColor;
        layer.path = path.CGPath;
        view.layer.mask = layer;
        view;
    });
    [self addSubview:self.numberView];
    [self.numberView.widthAnchor constraintEqualToConstant:numberView_w].active = YES;
    [self.numberView.heightAnchor constraintEqualToConstant:numberView_h].active = YES;
    [self.numberView.bottomAnchor constraintEqualToAnchor:self.centerView.topAnchor constant:-2].active = YES;
    [self.numberView.centerXAnchor constraintEqualToAnchor:self.centerView.centerXAnchor].active = YES;
    
    
    self.numberLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont systemFontOfSize:11];
        label.textColor = [UIColor colorWithWhite:1 alpha:1.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%.0f",self.value*100];
        label;
    });
    [self.numberView addSubview:self.numberLabel];
    [self.numberLabel.leftAnchor constraintEqualToAnchor:self.numberView.leftAnchor].active = YES;
    [self.numberLabel.rightAnchor constraintEqualToAnchor:self.numberView.rightAnchor].active = YES;
    [self.numberLabel.bottomAnchor constraintEqualToAnchor:self.numberView.bottomAnchor constant:-4].active = YES;
    [self.numberLabel.topAnchor constraintEqualToAnchor:self.numberView.topAnchor].active = YES;
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    self.numberView.hidden = NO;
    [self changePointX:touch];
    if (self.startTouchBlock) {
        self.startTouchBlock();
    }
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self changePointX:touch];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    self.numberView.hidden = YES;
    [self changePointX:touch];
    if (self.endTouchBlock) {
        self.endTouchBlock();
    }
}

- (void)changePointX:(UITouch *)touch {
    CGPoint point = [touch locationInView:self];
    [self changeWithX:point.x];
    
    if (self.valueChanged) {
//        CGFloat value = (point.x - kLeft_M) / (self.bounds.size.width - kLeft_M - kRight_M);
//        if (value >= 0 && value <= 1) {
//            self.valueChanged(value);
//        }
         self.valueChanged(self.numberLabel.text.integerValue);
    }
    
}

- (void)changeWithX:(CGFloat)x {
    self.topViewRightConstraint.active = NO;
    if (x <= kLeft_M) {
        self.numberLabel.text = @"0";
        self.topViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.topView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bgView attribute:NSLayoutAttributeWidth multiplier:0 constant:0];
    } else if (x >= self.bounds.size.width - kRight_M) {
        self.numberLabel.text = @"100";
        self.topViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.topView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bgView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    } else {
        CGFloat number = (x - kLeft_M)/(self.bounds.size.width - kLeft_M - kRight_M) * 100;
        self.numberLabel.text = [NSString stringWithFormat:@"%.0f",number];
        
        CGFloat multiplier = (x - kLeft_M)/(self.bounds.size.width - kLeft_M - kRight_M);
        self.topViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.topView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bgView attribute:NSLayoutAttributeWidth multiplier:multiplier constant:0];
    }
    self.topViewRightConstraint.active = YES;
    
}




@end
