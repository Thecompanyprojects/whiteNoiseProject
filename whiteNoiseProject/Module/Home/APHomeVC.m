//
//  APHomeViewController.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APHomeVC.h"
#import "APPayManager.h"
#import "APPayVC.h"

#import "APLoadingHUD.h"
#import "APSoundListVC.h"
#import "APCustomListVC.h"
#import "APHomeCorrugationView.h"
#import "APTranstionPushAnimation.h"
#import "APNoiseManager.h"
#import "APSQLiteManager.h"
#import "APNetworkHelper.h"
#import "APAudioPlayerTools.h"
#import "APDataHelper.h"
#import "APAboutUsVC.h"
#import "APSoundPlayerVC.h"

#import "APCuntomTool.h"

#import "APWebVC.h"

NSString * HomeCellReuseIdentifier = @"HomeCellReuseIdentifier";

@interface APHomeVC () <UINavigationControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UIButton *vipButtonItem;
@property (nonatomic, strong) UIButton *leftBtn;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray <APClassModel *>* classModelArr;
@end

@implementation APHomeVC

- (instancetype)init {
    self = [super init];
    if (self) {
        __weak typeof(self)weakSelf = self;
        self.selectBlock_tabbar = ^(NSDictionary *info){
            [weakSelf handleMenuViewAction:info];
        };
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewUI];
    
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.navigationController.navigationBar layoutSubviews];
    
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    self.title = app_Name;
    
    self.classModelArr = [[APSQLiteManager shared] getClassesModels];
    
    [self.collectionView reloadData];
    
    [APNetworkHelper xt_postRequestWithType:XTNetworkRequestTypeClasses parameters:nil response:^(NSDictionary *dict) {
        [[APSQLiteManager shared]saveClassesInfo:dict];
    } error:^(NSError *error) {
        NSLog(@"获取目录列表请求错误，%@",error);
    }];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.baseImgV beginAnimation];
    
    // 侧滑手势开启
    self.mm_drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    
    [[APPayManager shareInstance] checkSubscriptionStatusComplete:^(BOOL isVip) {
        self.vipButtonItem.hidden = isVip;
        self.vipButtonItem.userInteractionEnabled = !isVip;
    }];
    
    APBaseNavVC *nav = (APBaseNavVC *)self.navigationController;
    [nav ap_whiteTitleStyle];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.baseImgV stopAnimation];
    
    // 侧滑手势关闭
    self.mm_drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeNone;
    
    APBaseNavVC *nav = (APBaseNavVC *)self.navigationController;
    [nav ap_blackTitleStyle];
}

- (void)shardToFriends {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];

    //分享的标题
    NSString *textToShare = app_Name;
    //分享的图片
    UIImage *imageToShare = [UIImage imageNamed:@"icon"];
    //分享的url
    NSString * url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", kAppStoreID];
    NSURL *urlToShare = [NSURL URLWithString:url];
    //在这里呢 如果想分享图片 就把图片添加进去  文字什么的通上
    NSArray *activityItems = @[textToShare,imageToShare, urlToShare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    //不出现在活动项目
    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll,UIActivityTypeMessage];
    [self presentViewController:activityVC animated:YES completion:nil];
    // 分享之后的回调
    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        if (completed) {
            NSLog(@"share completed");
            //分享 成功
        } else {
            NSLog(@"share is cancled");
            //分享 取消
        }
    };
}

