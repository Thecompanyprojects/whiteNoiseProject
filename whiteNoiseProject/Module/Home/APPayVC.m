//
//  APPayVC.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/25.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APPayVC.h"
#import <YYText.h>
#import <NSAttributedString+YYText.h>
#import <QuartzCore/QuartzCore.h>
#import <SafariServices/SafariServices.h>
#import <MessageUI/MessageUI.h>
#import <YGNetworkHelper.h>
#import "APNetworkHelper.h"
#import "APPayCell.h"

#import "APPayManager.h"

@interface APPayVC () <APPayManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) BOOL isSubscribed; /**< 是否已经订阅过 */

@property (nonatomic, strong) UIView        *navigationView;
@property (nonatomic, strong) UIButton      *backButton;
@property (nonatomic, strong) YYLabel       *navTitleLabel;
@property (nonatomic, strong) UIButton      *restoreButton;

@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, strong) UIView        *contentView;
@property (nonatomic, strong) UIImageView   *iconImageView;
@property (nonatomic, strong) YYLabel       *titleLabel;
@property (nonatomic, strong) YYLabel       *subTitleLabel_1;
@property (nonatomic, strong) YYLabel       *subTitleLabel_2;
@property (nonatomic, strong) YYLabel       *subTitleLabel_3;
@property (nonatomic, strong) UIImageView   *cardsImageView;
@property (nonatomic, strong) UIButton      *payButton;
@property (nonatomic, strong) UITableView   *tableView;

@property (nonatomic, strong) UIView        *infoContentView;
@property (nonatomic, strong) YYLabel       *priceLabel;
@property (nonatomic, strong) YYLabel       *infoTitleLabel;
@property (nonatomic, strong) YYLabel       *infoLabel;
@property (nonatomic, strong) UIButton      *termsOfServicesButton;
@property (nonatomic, strong) UIButton      *privacyPolicyButton;

@property (nonatomic, strong) NSArray <NSDictionary <NSString *, NSString *>*>*dataSource;

@end

@implementation APPayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.kTagString = @"premium";
    
    // 设置导航栏
    [self setupNavigationView];
    
    [self setupUI];
}

- (void)setupUI {
    [[APPayManager shareInstance] addPayTransactionObserver];
    
    // 设置View
    [self setupViews];
    
    // 检查订阅状态
    [[APPayManager shareInstance] checkSubscriptionStatusComplete:^(BOOL isVip) {
        self.isSubscribed = isVip;
//        self.restoreButton.hidden = isVip;
//        self.payButton.enabled = !isVip;
//        self.scrollView.hidden = NO;
        
        if (isVip) {
            [UIAlertController showAlertTitle:@"Subscribed" message:@"You are already a subscriber!" cancelTitle:nil otherTitle:@"Sure and Back" cancleBlock:^{
                
            } otherBlock:^{
                [[APPayManager shareInstance] removePayTransactionObserver];
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    }];
}


- (instancetype)initWithSubscribed:(BOOL)isSubscribed {
    self = [super init];
    if (self) {
        self.isSubscribed = isSubscribed;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[APPayManager shareInstance] removePayTransactionObserver];
    [SVProgressHUD dismiss];
}


#pragma mark - 返回
- (void)backButtonAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 恢复
- (void)restoreButtonAction:(UIButton *)sender {
    
    [[APLogTool shareManager] addLogKey1:@"premium" key2:@"restore" content:nil userInfo:nil upload:YES];
    
    [APPayManager shareInstance].delegate = self;
    [SVProgressHUD show];
    [[APPayManager shareInstance] refreshReceipt];
}

#pragma mark - 购买
- (void)payButtonAction:(UIButton *)sender {
    [[APLogTool shareManager] addLogKey1:@"premium" key2:@"button" content:nil userInfo:nil upload:NO];
    
    NSString *productID = [self getConfigInfo][@"subscribe_payment_id"];
    
    [self startPayWithPaymentID:productID];
}

- (void)startPayWithPaymentID:(NSString *)paymentID {
    [APPayManager shareInstance].delegate = self;
    [SVProgressHUD show];
    [[APPayManager shareInstance] paymentWithProductID:paymentID];
}


#pragma mark - XYPaymentManageDelegate
- (void)paymentTransactionSucceedType:(XYPaymentStatus)SucceedType {
    self.payButton.enabled = NO;
    self.restoreButton.hidden = YES;
    [self showWithState:SucceedType isSuccess:YES];
    
    [[APPayManager shareInstance] checkSubscriptionStatusComplete:^(BOOL isVip) {
        
    }];
}

- (void)paymentTransactionFailureType:(XYPaymentStatus)failtype {
    [self showWithState:failtype isSuccess:NO];
}


#pragma mark - 服务条款
- (void)termsOfServicesButtonAction:(UIButton *)sender {
    NSString *terms_of_services = [self getConfigInfo][@"terms_of_services"];
    SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:terms_of_services]];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - 隐私政策
- (void)privacyPolicyButtonAction:(UIButton *)sender {
    NSString *privacy_policy = [self getConfigInfo][@"privacy_policy"];
    SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:privacy_policy]];
    [self presentViewController:controller animated:YES completion:nil];
}



