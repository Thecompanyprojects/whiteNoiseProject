//
//  APCustomListViewController.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APCustomListVC.h"
#import "APPayManager.h"
#import "APSoundListFlowLayout.h"
#import "APCustomSoundListAddCell.h"
#import "APCustomSoundListCell.h"
#import "APPayVC.h"
#import "APCuntomTool.h"
#import "APCustomCardView.h"
#import "APSoundPlayerVC.h"

@interface APCustomListVC () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray <APCustomModel *>*dataArray;
@end

@implementation APCustomListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.kTagString = @"custom";
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    APBaseNavVC *nav = (APBaseNavVC *)self.navigationController;
    [nav ap_blackTitleStyle];
    
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(0, 0, 44, 44);
    [addBtn setImage:[UIImage imageNamed:@"custom_nav_add"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addBtnItemAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addBtnItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    self.navigationItem.rightBarButtonItem = addBtnItem;
    
    self.dataArray = [NSMutableArray arrayWithArray:[[APCuntomTool sharedCuntomTool] getCuntomDataArray]];
    
    
    
    [self.collectionView setupEmptyDataText:@"Haven't added audio yet" verticalOffset:-kNavBarHeight emptyImage:[UIImage imageNamed:@"custom_empty"] tapBlock:^{
        
    }];
    
    
    [self.collectionView reloadData];
    [self.collectionView reloadEmptyDataSet];
}

#pragma mark - 添加按钮
- (void)addBtnItemAction:(UIButton *)sender {
    @weakify(self);
    [[APCuntomTool sharedCuntomTool] getSoundClassData:^(NSArray<APSoundClassModel *> *soundClassDataArray, NSArray<APSoundModel *> *defaultDataArray) {
        @strongify(self);
        if (soundClassDataArray.count <= 0) {
            [SVProgressHUD showErrorWithStatus:@"Data error, Please try again later"];
            [[APCuntomTool sharedCuntomTool] requestData];
            return;
        }
        APCustomModel *customModel = [APCustomModel new];
        customModel.isSaved = NO;
        customModel.sounds = [NSMutableArray arrayWithArray:defaultDataArray];
        customModel.icon_name = @"默认图_Normal";
        customModel.icon_bg_name = @"首页背景图模糊";
        
        APSoundPlayerVC *player = [[APSoundPlayerVC alloc] initWithSoundClassDataArray:soundClassDataArray cuntormDataModel:customModel isSelect:YES];
        [self.navigationController pushViewController:player animated:YES];
    }];
}

- (void)dealloc {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[APLogTool shareManager] uploadLocalLogData];
    });
}

#pragma mark - setupViews
- (void)setupViews {
    self.title = @"Custom";
    
    [self.view addSubview:self.collectionView];
    
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor whiteColor];
    view.frame = CGRectMake(0, 0, KScreenWidth, kNavBarHeight);
    [self.view addSubview:view];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    APCustomModel *model = self.dataArray[indexPath.item];
    APCustomSoundListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([APCustomSoundListCell class]) forIndexPath:indexPath];
    cell.model = model;
    cell.deleteAction = ^(APCustomModel *_model) {
        [UIAlertController showAlertTitle:@"Tips" message:@"Are you sure to delete it" cancelTitle:@"Cancel" otherTitle:@"Delete" cancleBlock:nil otherBlock:^{
            if ([[APCuntomTool sharedCuntomTool] deleteCustormData:_model]) {
                NSInteger index = [self.dataArray indexOfObject:_model];
                [self.dataArray removeObject:_model];
                [collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
                [collectionView reloadEmptyDataSet];
                [[APLogTool shareManager] addLogKey1:@"custom" key2:@"delete" content:nil userInfo:nil upload:NO];
            }
        }];
    };
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    APCustomModel *model = self.dataArray[indexPath.item];
    
    BOOL vipContains = NO;
    for (APSoundModel *sound in model.sounds) {
        if (sound.is_vip) {
            vipContains = YES;
            break;
        }
    }
    if (vipContains) {
        @weakify(self);
        [[APPayManager shareInstance] checkSubscriptionStatusComplete:^(BOOL isVip) {
            if (isVip) {
                [self gotoPlayCustomSounds:model];
            } else {
                [UIAlertController showAlertTitle:@"Tips" message:@"Option contains paid items that require subscriptions to be unlocked before proceeding" cancelTitle:@"cancel" otherTitle:@"subscribe" cancleBlock:nil otherBlock:^{
                    APPayVC *pay = [[APPayVC alloc] init];
                    @strongify(self);
                    [self presentViewController:pay animated:YES completion:nil];
                }];
            }
        }];
        
    } else {
        [self gotoPlayCustomSounds:model];
    }
}

- (void)gotoPlayCustomSounds:(APCustomModel *)customModel {
    NSArray<APSoundClassModel *>*soundClassDataArrray = [[APCuntomTool sharedCuntomTool] getSoundClassDataArray];
    APSoundPlayerVC *player = [[APSoundPlayerVC alloc] initWithSoundClassDataArray:soundClassDataArrray cuntormDataModel:customModel isSelect:NO];
    [self.navigationController pushViewController:player animated:YES];
}


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 15.0;
        layout.minimumInteritemSpacing = 15.0;
        layout.itemSize = CGSizeMake((KScreenWidth - 3 * 15) / 2.0, (KScreenWidth - 3 * 15) / 2.0);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionInset = UIEdgeInsetsMake(0, 15.0, 0, 15.0);
        _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.contentInset = UIEdgeInsetsMake(25*KWIDTH, 0, 25*KWIDTH, 0);
        _collectionView.frame = self.view.bounds;
        
        [_collectionView registerClass:[APCustomSoundListAddCell class] forCellWithReuseIdentifier:NSStringFromClass([APCustomSoundListAddCell class])];
        [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([APCustomSoundListCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([APCustomSoundListCell class])];
    }
    return _collectionView;
}





@end

