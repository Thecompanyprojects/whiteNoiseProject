//
//  APPayCell.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/25.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APPayCell.h"

@interface APPayCell ()

@property (strong, nonatomic) UIButton *payButton;

@end

@implementation APPayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubviews];
        self.textLabel.font = FontPingFangL(14);
        self.detailTextLabel.font = FontPingFangL(10);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setButtonTitle:(NSString *)buttonTitle {
    _buttonTitle = buttonTitle;
    [self.payButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (void)initSubviews {
    self.payButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.payButton.titleLabel.font = FontPingFangL(12);
    [self.payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.payButton.layer.cornerRadius = 15;
    self.payButton.backgroundColor = [UIColor colorGradientWithSize:CGSizeMake(100, 30) direction:GradientDirection_Horizontal startColor:kHexColor(0xFA6BEA) endColor:kHexColor(0xA269FE)];
    [self.payButton addTarget:self action:@selector(payButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.payButton];
    [self.payButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 30));
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-20);
    }];
}



#pragma mark payButtonAction
- (void)payButtonAction:(UIButton *)sender {
    if (self.payAction) {
        self.payAction();
    }
}


@end
