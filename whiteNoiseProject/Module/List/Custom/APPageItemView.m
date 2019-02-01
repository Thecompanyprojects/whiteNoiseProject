//
//  APPageItemView.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APPageItemView.h"
#import "APSoundClassModel.h"
#import "APSoundModel.h"

#import "APSoundItemCell.h"
#import "UIColor+Extension.h"
#import "APPayManager.h"


@interface APPageItemView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@end
@implementation APPageItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)setModel:(APSoundClassModel *)model {
    _model = model;
    [self.collectionView reloadData];
}

- (void)initSubviews {
    
    NSInteger itemcount_row = 4;
    CGFloat margan = 20.0;
    CGFloat space = 4.0;
    CGFloat view_w = [UIScreen mainScreen].bounds.size.width * 0.95;
    CGFloat item_w = (view_w - margan * 2 - space * (itemcount_row - 1)) / (itemcount_row * 1.0);
    CGFloat item_h = item_w;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(item_w, item_h);
    layout.minimumLineSpacing = space;
    layout.minimumInteritemSpacing = space - 1.0;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, margan, margan, margan);
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    [self.collectionView registerClass:[APSoundItemCell class] forCellWithReuseIdentifier:NSStringFromClass([APSoundItemCell class])];
    
    [self addSubview:self.collectionView];
    [self.collectionView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [self.collectionView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [self.collectionView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.collectionView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.model.resource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    APSoundItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([APSoundItemCell class]) forIndexPath:indexPath];
    cell.model = self.model.resource[indexPath.row];
    cell.downloadFinished = ^(BOOL isSuccess, NSError *error) {
        if (isSuccess) {
            [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        } else {
            //            [SVProgressHUD showInfoWithStatus:@"Download error!"];
        }
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    APSoundItemCell *cell = (APSoundItemCell *)[collectionView cellForItemAtIndexPath:indexPath];
    @weakify(self);
    if (cell.model.is_vip && ![APPayManager shareInstance].isVip) { // 需要订阅Vip
        if (self.ItemSelectShouldVip) {
            @strongify(self);
            self.ItemSelectShouldVip(cell.model);
        }
    } else { // 非Vip或者已订阅
        if (!cell.model.isDownload) { // 需要下载
            [cell downloadSound];
        } else { // 不需要下载或者已经下载
            // 选择事件
            if (self.ItemSelect) {
                @strongify(self);
                if (self.ItemSelect(cell.model)) {
                    NSLog(@"++++可被选中+++++++");
                    [[APLogTool shareManager] addLogKey1:@"custom" key2:@"select_tone" content:@{@"classify":self.model.groupName} userInfo:nil upload:NO];
                } else {
                    NSLog(@"----不可选中-------");
                }
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        }
    }
}


@end

