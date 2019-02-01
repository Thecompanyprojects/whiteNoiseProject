//
//  APMenuViewController.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#define ROWHEIGHT (50*KHEIGHT)

#import "APMenuVC.h"

#import "APMenuCell.h"

#import "APFeedbackVC.h"
#import "APAboutUsVC.h"
#import "APWebVC.h"
#import "APPayManager.h"

@interface APMenuVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong)LeftAppPurchaseView *appPurchaseView;
@end

@implementation APMenuVC

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left_bg_"]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = CGRectMake(0, 0, 230*KWIDTH, KScreenHeight);
    [self.view addSubview:imageView];
    
    UIView *maskView = [UIView new];
    maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    maskView.frame = imageView.bounds;
    [self.view addSubview:maskView];
    
    
    /*
     @{@"className":@"nil",//评分
     @"image":@"rute us",
     @"title":@"Rate Us",
     @"value":@"1"},
     */
    self.dataSource = @[
                        
                        @{@"className":@"nil",//分享给朋友
                          @"image":@"share",
                          @"title":@"Share to Friends",
                          @"value":@"2"},
                        @{@"className":NSStringFromClass(APFeedbackVC.class),//意见反馈
                          @"image":@"cebian yijian icon",
                          @"title":@"Feedback" ,
                          @"value":@""},
                        @{@"className":NSStringFromClass(APAboutUsVC.class),//关于
                          @"image":@"cebian guanyu icon",
                          @"title":@"About",
                          @"value":@""},
                        ];
    
    [self.view addSubview:self.tableView];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker* make){
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY);
        make.height.mas_equalTo(ROWHEIGHT*self.dataSource.count);
        make.width.mas_equalTo(KScreenWidth*0.61);
    }];
    
    [self.view addSubview:self.appPurchaseView];
    
    __weak typeof(self)weakself = self;

    [self.appPurchaseView setClickPayBtn:^{
        NSDictionary *dic = @{@"className":@"nil",
                              @"image":@"",
                              @"title":@"pay",
                              @"value":@"3"};
        weakself.selectBlock(dic);
        [[APLogTool shareManager] addLogKey1:@"left" key2:@"premium" content:nil userInfo:nil upload:YES];
    }];
    self.appPurchaseView.frame = CGRectMake(1, 1, self.view.xy_width, 0);
    [self.appPurchaseView setHidden:true];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker* make){
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY);
        make.height.mas_equalTo(ROWHEIGHT*self.dataSource.count);
        make.width.mas_equalTo(KScreenWidth*0.61);
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker* make){
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY);
        make.height.mas_equalTo(ROWHEIGHT*self.dataSource.count);
        make.width.mas_equalTo(KScreenWidth*0.61);
    }];
    
    [[APPayManager shareInstance] checkSubscriptionStatusComplete:^(BOOL isVip) {
        if (isVip){ //如果是vip
            self.appPurchaseView.frame = CGRectMake(1, 1, self.view.xy_width, 0);
            [self.appPurchaseView setHidden:true];
            [self.tableView mas_remakeConstraints:^(MASConstraintMaker* make){
                make.centerX.mas_equalTo(self.view.mas_centerX);
                make.centerY.mas_equalTo(self.view.mas_centerY);
                make.height.mas_equalTo(ROWHEIGHT*self.dataSource.count);
                make.width.mas_equalTo(KScreenWidth*0.61);
            }];
        }else{//如果不是vip
            
            if (KWIDTH < 375){
                self.appPurchaseView.frame = CGRectMake(0, 50, self.view.xy_width, 320);
            }else{
                self.appPurchaseView.frame = CGRectMake(0, 100*KHEIGHT, self.view.xy_width, 320);
            }
            
            [self.appPurchaseView setHidden:false];
            [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.view.mas_bottom).offset(-50*KHEIGHT);
                
                make.centerX.mas_equalTo(self.view.mas_centerX);
                make.height.mas_equalTo(ROWHEIGHT*self.dataSource.count);
                make.width.mas_equalTo(KScreenWidth*0.61);
            }];
        }
    }];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView dequeueReusableCellWithIdentifier:@"APMenuCell"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ROWHEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.selectBlock){
        self.selectBlock(self.dataSource[indexPath.row]);
        [[APLogTool shareManager] addLogKey1:@"left" key2:self.dataSource[indexPath.row] content:nil userInfo:nil upload:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    APMenuCell* tcell = (APMenuCell *)cell;
    tcell.iconImageView.image = [UIImage imageNamed:self.dataSource[indexPath.row][@"image"]];
    
    NSString *title = self.dataSource[indexPath.row][@"title"];
    
    tcell.titleLabel.text = NSLocalizedString(title, nil);
}

- (CGSize)preferredContentSize{
    return CGSizeMake(KScreenWidth*0.61, KScreenHeight);
}

//MARK:- lazy
- (UITableView *)tableView{
    if (!_tableView){
        _tableView = [UITableView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor =[UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        [_tableView registerNib:[UINib nibWithNibName:@"APMenuCell" bundle:nil] forCellReuseIdentifier:@"APMenuCell"];
    }
    return _tableView;
}

- (LeftAppPurchaseView *)appPurchaseView{
    if (!_appPurchaseView){
        _appPurchaseView = [LeftAppPurchaseView appPurchaseView];
    }
    return _appPurchaseView;
}

@end
