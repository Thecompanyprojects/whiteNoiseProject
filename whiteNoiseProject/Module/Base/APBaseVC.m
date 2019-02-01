//
//  APBaseVC.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APBaseVC.h"
#import "APSoundListVC.h"
#import "APCustomListVC.h"
#import "APAboutUsVC.h"
#import "APWebVC.h"
#import "APFeedbackVC.h"

#define bgImgVTag 201855

@interface APBaseVC (){
    UIBarButtonItem *leftItem_;
}

@end

@implementation APBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ap_setupUI];
}

- (void)ap_setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.navigationController.viewControllers.count > 0 && self.navigationController.viewControllers[0] != self) {
        UIButton *leftView = [UIButton buttonWithType:UIButtonTypeCustom];
        leftView.frame = CGRectMake(0, 0, 44, 44);
        [leftView setImage:[UIImage imageNamed:@"返回白"] forState:UIControlStateNormal];
        if ([self isKindOfClass:[APCustomListVC class]] || [self isKindOfClass:[APSoundListVC class]] || [self isKindOfClass:[APAboutUsVC class]] || [self isKindOfClass:[APWebVC class]] ||
            [self isKindOfClass:[APFeedbackVC class]]) {
            [leftView setImage:[UIImage imageNamed:@"返回黑"] forState:UIControlStateNormal];
        }
        [leftView addTarget:self action:@selector(ap_navigationBarBackButtonItemActionHandle) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:leftView];
        self.navigationItem.leftBarButtonItem = item;
        leftItem_ = item;
    }
}

- (void)ap_navigationBarBackButtonItemActionHandle{
    [self.view endEditing:YES];
    if (self.navigationController.viewControllers[0] != self) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (BOOL)ap_backScreenGestureShouldEnabled {
    return YES;
}


- (void)setBackgroundImage:(UIImage *)backgroundImage {
    if (!backgroundImage) return;
    _backgroundImage = backgroundImage;
    [self.view insertSubview:self.baseImgV atIndex:0];
    [self.baseImgV mas_makeConstraints:^(MASConstraintMaker* make){
        make.edges.mas_equalTo(self.view);
    }];
    self.baseImgV.beginSetImage = true;
    [self.baseImgV setImage:backgroundImage];
}

- (APHomeAnimationView *)baseImgV {
    if (!_baseImgV) {
        _baseImgV = [APHomeAnimationView new]; //[[ThemeView alloc]init];
        _baseImgV.tag = bgImgVTag;
        _baseImgV.frame = self.view.bounds;
        
    }
    return _baseImgV;
}


@end
