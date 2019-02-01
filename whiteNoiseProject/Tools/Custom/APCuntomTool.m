//
//  APCuntomTool.m
//  whiteNoiseProject
//
//  Created by 郭连城 on 2018/12/10.
//  Copyright © 2018 skunkworks. All rights reserved.
//


#import "APCuntomTool.h"
#import <objc/runtime.h>
#import "APNetworkHelper.h"


@implementation APCuntomTool

static APCuntomTool *_cuntomTool;

// 实例化
+ (instancetype)sharedCuntomTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cuntomTool = [[self alloc] init];
    });
    return _cuntomTool;
}

// 数据请求
- (void)requestData {
    // 加载音效资源
    @weakify(self);
    [APNetworkHelper xt_postRequestWithType:XTNetworkRequestTypeCustom parameters:nil response:^(NSDictionary *dict) {
        @strongify(self);
        // 数据转换
        NSMutableArray *arrM = (NSMutableArray *)dict[@"data"];
        // 数据保存
        [self saveSoundClassData:arrM];
        // 下载默认数据
        [self downloadDefaultSounds:arrM];
        
    } error:^(NSError *error) {

    }];
}

// 预下载默认音效
- (void)downloadDefaultSounds:(NSArray *)data {
    for (NSDictionary *dictClass in data) {
        NSArray *resourceArray = dictClass[@"resource"];
        for (NSDictionary *soundDict in resourceArray) {
            NSNumber *isDefault = soundDict[@"is_default"];
            if ([isDefault isEqualToNumber:@(1)]) {
                NSString *mp3 = soundDict[@"download_url"];
                [[APSoundDownloadRequest initWithURL:mp3] startDownload];
                NSString *icon = soundDict[@"image_select"];
                [[UIImageView new] sd_setImageWithURL:[NSURL URLWithString:icon]];
            }
        }
    }
}


- (BOOL)saveCustormData:(APCustomModel *)model {
    // 获取本地数据
    NSMutableArray *arrM = [NSMutableArray arrayWithArray:[self getCuntomDataArray]];
    [arrM insertObject:model atIndex:0];
    return [NSKeyedArchiver archiveRootObject:[arrM yy_modelToJSONObject] toFile:[self APCustomModelDataArchiverPath]];
}

- (BOOL)deleteCustormData:(APCustomModel *)model {
    NSMutableArray <APCustomModel *>*arrM = [NSMutableArray arrayWithArray:[self getCuntomDataArray]];
    for (APCustomModel *custom in arrM) {
        if (model.customId == custom.customId) {
            [arrM removeObject:custom];
            break;// 必须break;
        }
    }
    return [NSKeyedArchiver archiveRootObject:[arrM yy_modelToJSONObject] toFile:[self APCustomModelDataArchiverPath]];
}

- (NSArray<APCustomModel *> *)getCuntomDataArray {
    NSArray <NSDictionary *>*dictArr = [NSKeyedUnarchiver unarchiveObjectWithFile:[self APCustomModelDataArchiverPath]];
    if (!dictArr) {
        return [NSArray array];
    }
    NSArray <APCustomModel *>* dataArray = [NSArray yy_modelArrayWithClass:[APCustomModel class] json:dictArr];
    if (!dataArray) {
        return [NSArray array];
    }
    return dataArray;
}

- (NSArray <NSDictionary *>*)getLocalCustomData {
    NSArray <NSDictionary *>*dictArr = [NSKeyedUnarchiver unarchiveObjectWithFile:[self APSoundClassModelDataArchiverPath]];
    if (dictArr) {
        return dictArr;
    }
    return [NSArray array];
}


// 保存网络请求所得数据
- (BOOL)saveSoundClassData:(NSArray<NSDictionary *> *)dataArray {
    return [NSKeyedArchiver archiveRootObject:dataArray toFile:[self APSoundClassModelDataArchiverPath]];;
}

- (NSArray<APSoundClassModel *> *)getSoundClassDataArray {
    NSArray <NSDictionary *>*dictArr = [NSKeyedUnarchiver unarchiveObjectWithFile:[self APSoundClassModelDataArchiverPath]];
    if (dictArr) {
        NSArray <APSoundClassModel *>* dataArray = [NSArray yy_modelArrayWithClass:[APSoundClassModel class] json:dictArr];
        return dataArray;
    }
    return [NSArray array];
}

- (NSArray<APSoundModel *> *)getDefaultSoundDataArray {
    return [self defauleSoundClassDataArray:[self getSoundClassDataArray]];
}

- (void)getSoundClassData:(void (^)(NSArray<APSoundClassModel *> *, NSArray<APSoundModel *> *))dataSource {
    NSArray <APSoundClassModel *>*soundClassDataArray;
    NSArray <APSoundModel *>*defaultDataArray;
    NSArray <NSDictionary *>*dictArr = [NSKeyedUnarchiver unarchiveObjectWithFile:[self APSoundClassModelDataArchiverPath]];
    if (dictArr) {
        NSArray <APSoundClassModel *>* dataArray = [NSArray yy_modelArrayWithClass:[APSoundClassModel class] json:dictArr];
        if (dataArray) {
            soundClassDataArray = dataArray;
            defaultDataArray = [self defauleSoundClassDataArray:dataArray];
            dataSource(soundClassDataArray, defaultDataArray);
            return;
        }
    }
    
    [self requestData];
    
    dataSource([NSArray array], [NSArray array]);
}


- (NSMutableArray<APSoundClassModel *> *)getAPSoundClassModelArray {
    NSArray <NSDictionary *>*dictArr = [NSKeyedUnarchiver unarchiveObjectWithFile:[self APSoundClassModelDataArchiverPath]];
    if (!dictArr) {
        return [NSMutableArray array];
    }
    NSArray <APSoundClassModel *>* dataArray = [NSArray yy_modelArrayWithClass:[APSoundClassModel class] json:dictArr];
    if (!dataArray) {
        return [NSMutableArray array];
    }
    return [NSMutableArray arrayWithArray:dataArray];
}


#pragma mark - 筛选默认数据
- (NSArray <APSoundModel *>*)defauleSoundClassDataArray:(NSArray <APSoundClassModel *>*)classArrM {
    NSMutableArray *dataArray = [NSMutableArray array];
    for (APSoundClassModel *classModel in classArrM) {
        for (APSoundModel *APSoundModel in classModel.resource) {
            if (APSoundModel.is_default) {
                [dataArray addObject:APSoundModel];
            }
        }
    }
    return dataArray.copy;
}

- (NSString *)APCustomModelDataArchiverPath {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"custormmusicdata.archiver"];
    return path;
}

- (NSString *)APSoundClassModelDataArchiverPath {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [docPath stringByAppendingPathComponent:@"soundclassdata.archiver"];
    return path;
}




@end
