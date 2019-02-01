//
//  APNavigationController.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APNavVC.h"

@interface APNavVC ()
@property (nonatomic, strong) UIImageView *baseImgV;
@end

@implementation APNavVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UIImageView *)baseImgV{
    if (!_baseImgV) {
        _baseImgV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"首页背景图"]];
        _baseImgV.frame = self.view.bounds;
    }
    return _baseImgV;
}

@end
