//
//  APProgressView.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APProgressView.h"

@interface APProgressView ()

@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) CAShapeLayer *defaultLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAShapeLayer *pauseLayerLeft;
@property (nonatomic, strong) CAShapeLayer *pauseLayerRight;

@end
@implementation APProgressView

- (instancetype)initWithFrame:(CGRect)frame defaultColor:(UIColor *)defaultColor progressColor:(UIColor *)progressColor {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.6];
        
        self.progressLabel = [[UILabel alloc] init];
        self.progressLabel.font = [UIFont systemFontOfSize:12];
        self.progressLabel.textAlignment = NSTextAlignmentCenter;
        self.progressLabel.textColor = defaultColor?:[UIColor colorWithWhite:1.0 alpha:1.0];
        self.progressLabel.text = @"0%";
        self.progressLabel.frame = self.bounds;
        [self addSubview:self.progressLabel];
        
        CGFloat radius = 18.0;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((self.bounds.size.width - radius*2)/2.0, (self.bounds.size.height - radius * 2)/2.0, radius*2, radius*2) cornerRadius:radius];
        self.defaultLayer = [[CAShapeLayer alloc] init];
        self.defaultLayer.lineWidth = 2.4;
        self.defaultLayer.lineCap = kCALineJoinRound;
        self.defaultLayer.strokeColor = defaultColor?defaultColor.CGColor:[UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
        self.defaultLayer.fillColor = [UIColor clearColor].CGColor;
        self.defaultLayer.path = path.CGPath;
        [self.layer addSublayer:self.defaultLayer];
        
        
        UIBezierPath *pathA = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:18.0 startAngle:-M_PI_2 endAngle:(M_PI*2-M_PI_2) clockwise:YES];
        self.progressLayer = [[CAShapeLayer alloc] init];
        self.progressLayer.lineWidth = 2.4;
        self.progressLayer.lineCap = kCALineJoinRound;
        self.progressLayer.strokeColor = progressColor?progressColor.CGColor:[UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
        self.progressLayer.fillColor = [UIColor clearColor].CGColor;
        self.progressLayer.frame = self.bounds;
        self.progressLayer.path = pathA.CGPath;
        self.progressLayer.strokeStart = 0;
        self.progressLayer.strokeEnd = 0;
        [self.layer addSublayer:self.progressLayer];
        
    }
    return self;
}

- (void)setProgress:(CGFloat)progress {
    if (_progress > 1.0 || _progress < 0.0) {
        return;
    }
    
    NSLog(@"%.0f",progress*100);
    
    _progress = progress;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressLayer.strokeEnd = progress;
        self.progressLabel.text = [NSString stringWithFormat:@"%.0f%%",progress*100];
    });
}


@end

