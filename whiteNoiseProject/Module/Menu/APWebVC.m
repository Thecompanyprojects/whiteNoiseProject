//
//  APWebViewController.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APWebVC.h"

@interface APWebVC () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation APWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.webView];
    
    UIView *navView = [[UIView alloc] init];
    navView.backgroundColor = [UIColor whiteColor];
    navView.frame = CGRectMake(0, 0, KScreenWidth, kNavBarHeight);
    [self.view addSubview:navView];
    
    NSString *str = @"";
    if (_contentType == WebViewContentTypePrivacy) {
        str = kPrivacyHtml;
        self.title = NSLocalizedString(@"Privacy Policy", nil);
        
    } else if (_contentType == WebViewContentTypeTerms) {
        str = kTermHtml;
        self.title = NSLocalizedString(@"Terms of Service", nil);
    }
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [SVProgressHUD show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
    });
}


@end
