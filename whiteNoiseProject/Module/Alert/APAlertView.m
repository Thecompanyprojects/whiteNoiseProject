//
//  APNoiseAlertView.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APAlertView.h"
#define btnTag  20182021

@interface APAlertView ()

@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, copy) NSArray  *array;

@end

@implementation APAlertView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title subTitle:(NSString *)subTitle array:(NSArray *)array{
    self = [super initWithFrame:frame];
    if (self) {
        _title = title;
        _subTitle = subTitle;
        _array = array;
        [self setupUI];
    }
    return self;
}


#define baseW (325*KWIDTH)
#define btnH (60*KWIDTH)
#define space (5*KWIDTH)
- (void)setupUI{
    [self addSubview:self.baseView];
    [self.baseView addSubview:self.titleLabel];
    [self.baseView addSubview:self.subTitleLabel];
    
    
    _titleLabel.center = CGPointMake(baseW*0.5, 20*KWIDTH + _titleLabel.xy_height*0.5);
    
    _subTitleLabel.xy_y = CGRectGetMaxY(self.titleLabel.frame) + space;
    _subTitleLabel.xy_x = (baseW-220*KWIDTH)*0.5;
    
    CGFloat height = btnH*2 + CGRectGetMaxY(self.subTitleLabel.frame) + 15*KHEIGHT;
    self.baseView.frame = CGRectMake((self.xy_width-baseW)*0.5, self.xy_y-height, baseW, height);
    
    CGFloat y = CGRectGetMaxY(self.subTitleLabel.frame) + 15*KHEIGHT;
    for (int i=0; i<self.array.count+1; i++) {
        NSString *title;
        UIColor *color ;
        if (i==self.array.count) {
            title = NSLocalizedString(@"Cancel", nil);
            color = [UIColor colorWithHex:0x0033ff];
        }else{
            title = self.array[i];
            color = [UIColor colorWithHex:0xff0000];
        }
        
        UIButton *btn = [[UIButton alloc]init];
        btn.tag = btnTag+i;
        [btn setTitle:title forState:UIControlStateNormal];
        btn.titleLabel.font = FontPingFangL(14*KWIDTH);
        [btn setTitleColor:color forState:UIControlStateNormal];
        btn.frame = CGRectMake(0 , i * btnH + y , self.baseView.xy_width, btnH);
        [self.baseView addSubview:btn];
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, btn.xy_width, 0.5*KWIDTH)];
        lineView.backgroundColor = [UIColor colorWithHex:0xdddddd];
        [btn addSubview:lineView];
    }
    
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.baseView.xy_centerY = self.xy_height*0.5;
                     }completion:nil];
}

- (void)clickBtn:(UIButton *)sender{
    
    NSInteger index = sender.tag - btnTag;
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakself.baseView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        weakself.baseView.alpha = 0;
    } completion:^(BOOL finished) {
        [weakself removeFromSuperview];
        if (index == weakself.array.count) {
        }else{
            if (weakself.callBackBlock) {
                weakself.callBackBlock(index);
            }
        }
    }];
}

//T20 S8 B15  M_W300 T_w250  S_W230
//H150
- (UIView *)baseView{
    if (!_baseView) {
        _baseView = [[UIView alloc]init];
        _baseView.backgroundColor = [UIColor whiteColor];
        _baseView.layer.masksToBounds = YES;
        _baseView.layer.cornerRadius = 20*KWIDTH;
    }
    return _baseView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = self.title;
        _titleLabel.font = FontPingFangR(15*KWIDTH);
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        [_titleLabel sizeToFit];
        CGFloat height = [UIView getHeightByWidth:250*KWIDTH title:self.title font:_titleLabel.font];
        _titleLabel.xy_width = 250*KWIDTH;
        _titleLabel.xy_height = height;
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel{
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc]init];
        _subTitleLabel.text = self.subTitle;
        _subTitleLabel.font = FontPingFangU(14*KWIDTH);
        _subTitleLabel.textColor = [UIColor colorWithHex:0x666666];
        _subTitleLabel.numberOfLines = 0;
        _subTitleLabel.textAlignment = NSTextAlignmentCenter;
        [_subTitleLabel sizeToFit];
        CGFloat height = [UIView getHeightByWidth:220*KWIDTH title:self.subTitle font:_subTitleLabel.font];
        _subTitleLabel.xy_width = 220*KWIDTH;
        _subTitleLabel.xy_height = height;
    }
    return _subTitleLabel;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

