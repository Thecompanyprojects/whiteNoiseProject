//
//  APTextAlertView.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APTextAlertView.h"

static CGFloat const kTextAlertViewTag      = 888001; // 弹窗
static CGFloat const kTextAlertBgViewTag    = 888002; // 背景

@interface APTextAlertView ()

@property (weak, nonatomic) IBOutlet UITextField        *textField;
@property (weak, nonatomic) IBOutlet UIButton           *confirmButton;
@property (weak, nonatomic) IBOutlet UIView             *lineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonHeight;

@property (nonatomic, copy) void (^complete)(NSString *text);

@end

@implementation APTextAlertView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.confirmButton.layer.cornerRadius = self.buttonHeight.constant / 2.0;
    self.confirmButton.layer.masksToBounds = YES;
    
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.colors = @[(__bridge id)[UIColor colorWithRed:250/255.0 green:107/255.0 blue:234/255.0 alpha:1].CGColor,
                  (__bridge id)[UIColor colorWithRed:162/255.0 green:105/255.0 blue:254/255.0 alpha:1].CGColor];
    gl.startPoint = CGPointMake(0, 0);
    gl.endPoint = CGPointMake(1, 0);
    gl.locations = @[@(0), @(1.0f)];
    gl.frame = self.confirmButton.bounds;
    [self.confirmButton.layer addSublayer:gl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)notifaction {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    APTextAlertView *alertView = [window viewWithTag:kTextAlertViewTag];
    CGFloat scale_w = [UIScreen mainScreen].bounds.size.width / 375.0;
    [UIView animateWithDuration:0.20 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        alertView.center = CGPointMake(window.center.x, window.center.y - 60 * scale_w);
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)keyboardWillHidden:(NSNotification *)notifaction {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    APTextAlertView *alertView = [window viewWithTag:kTextAlertViewTag];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        alertView.center = window.center;
    } completion:^(BOOL finished) {
        
    }];
}


- (IBAction)confirmButtonAction:(UIButton *)sender {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!CGPointEqualToPoint(window.center, self.center)) {
        [self endEditing:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self finishEdit];
        });
        return;
    }
    
    [self finishEdit];
}

- (void)finishEdit {
    if (self.textField.text.length <= 0) {
        [SVProgressHUD showInfoWithStatus:@"Please enter a custom sound name"];
        return;
    }
    if (self.complete) {
        self.complete(self.textField.text);
    }
    [self dismissTextView];
}

+ (void)bgViewTapAction:(UITapGestureRecognizer *)tap {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    APTextAlertView *alertView = [window viewWithTag:kTextAlertViewTag];
    
    // 有位置移动时拦截背景点击方法
    if (!CGPointEqualToPoint(window.center, alertView.center)) {
        return;
    }
    
    [alertView endEditing:YES];
    [alertView dismissTextView];
}

+ (void)showSaveAlertViewWithComplete:(void (^)(NSString *))complete {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if ([window viewWithTag:kTextAlertViewTag] || [window viewWithTag:kTextAlertBgViewTag]) {
        return;
    }
    
    APTextAlertView *alertView = [[NSBundle mainBundle] loadNibNamed:@"APTextAlertView" owner:nil options:nil].lastObject;
    alertView.tag = kTextAlertViewTag;
    alertView.complete = complete;
    CGFloat scale_w = [UIScreen mainScreen].bounds.size.width / 375.0;
    alertView.frame = CGRectMake(0, 0, 345 * scale_w, 180 * scale_w);
    alertView.center = window.center;
    alertView.alpha = 0;
    alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
    alertView.layer.cornerRadius = 5.0;
    alertView.layer.masksToBounds = YES;
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    bgView.alpha = 0;
    bgView.frame = window.bounds;
    bgView.tag = kTextAlertBgViewTag;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgViewTapAction:)];
    [bgView addGestureRecognizer:tap];
    
    [window addSubview:bgView];
    [window addSubview:alertView];
    
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        bgView.alpha = 1;
        alertView.alpha = 1;
        alertView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [alertView.textField becomeFirstResponder];
    }];
}

+ (void)dismissSaveAlertView {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    APTextAlertView *alertView = [window viewWithTag:kTextAlertViewTag];
    if (alertView) {
        [alertView confirmButtonAction:nil];
    }
}

- (void)dismissTextView {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *bgView = [window viewWithTag:kTextAlertBgViewTag];
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        bgView.alpha = 0;
        self.alpha = 0;
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
    } completion:^(BOOL finished) {
        [bgView removeFromSuperview];
        [self removeFromSuperview];
    }];
}




@end

