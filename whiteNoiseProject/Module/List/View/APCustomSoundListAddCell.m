//
//  CustomAddCell.m
//  Sound
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018年 DDTR. All rights reserved.
//

#import "APCustomSoundListAddCell.h"

@implementation APCustomSoundListAddCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"custom_add"];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = self.contentView.bounds;
    [self.contentView addSubview:imageView];
}


@end
