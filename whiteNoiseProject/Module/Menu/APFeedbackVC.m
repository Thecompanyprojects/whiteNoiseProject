//
//  APFeedbackViewController.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APFeedbackVC.h"
#import "APFeedbackEmailTextFiled.h"
#import "UITextView+Placeholder.h"
#import "UIView+YGNib.h"
#import "NSData+Blowfish.h"
#import "APNetworkHelper.h"

@interface APFeedbackVC ()<UINavigationControllerDelegate, UITextViewDelegate>

@property (nonatomic, strong) UIScrollView *containerView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *submitBtn;
@property (nonatomic, strong) APFeedbackEmailTextFiled *emailFillView;
@property (nonatomic, strong) NSMutableArray <UIImage *>*imageArrayM;

@end

@implementation APFeedbackVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSMutableArray <UIImage *>*)imageArrayM {
    if (!_imageArrayM) {
        _imageArrayM = [NSMutableArray array];
    }
    return _imageArrayM;
}

#pragma mark - 提交反馈
- (void)submitBtnAction:(UIButton *)sender {
    
    if (self.textView.text.length <= 0) {
        [SVProgressHUD showInfoWithStatus:@"Oh, oh, you haven't entered anything yet"];
        return;
    }
    
    [SVProgressHUD show];
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    [dictM setObject:self.textView.text forKey:@"content"];
    if (self.emailFillView.email.length > 0) {
        [dictM setObject:self.emailFillView.email forKey:@"email"];
    }
    
    [APNetworkHelper xt_postRequestWithType:XTNetworkRequestTypeFeedBack parameters:dictM response:^(NSDictionary *dict) {
        if ([dict[@"code"] integerValue] == 1) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Thanks for your feedback, we will continue to improve", nil)];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        } else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error!", nil)];
        }
        
    } error:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

#pragma mark - 设置UI
- (void)setupView {
    self.title = NSLocalizedString(@"Feedback", nil);
    
    UIView *navView = [[UIView alloc] init];
    navView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navView];
    [navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(kNavBarHeight);
    }];
    
    self.submitBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundColor:[UIColor clearColor]];
        btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:18];
        [btn setTitle:NSLocalizedString(@"Send", nil) forState:UIControlStateNormal];
        [btn setTitleColor:kHexColor(0x000000) forState:UIControlStateNormal];
        [btn setTitleColor:kHexColor(0xeeeeee) forState:UIControlStateDisabled];
        [btn addTarget:self action:@selector(submitBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.submitBtn];
    
    
    self.containerView = ({
        UIScrollView *scView = [[UIScrollView alloc] init];
        scView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        scView;
    });
    [self.view addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.view);
        make.top.mas_equalTo(navView.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    UIView *textContentView = ({
        UIView *v = [[UIView alloc] init];
        v.backgroundColor = [UIColor whiteColor];
        v;
    });
    [self.containerView addSubview:textContentView];
    [textContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(1);
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(200);
    }];
    
    self.textView = ({
        UITextView *textView = [[UITextView alloc] init];
        textView.delegate = self;
        textView.yg_placeholderLabel.text = NSLocalizedString(@"Enter your comments or suggestions...", nil);
        textView.yg_placeholderLabel.textColor = kHexColor(0x999999);
        textView.textColor = kHexColor(0x333333);
        textView.font = [UIFont fontWithName:@"PingFangSC-Light" size:15];
        textView;
    });
    [textContentView addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(10);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(-15);
    }];
    
    
    self.emailFillView = ({
        APFeedbackEmailTextFiled *view = [APFeedbackEmailTextFiled yg_loadViewFromNib];
        view.backgroundColor = [UIColor whiteColor];
        view;
    });
    
    [self.containerView addSubview:self.emailFillView];
    [self.emailFillView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(self.view);
        make.top.mas_equalTo(textContentView.mas_bottom).offset(5);
        make.height.mas_equalTo(50);
    }];
    
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSMutableString *textString = [[NSMutableString alloc] initWithString:textView.text];
    [textString stringByReplacingCharactersInRange:range withString:text];
    return textString.length <= 300;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"内容:%@", textView.text);
    
}


@end