- (void)handleMenuViewAction:(NSDictionary *)info {
    // 开/关侧边栏
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    
    NSString* className = info[@"className"];
    Class class = NSClassFromString(className);
    UIViewController *vc = [[class alloc]init];
    if (!vc){
        NSString *title = info[@"value"];
        if([title isEqualToString:@"1"]){//评分
            NSString * url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review", @"1421723111"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }else if([title isEqualToString:@"2"]){//分享给朋友
            [self shardToFriends];
        }else if([title isEqualToString:@"3"]){ //点击了购买
            NSLog(@"点击了购买");
            [[APLogTool shareManager] addLogKey1:@"premium" key2:@"show" content:@{@"type":@"click"} userInfo:nil upload:YES];
            APPayVC *vc = [[APPayVC alloc]init];
            [self presentViewController:vc animated:YES completion:nil];
            
        }
        return;
    }
    
    if ([vc isKindOfClass:APWebVC.class]){
        NSString* value = info[@"value"]?info[@"value"]:@"";
        APWebVC *webvc = (APWebVC *)vc;
        if ([value isEqualToString:@"WebViewContentTypeTerms"]){
            webvc.contentType = WebViewContentTypeTerms;
        }else{
            webvc.contentType = WebViewContentTypePrivacy;
        }
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showMenuViewController{
    [[APLogTool shareManager] addLogKey1:@"mian" key2:@"sidebar" content:@{@"action":@"home_nav_btn_click", @"state":@"open"} userInfo:nil upload:NO];
    
    // 开/关侧边栏
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - vipButtonAction
- (void)vipButtonAction:(UIButton *)sender {
    
    [[APLogTool shareManager] addLogKey1:@"premium" key2:@"premium" content:nil userInfo:nil upload:YES];
    
    APPayVC *vipPaymentVC = [[APPayVC alloc] init];
    [self presentViewController:vipPaymentVC animated:YES completion:nil];
}


//btm85 L45 W110

#define roundW (110*KWIDTH)
#define roundL (45*KWIDTH)
#define roundB (85*KWIDTH)

- (void)setupViewUI{
    self.backgroundImage = [APNoiseManager shareInstance].homeBgImg;
    [self.view addSubview:self.collectionView];
    [self setupNavigationBarMenuButton];
}

- (void)setupNavigationBarMenuButton {
    
    self.vipButtonItem = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"huiyuan icon"] forState:UIControlStateNormal];
        btn.frame = CGRectMake(10, 10, 48, 48);//CGRectMake(KScreenWidth - 44 - 20, kNavBarHeight + 10, 44, 44);
        [btn addTarget:self action:@selector(vipButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:self.vipButtonItem];
    self.navigationItem.rightBarButtonItem = btnItem;
    
    self.leftBtn = ({
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.frame = CGRectMake(0, 10, 50, 50);
        [leftBtn setImage:[UIImage imageNamed:@"menu_icon"] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(showMenuViewController) forControlEvents:UIControlEventTouchUpInside];
        leftBtn;
    });
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.leftBtn];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}



- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    
    if (operation == UINavigationControllerOperationPush) {
        return [APTranstionPushAnimation new];
    }else{
        return nil;
    }
}
//MARK:- collectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.classModelArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    APHomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:HomeCellReuseIdentifier forIndexPath:indexPath];
    cell.model = self.classModelArr[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    APClassModel *model = self.classModelArr[indexPath.row];
    
    [[APLogTool shareManager] addLogKey1:@"main" key2:@"click" content:@{@"classify":model.className_en} userInfo:nil upload:NO];
    
    
    if (model.classId == 7) { // 自定义音效类
        APCustomListVC *listVc = [[APCustomListVC alloc] init];
        [self.navigationController pushViewController:listVc animated:YES];
        
//        if ([[APCuntomTool sharedCuntomTool] getCuntomDataArray].count > 0) {
//            // 本地已经有自定义音效
//            APCustomListVC *listVc = [[APCustomListVC alloc] init];
//            [self.navigationController pushViewController:listVc animated:YES];
//
//        } else {
//
//            @weakify(self);
//            [[APCuntomTool sharedCuntomTool] getSoundClassData:^(NSArray<APSoundClassModel *> *soundClassDataArray, NSArray<APSoundModel *> *defaultDataArray) {
//                @strongify(self);
//                if (soundClassDataArray.count <= 0) {
//                    [SVProgressHUD showErrorWithStatus:@"Network error, please try again later"];
//                    [[APCuntomTool sharedCuntomTool] requestData];
//                    return;
//                }
//                APCustomModel *customModel = [APCustomModel new];
//                customModel.isSaved = NO;
//                customModel.sounds = [NSMutableArray arrayWithArray:defaultDataArray];
//                customModel.icon_name = @"默认图_Normal";
//                customModel.icon_bg_name = @"首页背景图模糊";
//
//                APSoundPlayerVC *player = [[APSoundPlayerVC alloc] initWithSoundClassDataArray:soundClassDataArray cuntormDataModel:customModel isSelect:YES];
//                [self.navigationController pushViewController:player animated:YES];
//            }];
//        }
        
    } else {
        [self.navigationController pushViewController:[[APSoundListVC alloc] initWithType:model] animated:YES];
    }
    
}

//MARK:- lazy
- (UICollectionView *)collectionView{
    if (!_collectionView){
        _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:[APHomeFlowLayout new]];
        [_collectionView registerNib:[UINib nibWithNibName:@"APHomeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:HomeCellReuseIdentifier];
        
        _collectionView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}

- (NSArray<APClassModel *> *)classModelArr{
    if (!_classModelArr){
        _classModelArr = [NSArray array];
    }
    return _classModelArr;
}

@end