#pragma mark - 设置UI
- (void)setupNavigationView {
    self.navigationView = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        view;
    });
    [self.view addSubview:self.navigationView];
    [self.navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(kNavBarHeight);
    }];
    
    self.backButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"payment_close"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.navigationView addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(44, 44));
        make.left.mas_equalTo(10);
        make.bottom.mas_equalTo(0);
    }];
    
    self.restoreButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        button.hidden = YES;
        NSNumber *alpha = [self getConfigInfo][@"restore_btn_alpha"];
        UIColor *color = [UIColor colorWithHexString:[self getConfigInfo][@"restore_btn_color"]];
        [button setTitle:[self getConfigInfo][@"restore_btn_title"] forState:UIControlStateNormal];
        [button setTitleColor:color forState:UIControlStateNormal];
        button.alpha = alpha.doubleValue;
        button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.numberOfLines = 2;
        [button addTarget:self action:@selector(restoreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.navigationView addSubview:self.restoreButton];
    [self.restoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(44);
        make.right.mas_equalTo(-15);
    }];
    
}

#pragma mark - 设置UI
- (void)setupViews {
    self.scrollView = ({
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.backgroundColor = [UIColor whiteColor];
//        scrollView.hidden = YES;
        scrollView;
    });
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(kNavBarHeight, 0, 0, 0));
    }];
    
    self.contentView = ({
        UIView *view = [[UIView alloc] init];
        view;
    });
    [self.scrollView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.scrollView);
        make.width.mas_equalTo(self.scrollView);
    }];
    
    self.iconImageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:@"huiyuan zuanshi"];
        imageView;
    });
    [self.contentView addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(109, 96));
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(0);
    }];
    
    self.titleLabel = ({
        YYLabel *label = [[YYLabel alloc] init];
        label.numberOfLines = 0;
        label.text = [self getConfigInfo][@"title"];
        NSNumber *font = [self getConfigInfo][@"title_font"];
        label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:font.integerValue];
        UIColor *color = [UIColor colorWithHexString:[self getConfigInfo][@"title_color"]];
        label.textColor = color;
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(15);
        make.width.mas_equalTo(self.contentView.mas_width).offset(-80);
    }];
    
    self.subTitleLabel_1 = ({
        YYLabel *label = [[YYLabel alloc] init];
        label.attributedText = [self subTitleAttributedText:[self getConfigInfo][@"sub_title1"]];
        label;
    });
    [self.contentView addSubview:self.subTitleLabel_1];
    [self.subTitleLabel_1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(KScreenWidth * 0.2);
        make.width.mas_equalTo(self.contentView).multipliedBy(0.8);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(30);
    }];
    
    self.subTitleLabel_2 = ({
        YYLabel *label = [[YYLabel alloc] init];
        label.attributedText = [self subTitleAttributedText:[self getConfigInfo][@"sub_title2"]];
        label;
    });
    [self.contentView addSubview:self.subTitleLabel_2];
    [self.subTitleLabel_2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(KScreenWidth * 0.2);
        make.width.mas_equalTo(self.contentView).multipliedBy(0.8);
        make.top.mas_equalTo(self.subTitleLabel_1.mas_bottom).offset(15);
    }];
    
    self.subTitleLabel_3 = ({
        YYLabel *label = [[YYLabel alloc] init];
        label.attributedText = [self subTitleAttributedText:[self getConfigInfo][@"sub_title3"]];
        label;
    });
    [self.contentView addSubview:self.subTitleLabel_3];
    [self.subTitleLabel_3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(KScreenWidth * 0.2);
        make.width.mas_equalTo(self.contentView).multipliedBy(0.8);
        make.top.mas_equalTo(self.subTitleLabel_2.mas_bottom).offset(15);
    }];
    
    
    self.cardsImageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [self cardsImage];
        imageView;
    });
    [self.contentView addSubview:self.cardsImageView];
    [self.cardsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.self.subTitleLabel_3.mas_bottom).offset(30);
        make.height.mas_equalTo(((KScreenWidth - 20 * 2 - 3 * 7) / 4.0) * 2 + 1 * 7);
    }];
    
