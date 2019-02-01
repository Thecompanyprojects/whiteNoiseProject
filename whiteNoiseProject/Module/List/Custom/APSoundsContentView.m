//
//  APSoundsContentView.m
//  whiteNoiseProject
//
//  Created by 许亚光 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//

#import "APSoundsContentView.h"
#import "APSoundsItemView.h"
#import "APSoundModel.h"

@interface APSoundsContentView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray <APSoundsItemView *>*soundItems;

@property (nonatomic, assign) NSUInteger placeholderCount;
@property (nonatomic, copy) UITableView *tableView;

@end
@implementation APSoundsContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tableView];
        [self.tableView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:0].active = YES;
        [self.tableView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:0].active = YES;
        [self.tableView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:-10].active = YES;
        if (KScreenWidth < 375) {
            [self.tableView.heightAnchor constraintEqualToConstant:50.0 * 3.0 + 20].active = YES;
        } else {
            [self.tableView.heightAnchor constraintEqualToConstant:60.0 * 3.0 + 20].active = YES;
        }
    }
    return self;
}


- (NSMutableArray *)soundItems {
    if (!_soundItems) {
        _soundItems = [NSMutableArray array];
    }
    return _soundItems;
}

- (void)setDataArrM:(NSMutableArray *)dataArrM {
    _dataArrM = dataArrM;
    [self.tableView reloadData];
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (KScreenWidth < 375) {
            _tableView.rowHeight = 50.0;
        } else {
            _tableView.rowHeight = 60.0;
        }
        _tableView.scrollEnabled = NO;
        //        _tableView.clipsToBounds = NO;
        _tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        _tableView.contentOffset = CGPointMake(0, -20);
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArrM.count + 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    APSoundsItemView *itemView = [cell.contentView viewWithTag:87439238];
    if (!itemView) {
        itemView = [[APSoundsItemView alloc] init];
        itemView.tag = 87439238;
        itemView.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:itemView];
        [itemView.leftAnchor constraintEqualToAnchor:cell.contentView.leftAnchor constant:30].active = YES;
        [itemView.rightAnchor constraintEqualToAnchor:cell.contentView.rightAnchor constant:-30].active = YES;
        [itemView.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:0].active = YES;
        [itemView.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:0].active = YES;
        
        // 音量调节回调
        itemView.volumeChaneged = ^(APSoundModel *model, NSInteger volume) {
            if (self.volumeChanged) {
                self.volumeChanged(model, volume);
            }
        };
    }
    
    if (indexPath.row + 1 > self.dataArrM.count) {
        itemView.model = nil;
    } else {
        itemView.model = self.dataArrM[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > self.dataArrM.count - 1) {
        return;
    }
    
    if (self.dataArrM.count > 1) {
        
        APSoundModel *model = self.dataArrM[indexPath.row];
        model.is_default = NO;
        
        // 处理
        [self.dataArrM removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        // 回调
        if (self.deleteSound) {
            self.deleteSound(model);
        }
        
    } else {
        [SVProgressHUD showInfoWithStatus:@"You need to choose at least one!"];
    }
}


- (void)addSoundItem:(APSoundModel *)model {
    if (self.dataArrM.count >= 3) {
        [self.dataArrM replaceObjectAtIndex:2 withObject:model];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    } else {
        NSUInteger index = self.dataArrM.count;
        [self.dataArrM addObject:model];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    }
}

- (void)deleteSoundItem:(APSoundModel *)model {
    NSIndexPath *indexpath = [self indexPathWithModel:model];
    if (!indexpath) {
        return;
    }
    
    [self.dataArrM removeObjectAtIndex:indexpath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationLeft];
}




// 计算下标
- (NSIndexPath *)indexPathWithModel:(APSoundModel *)model {
    for (id sound in self.dataArrM) {
        if (![sound isKindOfClass:[APSoundModel class]]) {
            continue;
        } else {
            APSoundModel *soundModel = (APSoundModel *)sound;
            if ([soundModel.groupId isEqualToNumber:model.groupId] && [soundModel.soundId isEqualToNumber:model.soundId]) {
                return [NSIndexPath indexPathForRow:[self.dataArrM indexOfObject:sound] inSection:0];
            }
        }
    }
    return nil;
}

@end

