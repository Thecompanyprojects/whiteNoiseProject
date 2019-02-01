//
//  APHomeCorrugationView.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APHomeCorrugationView.h"

@interface APHomeCorrugationView ()

@property (nonatomic, strong)   UILabel     *titleLabel;
@property (nonatomic, strong)   MSWeakTimer *timer;
@property (nonatomic, strong)   UIColor     *color;
@property (nonatomic, copy)     NSString    *title;

@end

@implementation APHomeCorrugationView

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color title:(NSString *)title{
    self = [super initWithFrame:frame];
    if (self) {
        _title = title;
        _color = color;
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    [self addSubview:self.baseImgV];
    [self addSubview:self.imageView];
    [self addSubview:self.titleLabel];
    
    
    CGFloat random = arc4random_uniform(20)/10.0f;
    NSLog(@"%f",random);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(random * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        MSWeakTimer *timer = [MSWeakTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(observeAnimationEvent) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
        self.timer = timer;
    });
}

- (void)observeAnimationEvent{
    UIImageView *animationView = [[UIImageView alloc]init];
    animationView.backgroundColor = self.color;
    animationView.alpha = 0.3;
    animationView.layer.masksToBounds = YES;
    animationView.layer.cornerRadius = self.xy_width*0.5;
    animationView.frame = self.bounds;
    [self addSubview:animationView];
    [self sendSubviewToBack:animationView];
    
    [UIView animateWithDuration:3 animations:^{
        animationView.alpha = 0;
        animationView.transform = CGAffineTransformMakeScale(1.4, 1.4);
    } completion:^(BOOL finished) {
        [animationView removeFromSuperview];
    }];
    
}


- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.backgroundColor = self.color;
        _imageView.alpha = 0.3;
        
        _imageView.frame = self.bounds;
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = self.xy_width*0.5;
    }
    return _imageView;
}

- (UIImageView *)baseImgV{
    if (!_baseImgV) {
        _baseImgV = [[UIImageView alloc]init];
        _baseImgV.frame = self.bounds;
    }
    return _baseImgV;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.text = self.title;
        _titleLabel.font = FontPingFangR(20*KWIDTH);
        _titleLabel.textColor = [UIColor whiteColor];
        [_titleLabel sizeToFit];
        _titleLabel.center = CGPointMake(self.xy_width*0.5, self.xy_height*0.5);
    }
    return _titleLabel;
}

@end
