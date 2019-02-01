//
//  APCustomCardView.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APCustomCardView.h"
#import "UIColor+Extension.h"

#import "APSoundsContentView.h"
#import "APPageContentView.h"
#import "APPayVC.h"

#import "APSoundClassModel.h"
#import "APSoundModel.h"
#import "APCustomModel.h"




#define kSCREEN_W       [UIScreen mainScreen].bounds.size.width
#define kSCREEN_H       [UIScreen mainScreen].bounds.size.height
#define kWINDOD         [UIApplication sharedApplication].keyWindow
#define kSCALE_W        (kSCREEN_W / 375.0)
#define kSCALE_H        (kSCREEN_H / 667.0)

#define kCARDVIEW_TAG   9990001
#define kBGVIEW_TAG     9990002

@interface APCustomCardView ()

@property (nonatomic, strong) APSoundsContentView *selectedView;
@property (nonatomic, strong) APPageContentView *contentView;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIImageView *closeImageView;

@property (nonatomic, strong) NSMutableArray <APSoundClassModel *>*dataArray;
@property (nonatomic, strong) APCustomModel *customModel;

@property (nonatomic, copy) void (^complete)(APCustomModel *model);

@end
@implementation APCustomCardView

- (instancetype)initWithCustomSourceDataArray:(NSMutableArray<APSoundClassModel *> *)dataArray customDataModel:(APCustomModel *)APCustomModel addSoundBlock:(void (^)(APSoundModel *))addHandle deleteSoundBlock:(void (^)(APSoundModel *))deleteHandle volumeChangedBlock:(void (^)(APSoundModel *))volumeHandle confirmBlock:(void (^)(APCustomModel *))confirmHandle {
    self = [super initWithFrame:CGRectMake(0, 0, kSCREEN_W * 0.95, kSCREEN_H * 0.9)];
    if (self) {
        self.dataArray = dataArray;
        self.customModel = APCustomModel;
        self.complete = confirmHandle;
        self.tag = kCARDVIEW_TAG;
        self.layer.cornerRadius = 8.0;
        self.layer.masksToBounds = YES;
        self.center = kWINDOD.center;
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        
        [self initSubViews];
        
        @weakify(self);
        // selectedView触发事件
        self.selectedView.volumeChanged = ^(APSoundModel *sound, CGFloat voloum) {
            NSLog(@"音效:%@--音量:%.2f",sound.name_en, voloum);
//            if (voloum < 0.03) {
//                sound.volume = 0;
//            } else {
//            }
            sound.volume = voloum/100.0;
            if (volumeHandle) {
                volumeHandle(sound);
            }
        };
        
        // 顶部选择
        self.selectedView.deleteSound = ^(APSoundModel *sound) {
            @strongify(self);
            NSLog(@"删除音效:%@",sound.name_en);
            if (deleteHandle) {
                deleteHandle(sound);
            }
            self.contentView.dataArray = self.dataArray;
        };
        
        // 需要先订阅
        self.contentView.pageContentItemSelectShouldVip = ^(APSoundModel *model) {
            // 隐藏窗口,弹出订阅
            @strongify(self);
            APPayVC *vipVC = [APPayVC new];
            [self dismissCuntomSelectView];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[UIViewController currentViewController] presentViewController:vipVC animated:YES completion:nil];
            });
            
        };
        
        
        // 正常选择
        self.contentView.pageContentItemSelect = ^BOOL(APSoundModel *model) {
            @strongify(self);
            
            // 已选择
            if ([self isContainsAPSoundModel:model]) {
                if (self.customModel.sounds.count <= 1) { // 不能少于一个
                    [SVProgressHUD showInfoWithStatus:@"You need to choose at least one!"];
                    
                } else { // 可以删除
                    model.is_default = NO;
                    [self.selectedView deleteSoundItem:model];
                    
                    if (deleteHandle) {
                        deleteHandle(model);
                    }
                }
                return NO;
            }
            
            
            // 没有选择
            if (self.customModel.sounds.count >= 3) { // 替换
                
                [SVProgressHUD showInfoWithStatus:@"you have added 3 sounds, please remove one."];
                
                return NO;
                
            } else { // 直接添加
                model.is_default = YES;
                [self.selectedView addSoundItem:model];
                
                if (addHandle) {
                    addHandle(model);
                }
                return YES;
            }
        };
        
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDate:) name:@"kPaymentSuccessNotifactionName" object:nil];
    
    return self;
}


