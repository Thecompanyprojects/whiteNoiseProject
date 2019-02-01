//
//  APSoundListViewController.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APSoundListVC.h"
#import "APAudioPlayerTools.h"
#import "APTranstionPopAnimation.h"
#import "APSoundListCell.h"
#import "APTool.h"
#import "APSoundListFlowLayout.h"
#import "APNetworkHelper.h"
#import "APPayManager.h"
#import "APSoundPlayerVC.h"
#import "APPayVC.h"
@interface APSoundListVC ()
<
UINavigationControllerDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
APSleepCollectionViewCellDelegate
>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) NSArray <MusicInfo *>*dataArrM;

@property (nonatomic, strong) APClassModel *classModel;
@end

@implementation APSoundListVC


- (instancetype)initWithType:(APClassModel *)model{
    self = [super init];
    if (self) {
        _classModel = model;
        self.kTagString = model.className_en;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [APTool getServiceMusicListForModel:self.classModel finished:nil];
    
    APBaseNavVC *nav = (APBaseNavVC *)self.navigationController;
    [nav ap_blackTitleStyle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicInfoUpdate:) name:MusicInfoUpdateFinishNotification object:nil];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)musicInfoUpdate:(NSNotification *)notifi {
    [self loadData];
}

- (void)loadData{
    self.title = self.classModel.name;
    self.dataArrM = [[APSQLiteManager shared] getMusicListFromType:self.classModel];
    [self.collectionView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[APLogTool shareManager] uploadLocalLogData];
    });
    
    self.index = -1;
    
    [self loadData];
    // 设置UI
    [self setupUI];
    
}


- (void)setupUI{
    [self.view addSubview:self.collectionView];
    
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor whiteColor];
    view.frame = CGRectMake(0, 0, KScreenWidth, kNavBarHeight);
    [self.view addSubview:view];
}

- (void)macthReceipt:(NSDictionary *)receipt {
    NSArray *in_app = receipt[@"receipt"][@"in_app"];
    for (int i = 0; i < in_app.count; i++) {
        NSDictionary *dic = in_app[i];
        NSString *productID = dic[@"product_id"];
        for (NSInteger i = 0; i < self.dataArrM.count; i++) {
            MusicInfo *model = self.dataArrM[i];
            if ([model.productId isEqualToString:productID]) {
                model.isPurchased = YES;
                continue;
            }
        }
    }
}

//MARK:- 点击cell回调
- (void)sleepCollectionViewDidSelectItem:(APSoundListCell *)cell{
    
    MusicInfo *model = cell.model;
    // 广告
    if (model.type == 1) {
        // 不响应广告的点击,交给广告自己
        return;
    }
    
    if (model.price.floatValue <= 0){
        
        [[APLogTool shareManager] addLogKey1:@"music" key2:@"play" content:@{@"type":self.classModel.className_en, @"music_name":model.name_en,@"premium":@"0"} userInfo:nil upload:NO];
        
        APSoundPlayerVC *playerVC = [[APSoundPlayerVC alloc]initWithModel:model];
        [self.navigationController pushViewController:playerVC animated:YES];
        return;
    }
   
    
    [SVProgressHUD show];
    [[APPayManager shareInstance]checkSubscriptionStatusComplete:^(BOOL isVip) {
        [SVProgressHUD dismiss];
        if (isVip){
            [[APLogTool shareManager] addLogKey1:@"music" key2:@"play" content:@{@"type":self.classModel.className_en, @"music_name":model.name_en,@"premium":@"1"} userInfo:nil upload:NO];
            APSoundPlayerVC *playerVC = [[APSoundPlayerVC alloc]initWithModel:model];
            [self.navigationController pushViewController:playerVC animated:YES];
            
        }else{
            APPayVC *vipPaymentVC = [[APPayVC alloc] init];
            [self presentViewController:vipPaymentVC animated:YES completion:nil];
        }
    }];
    
    

    return;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArrM.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MusicInfo *model = self.dataArrM[indexPath.row];
    model.argb = self.classModel.argb;
    
    APSoundListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([APSoundListCell class]) forIndexPath:indexPath];
    cell.model = model;
    cell.delegate = self;

    return cell;
}


- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    
    if (operation == UINavigationControllerOperationPop && [fromVC isKindOfClass:[APSoundListVC class]]) {
        return [APTranstionPopAnimation new];
    }else{
        return nil;
    }
}

- (void)ap_navigationBarBackButtonItemActionHandle{
    [super ap_navigationBarBackButtonItemActionHandle];
    //    [self.audioHelper stopMusic];
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        APSoundListFlowLayout *layout = [APSoundListFlowLayout new];
        
        _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithHex:0xf5f5f5];
        [_collectionView registerClass:[APSoundListCell class] forCellWithReuseIdentifier:NSStringFromClass([APSoundListCell class])];
        _collectionView.contentInset = UIEdgeInsetsMake(25*KWIDTH, 0, 25*KWIDTH, 0);
    }
    return _collectionView;
}

- (void)dealloc {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[APLogTool shareManager] uploadLocalLogData];
    });
}

//MARK:- lazy

- (NSArray *)dataArrM {
    if (!_dataArrM) {
        _dataArrM = [NSArray array];
    }
    return _dataArrM;
}

@end