//    self.payButton = ({
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        NSNumber *font = [self getConfigInfo][@"pay_btn_text_font"];
//        button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:font.integerValue];
//        [button setTitle:[self getConfigInfo][@"pay_btn_text_notvip"] forState:UIControlStateNormal];
//        [button setTitle:[self getConfigInfo][@"pay_btn_text_vip"] forState:UIControlStateDisabled];
//        [button setTitleColor:[UIColor colorWithHexString:[self getConfigInfo][@"pay_btn_text_color"]] forState:UIControlStateNormal];
//        NSNumber *alpha = [self getConfigInfo][@"pay_btn_text_alpha"];
//        button.alpha = alpha.doubleValue;
//        button.titleLabel.numberOfLines = 0;
//        [button setBackgroundImage:[UIImage imageNamed:@"anniu"] forState:UIControlStateNormal];
//        [button addTarget:self action:@selector(payButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//        button.adjustsImageWhenDisabled = NO;
//        button.titleLabel.textAlignment = NSTextAlignmentCenter;
//        button;
//    });
//    self.payButton.enabled = !self.isSubscribed;
//    [self.contentView addSubview:self.payButton];
//    [self.payButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(345*KWIDTH, 65*KWIDTH));
//        make.top.mas_equalTo(self.cardsImageView.mas_bottom).offset(30);
//        make.centerX.mas_equalTo(0);
//    }];
    
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.bounces = NO;
        tableView.scrollEnabled = NO;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.showsHorizontalScrollIndicator = NO;
        tableView.separatorColor = [UIColor groupTableViewBackgroundColor];
        tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
        tableView.rowHeight = 60;
        tableView.estimatedRowHeight = 60;
        tableView.tableFooterView = [UIView new];
        tableView;
    });
    
    [self.contentView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(-0);
        make.top.mas_equalTo(self.cardsImageView.mas_bottom).offset(20);
        make.height.mas_equalTo(self.dataSource.count * 60 + 4);
    }];
    
    
    self.infoContentView = ({
        UIView *view = [[UIView alloc] init];
        NSNumber *hidden = [self getConfigInfo][@"instructions_alpha"];
        view.alpha = hidden.doubleValue;
        view;
    });
    [self.contentView addSubview:self.infoContentView];
    [self.infoContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.tableView.mas_bottom).offset(0);
    }];
    