- (void)refreshDate:(NSNotification *)notification {
    self.contentView.dataArray = self.dataArray;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isContainsAPSoundModel:(APSoundModel *)model {
    for (APSoundModel *sound in self.customModel.sounds) {
        if ([sound.groupId isEqualToNumber:model.groupId] && [sound.soundId isEqualToNumber:model.soundId]) {
            return YES;
        }
    }
    return NO;
}


- (void)showCuntomSelectView {
    if (self.dataArray.count <= 0) {
        return;
    }
    
    UIView *backgroundView = [kWINDOD viewWithTag:kBGVIEW_TAG];
    if (backgroundView) {
        return;
    }
    
    backgroundView = [[UIView alloc] init];
    backgroundView.tag = kBGVIEW_TAG;
    backgroundView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    backgroundView.frame = kWINDOD.bounds;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewTapAction:)];
    [backgroundView addGestureRecognizer:tap];
    
    [kWINDOD addSubview:backgroundView];
    [kWINDOD addSubview:self];
    
    backgroundView.alpha = 0.0;
    self.alpha = 0.0;
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:20 options:UIViewAnimationOptionCurveEaseIn animations:^{
        backgroundView.alpha = 1.0;
        self.alpha = 1.0;
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
    
}


- (void)backgroundViewTapAction:(UITapGestureRecognizer *)sender {
    //    [self dismissCuntomView];
}

- (void)dismissCuntomSelectView {
    UIView *backgroundView = [kWINDOD viewWithTag:kBGVIEW_TAG];
    if (!backgroundView) {
        return;
    }
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        backgroundView.alpha = 0;
        self.alpha = 0;
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
        [self removeFromSuperview];
    }];
}


#pragma mark initSubViews
- (void)initSubViews {
    self.selectedView = ({
        APSoundsContentView *view = [APSoundsContentView new];
        view.dataArrM = self.customModel.sounds;
        view;
    });
    self.selectedView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.selectedView];
    [self.selectedView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [self.selectedView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.selectedView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [self.selectedView.heightAnchor constraintEqualToAnchor:self.selectedView.widthAnchor multiplier:0.6].active = YES;
    
    
    UIView *lineView = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = kHexColor(0xDDDDDD);
        view.translatesAutoresizingMaskIntoConstraints = NO;
        view;
    });
    [self addSubview:lineView];
    [lineView.heightAnchor constraintEqualToConstant:1.0].active = YES;
    [lineView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [lineView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [lineView.topAnchor constraintEqualToAnchor:self.selectedView.bottomAnchor constant:0].active = YES;
    
    
    CGFloat confirmButton_w = (100.0 * kSCALE_W);
    CGFloat confirmButton_h = (30.0 * kSCALE_W);
    self.confirmButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:@"Confirm" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(confirmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor colorGradientWithSize:CGSizeMake(confirmButton_w, confirmButton_h) direction:GradientDirection_Horizontal startColor:[UIColor colorWithHexString:@"#FA6BEA"] endColor:[UIColor colorWithHexString:@"#A269FE"]];
        button.layer.cornerRadius = confirmButton_h / 2.0;
        button.layer.masksToBounds = YES;
        button;
    });
    
    [self addSubview:self.confirmButton];
    self.confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.confirmButton.widthAnchor constraintEqualToConstant:confirmButton_w].active = YES;
    [self.confirmButton.heightAnchor constraintEqualToConstant:confirmButton_h].active = YES;
    [self.confirmButton.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-20].active = YES;
    [self.confirmButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:0].active = YES;
    
    self.contentView = ({
        APPageContentView *view = [APPageContentView new];
        view.dataArray = self.dataArray;
        view.backgroundColor = [UIColor clearColor];
        view;
    });
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.contentView];
    [self.contentView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [self.contentView.topAnchor constraintEqualToAnchor:lineView.bottomAnchor constant:4.0].active = YES;
    [self.contentView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:self.confirmButton.topAnchor constant:-20].active = YES;
    
    self.closeImageView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.userInteractionEnabled = YES;
        imageView.image = [UIImage imageNamed:@"custom_card_close"];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeCustomView:)];
        [imageView addGestureRecognizer:tap];
        imageView;
    });
    [self addSubview:self.closeImageView];
    [self.closeImageView.widthAnchor constraintEqualToConstant:28*KWIDTH].active = YES;
    [self.closeImageView.heightAnchor constraintEqualToAnchor:self.closeImageView.widthAnchor multiplier:1].active = YES;
    [self.closeImageView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0].active = YES;
    [self.closeImageView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:0].active = YES;
}

- (void)closeCustomView:(UITapGestureRecognizer *)sender {
    [self dismissCuntomSelectView];
}


- (void)confirmButtonAction:(UIButton *)sender {
    if (self.complete) {
        self.complete(self.customModel);
    }
    [self dismissCuntomSelectView];
}




@end

