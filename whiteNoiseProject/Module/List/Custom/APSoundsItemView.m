//
//  APSoundsItemView.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APSoundsItemView.h"
#import "APSoundSlider.h"
#import "APSoundModel.h"

@interface APSoundsItemView ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *deleteImageView;
@property (nonatomic, strong) APSoundSlider *slider;
@end
@implementation APSoundsItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)setModel:(APSoundModel *)model {
    _model = model;
    if (!model) {
        _slider.isEnable = NO;
        _deleteImageView.hidden = YES;
        _imageView.image = [UIImage imageNamed:@"custom_default"];
        return;
    }
    
    _deleteImageView.hidden = NO;
    _slider.isEnable = YES;
    
    _slider.value = model.volume;
    [_imageView sd_setImageWithURL:[NSURL URLWithString:model.image_select] placeholderImage:[UIImage imageNamed:@"custom_default"] options:SDWebImageRetryFailed];
}


- (void)initSubviews {
    self.imageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.image = [UIImage imageNamed:@"custom_default"];
        imageView;
    });
    [self addSubview:self.imageView];
    [self.imageView.widthAnchor constraintEqualToConstant:40].active = YES;
    [self.imageView.heightAnchor constraintEqualToAnchor:self.imageView.widthAnchor].active = YES;
    [self.imageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [self.imageView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:0].active = YES;
    
    
    self.deleteImageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.image = [UIImage imageNamed:@"custom_delete _01"];
        imageView;
    });
    [self addSubview:self.deleteImageView];
    [self.deleteImageView.widthAnchor constraintEqualToConstant:15].active = YES;
    [self.deleteImageView.heightAnchor constraintEqualToAnchor:self.deleteImageView.widthAnchor].active = YES;
    [self.deleteImageView.topAnchor constraintEqualToAnchor:self.imageView.topAnchor constant:-4].active = YES;
    [self.deleteImageView.leftAnchor constraintEqualToAnchor:self.imageView.leftAnchor constant:-4].active = YES;
    
    
    
    self.slider = ({
        APSoundSlider *slider = [[APSoundSlider alloc] init];
        slider.translatesAutoresizingMaskIntoConstraints = NO;
        slider.valueChanged = ^(NSInteger volume) {
            if (self.volumeChaneged) {
                NSLog(@"音效:%@-音量%zdf",self.model.soundId,volume);
                self.volumeChaneged(self.model, volume);
            }
        };
        slider;
    });
    [self addSubview:self.slider];
    [self.slider.heightAnchor constraintEqualToConstant:40.0].active = YES;
    [self.slider.leftAnchor constraintEqualToAnchor:self.imageView.rightAnchor constant:12].active = YES;
    [self.slider.centerYAnchor constraintEqualToAnchor:self.imageView.centerYAnchor].active = YES;
    [self.slider.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-0].active = YES;
}


@end