//    self.priceLabel = ({
//        YYLabel *label = [[YYLabel alloc] init];
//        label.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
//        label.textColor = [UIColor colorWithHexString:[self getConfigInfo][@"subscribed_price_color"]];
//        NSNumber *alpha = [self getConfigInfo][@"subscribed_price_alpha"];
//        label.alpha = alpha.doubleValue;
//        label.text = [self getConfigInfo][@"subscribed_price"];
//        label.textAlignment = NSTextAlignmentCenter;
//        label;
//    });
//    [self.infoContentView addSubview:self.priceLabel];
//    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(20);
//        make.top.mas_equalTo(0);
//        make.width.mas_equalTo(KScreenWidth - 40);
//    }];
    
    self.infoLabel = ({
        YYLabel *label = [[YYLabel alloc] init];
        label.numberOfLines = 0;
        label.userInteractionEnabled = YES;
        label.attributedText = [self infoString];
        NSNumber *alpha = [self getConfigInfo][@"instructions_alpha"];
        label.alpha = alpha.doubleValue;
        label;
    });
    [self.infoContentView addSubview:self.infoLabel];
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(KScreenWidth - 40, MAXFLOAT) text:self.infoLabel.attributedText];
    CGFloat infoHeight = layout.textBoundingSize.height;
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(20);
        make.width.mas_equalTo(KScreenWidth - 40);
        make.height.mas_equalTo(infoHeight);
    }];
    
    self.termsOfServicesButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setAttributedTitle:[self urlButtonAttributedTextWithText:[self getConfigInfo][@"terms_of_services_title"]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(termsOfServicesButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.infoContentView addSubview:self.termsOfServicesButton];
    [self.termsOfServicesButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.infoLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(self.infoContentView.mas_width).multipliedBy(0.5);
        make.bottom.mas_equalTo(self.infoContentView).offset(0);
    }];
    
    self.privacyPolicyButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setAttributedTitle:[self urlButtonAttributedTextWithText:[self getConfigInfo][@"privacy_policy_title"]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(privacyPolicyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.infoContentView addSubview:self.privacyPolicyButton];
    [self.privacyPolicyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-30);
        make.width.mas_equalTo(self.infoContentView.mas_width).multipliedBy(0.5);
        make.top.bottom.mas_equalTo(self.termsOfServicesButton);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.infoContentView.mas_bottom).offset(isIPhoneX?54:20);
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor whiteColor];
    v.frame = CGRectMake(0, 0, KScreenWidth, 0.5);
    UIView *sv = [[UIView alloc] init];
    sv.backgroundColor = [UIColor groupTableViewBackgroundColor];
    sv.frame = CGRectMake(20, 0, KScreenWidth - 40, 0.5);
    [v addSubview:sv];
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor whiteColor];
    v.frame = CGRectMake(0, 0, KScreenWidth, 0.5);
    UIView *sv = [[UIView alloc] init];
    sv.backgroundColor = [UIColor groupTableViewBackgroundColor];
    sv.frame = CGRectMake(20, 0, KScreenWidth - 40, 0.5);
    [v addSubview:sv];
    return v;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseId = @"APPayCell";
    APPayCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell = [[APPayCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseId];
    }
    
    cell.textLabel.text = self.dataSource[indexPath.row][@"title"];
    cell.detailTextLabel.text = self.dataSource[indexPath.row][@"sub_title"];
    cell.buttonTitle = self.dataSource[indexPath.row][@"btn_title"];
    cell.payAction = ^{
        [self startPayWithPaymentID:self.dataSource[indexPath.row][@"pay_id"]];
    };
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark - 获取富文本文字
- (NSMutableAttributedString *)urlButtonAttributedTextWithText:(NSString *)text {
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(text, nil)];
    attText.yy_font = [UIFont fontWithName:@"PingFangSC-Light" size:10];
    UIColor *color =  [UIColor colorWithHexString:[self getConfigInfo][@"instructions_color"]];
    attText.yy_color = color;
    attText.yy_underlineStyle = NSUnderlineStyleSingle;
    attText.yy_underlineColor = color;
    attText.yy_alignment = NSTextAlignmentCenter;
    return attText;
}


- (NSMutableAttributedString *)titleAttributedText {
    NSString *title = [NSString stringWithFormat:@"%@",[self getConfigInfo][@"title"]];
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(title, nil)];
    attText.yy_font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    UIColor *color = [UIColor colorWithHexString:[self getConfigInfo][@"title_color"]];
    attText.yy_color = color;
    attText.yy_alignment = NSTextAlignmentCenter;
    attText.yy_lineSpacing = 15.0;
    return attText;
}

- (NSMutableAttributedString *)subTitleAttributedText:(NSString *)text {
    UIImage *image = [UIImage imageNamed:@"check"];
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    UIColor *color = [UIColor colorWithHexString:[self getConfigInfo][@"sub_title_color"]];
    NSMutableAttributedString *attachment = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:CGSizeMake(30, 20) alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:text];
    attText.yy_font = font;
    attText.yy_color = color;
    [attText insertAttributedString:attachment atIndex:0];
    attText.yy_alignment = NSTextAlignmentLeft;
    return attText;
}


- (NSMutableAttributedString *)infoString {
    NSString *text = [self getConfigInfo][@"instructions_text"]?:@"";
    NSMutableAttributedString *attStrM = [[NSMutableAttributedString alloc] initWithString:text];
    attStrM.yy_font = [UIFont fontWithName:@"PingFangSC-Light" size:10];
    UIColor *color =  [UIColor colorWithHexString:[self getConfigInfo][@"instructions_color"]];
    attStrM.yy_color = color;
    attStrM.yy_alignment = NSTextAlignmentLeft;
    return attStrM;
}


- (NSDictionary *)getConfigInfo {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"pay_config" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    self.dataSource = dict[@"subscribe"][@"subscribe_ids"];
    
    return dict[@"subscribe"];
}


