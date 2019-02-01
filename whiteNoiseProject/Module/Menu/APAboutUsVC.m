//
//  APAboutViewController.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APAboutUsVC.h"

#import "UIImage+AppIcon.h"

#import "APWebVC.h"
#import "APFeedbackVC.h"
#import "APSQLiteManager+APTool.h"

@interface APAboutUsVC ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIButton *termsBtn;
@property (weak, nonatomic) IBOutlet UIButton *policyBtn;
@property (weak, nonatomic) IBOutlet UIButton *restoreBtn;
@property (weak, nonatomic) IBOutlet UIButton *feedbackBtn;

@end

@implementation APAboutUsVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"About", nil);
    
    self.iconImageView.layer.cornerRadius = 12;
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.image = [UIImage appIconImage];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app名称
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
//    // app build版本
//    NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];

    self.titleLabel.text = app_Name;
    self.versionLabel.text = [NSString stringWithFormat:@"v%@",app_Version];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (IBAction)buttonAction:(UIButton *)sender {
    switch (sender.tag) {
        case 0:{ // 用户反馈
            APFeedbackVC *feedbackVC = [[APFeedbackVC alloc] init];
            [self.navigationController pushViewController:feedbackVC animated:YES];
        } break;
            
        case 1:{ // 服务协议
            APWebVC *webVC = [[APWebVC alloc] init];
            webVC.contentType = WebViewContentTypeTerms;
            [self.navigationController pushViewController:webVC animated:YES];
        } break;
            
        case 2:{ // 隐私政策
            APWebVC *webVC = [[APWebVC alloc] init];
            webVC.contentType = WebViewContentTypePrivacy;
            [self.navigationController pushViewController:webVC animated:YES];
        } break;
    }
}




#pragma mark - 更新本地数据库信息
- (void)updateSQLdata:(NSDictionary *)receipt {
    NSArray *in_app = receipt[@"receipt"][@"in_app"];
    for (int i = 0; i < in_app.count; i++) {
        NSDictionary *dic = in_app[i];
        NSString *productID = dic[@"product_id"];
        [[APSQLiteManager shared] savePurchasedProduct:productID];
    }
}

@end