#pragma mark - 绘制卡片图片
- (UIImage *)cardsImage {
    NSArray *cardImageNameArray = @[@"ocean card",
                                    @"fire card",
                                    @"wind card",
                                    @"night card" ,
                                    @"waterfall card",
                                    @"rain card",
                                    @"bell card",
                                    @"lake card"];
    
    NSArray *cardTitleNameArray = @[NSLocalizedString(@"Ocean", nil),
                                    NSLocalizedString(@"Fire", nil),
                                    NSLocalizedString(@"Wind", nil),
                                    NSLocalizedString(@"Night", nil),
                                    NSLocalizedString(@"Waterfall", nil),
                                    NSLocalizedString(@"Rain", nil),
                                    NSLocalizedString(@"Bell", nil),
                                    NSLocalizedString(@"Lake", nil)];
    
    CGFloat cardWidth = (KScreenWidth - 20 * 2 - 3 * 7) / 4.0;
    CGSize cardImageSize = CGSizeMake(cardWidth * 4 + 3 * 7, cardWidth * 2 + 1 * 7);
    
    // 设置当前上下文中绘制的区域
    UIGraphicsBeginImageContextWithOptions(cardImageSize,NO,0);
    for (NSInteger i = 0; i < cardImageNameArray.count; i++) {
        // 绘制范围
        CGRect drawRect = CGRectMake((cardWidth + 7) * (i % 4),
                                     (i / 4) * (cardWidth + 7),
                                     cardWidth,
                                     cardWidth);
        // 绘制图片
        UIImage *image = [UIImage imageNamed:cardImageNameArray[i]];
        [image drawInRect:drawRect blendMode:kCGBlendModeNormal alpha:1.0];
        // 绘制文字
        UIFont *font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        NSString *text = cardTitleNameArray[i];
        CGRect textRect = CGRectMake(drawRect.origin.x,
                                     (cardWidth - font.lineHeight)/2.0 + (cardWidth + 7) * (i / 4),
                                     cardWidth,
                                     font.lineHeight);
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentCenter;
        style.minimumLineHeight = font.lineHeight;
        style.maximumLineHeight = font.lineHeight;
        NSDictionary *att = @{
                              NSFontAttributeName:font,
                              NSForegroundColorAttributeName:[UIColor whiteColor],
                              NSParagraphStyleAttributeName:style
                              };
        [text drawInRect:textRect withAttributes:att];
        
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)showWithState:(XYPaymentStatus)state isSuccess:(BOOL)success {
    
    NSString *logString = @"";
    switch (state) {
        case payment_succeed_status:{
            logString = NSLocalizedString(@"Payment success",nil);
        } break;
        case verify_timeout_status:{
            logString = NSLocalizedString(@"Verification timeout",nil);
        } break;
        case verify_fail_status:{
            logString = NSLocalizedString(@"Verification failed",nil);
        } break;
        case payment_fail_status:{
            logString = NSLocalizedString(@"Payment timeout",nil);
        } break;
        case no_product_status:{
            logString = NSLocalizedString(@"Unavailable",nil);
        } break;
        case bought_status:{
            logString = NSLocalizedString(@"Purchased",nil);
        } break;
        case Transaction_fail_status:{
            logString = NSLocalizedString(@"Payment failed",nil);
        } break;
        case vip_Expires_status:{
            logString = NSLocalizedString(@"Subscription has expired",nil);
        } break;
        case app_store_connect_fail_status:{
            logString = NSLocalizedString(@"iTunes Store connect failed",nil);
        } break;
        case not_allowed_pay_status:{
            logString = NSLocalizedString(@"No purchase allowed",nil);
        } break;
        case user_cancel:{
            logString = NSLocalizedString(@"Purchase cancelled",nil);
        } break;
        default:
            break;
    }
    
    
    if (success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kPaymentSuccessNotifactionName" object:nil];
        
        [SVProgressHUD dismiss];
        [[APLogTool shareManager] addLogKey1:@"premium" key2:@"success" content:@{@"state":logString} userInfo:nil upload:YES];
        [UIAlertController showAlertTitle:@"Subscription success!" message:nil cancelTitle:nil otherTitle:@"Sure and Back" cancleBlock:^{
            
        } otherBlock:^{
            [[APPayManager shareInstance] removePayTransactionObserver];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
//        [SVProgressHUD showSuccessWithStatus:logString];
    } else {
        [SVProgressHUD showErrorWithStatus:logString];
        [[APLogTool shareManager] addLogKey1:@"premium" key2:@"failed" content:@{@"state":logString} userInfo:nil upload:YES];
    }
    
}

#pragma mark - MFMailComposeViewControllerDelegate的代理方法：
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result) {
        case MFMailComposeResultCancelled:
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Send cancelled", nil)];
            break;
        case MFMailComposeResultSaved:
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Save success", nil)];
            break;
        case MFMailComposeResultSent:
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Send success", nil)];
            break;
        case MFMailComposeResultFailed:
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Send failed", nil)];
            break;
    }
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [controller dismissViewControllerAnimated:YES completion:nil];
}




@end
