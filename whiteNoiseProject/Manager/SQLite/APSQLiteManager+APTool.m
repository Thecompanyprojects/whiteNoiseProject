//

//  Sound
//
//  Created by 郭连城 on 2018/8/15.
//  Copyright © 2018年 DDTR. All rights reserved.
//

#import "APSQLiteManager+APTool.h"
//#import "APSQLiteManager.h"


#import "MusicInfo.h"

@implementation APSQLiteManager (APTool)

- (void)savePurchasedProduct:(NSString *)productId{
    
    NSString *sql = [NSString stringWithFormat: @"UPDATE MusicInfo SET isPurchased = '%d' WHERE productId = '%@'",1,productId];
    
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:sql];
    }];
    [[NSNotificationCenter defaultCenter]postNotificationName:MusicInfoUpdateFinishNotification object:nil];
}

//更新数据库的文件名
//TODO:--把更新方法封装一个 忽略某个参数，和只更新某个参数的方法。！！！！！
- (void)saveFileRecord:(NSString *)url AndFileName:(NSString *)fimeName{
    // NSString *sql1 = [[APSQLiteManagerHelper new] updateModelClass:MusicInfo.class
    // AndDic:@{@"mp3FileName":fimeName}
    //   forWhere:@{@"downloadUrl":url}];
    
    NSString *sql = [NSString stringWithFormat: @"UPDATE MusicInfo SET mp3FileName = '%@' WHERE downloadUrl = '%@'",fimeName,url];
    
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:sql];
    }];
}

- (void)saveInfo:(NSDictionary *)dic{
    
    NSNumber *code = dic[@"code"];
    if (code.integerValue  != 1){return;}
    
    NSArray <NSDictionary *> *arr = dic[@"data"];
    if (arr.count <= 0){return;}
    
    NSMutableArray <MusicInfo *>*modelsArr = [NSMutableArray array];
    for (NSDictionary *modelDic in arr){
        
        MusicInfo *model = [MusicInfo yy_modelWithDictionary:modelDic];
        [modelsArr addObject:model];
    }
    
    NSString *flag = [NSString stringWithFormat:@"%ld",(long)modelsArr[0].flag];
    
    NSMutableArray *oldModels = [self searchModelsByModelClass:[MusicInfo class]
                                   AndSearchPropertyDictionary:@{@"flag":flag} AndSortColumn:nil AndSortType:Sql_Sort_Type_None].mutableCopy;
    
    
    NSMutableArray *haveModels = [NSMutableArray array];
    
    //找出都有的，oldModels 删除掉 haveModels 就剩下需要删除的了。
    for (MusicInfo *model in modelsArr){
        for (MusicInfo *oldModel in oldModels){
            if ([oldModel.ID isEqualToString:model.ID]){
                [haveModels addObject:oldModel];
            }
        }
    }
    
    [oldModels removeObjectsInArray:haveModels];
    
    [self updateModelsByType:Sql_Manager_Type_Del WithModels:oldModels WithIgnoreColumn:nil AndFinishBlock:^(BOOL successful, NSArray *fireModelArray) {
        if (!successful){
            NSLog(@"数据库 删除错误 以下数据未删除：/n%@",fireModelArray);
        }
    }];
    
    
    
    NSArray *ignoreArr = @[@"mp3FileName",@"isPurchased"];
    //插入一遍更新一遍，是因为没有（插入如果有就替换的语句）
    [self updateModelsByType:Sql_Manager_Type_Add WithModels:modelsArr WithIgnoreColumn:ignoreArr AndFinishBlock:^(BOOL successful, NSArray *fireModelArray) {
        if (!successful){
            NSLog(@"数据库 储存出现错误 以下数据储存:/n %@",fireModelArray);
        }
    }];
    
    [self updateModelsByType:Sql_Manager_Type_Change WithModels:modelsArr WithIgnoreColumn:ignoreArr AndFinishBlock:^(BOOL successful, NSArray *fireModelArray) {
        if (!successful){
            NSLog(@"数据库 更新出现错误 以下数据未更新:/n %@",fireModelArray);
        }
    }];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:MusicInfoUpdateFinishNotification object:nil];
}


//MARK:- 分类目录存方法
- (void)saveClassesInfo:(NSDictionary *)dic{
    NSNumber *code = dic[@"code"];
    if (code.integerValue  != 1){return;}
    
    NSArray <NSDictionary *> *arr = dic[@"classes"];
    if (arr.count <= 0){return;}
    NSData *date = [dic yy_modelToJSONData];
    
    // 1> 写入磁盘
    NSString *jsonPath = [[APSQLiteManagerHelper new] classesPath];
    
    // 直接保存在沙盒
    [date writeToFile:jsonPath atomically:true];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:MusicInfoUpdateFinishNotification object:nil];
}

//MARK:- 分类目录取数据方法
- (NSArray <APClassModel *>*)getClassesModels{
    NSString *path = [[APSQLiteManagerHelper new]classesPath];
    
    NSArray <APClassModel *>*models = [NSArray array];
    NSData *jsonData = [NSData dataWithContentsOfFile:path];
    if (!jsonData){
        NSString *bundlePath = [[APSQLiteManagerHelper new] classesBundlePath];
        jsonData = [NSData dataWithContentsOfFile:bundlePath];
        
        if (!jsonData){
            return models;
        }
    }
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
    
    NSArray *arr = dic[@"classes"];
    
    models = [NSArray yy_modelArrayWithClass:APClassModel.class json:arr];
    
    models = [models sortedArrayUsingComparator:^NSComparisonResult(APClassModel *obj1,APClassModel * obj2) {
        if (obj1.classIndex >obj2.classIndex){
            return NSOrderedDescending;
        }else{
            return NSOrderedAscending;
        }
    }];
    
    NSLog(@"%@", models);
    return models;
}

//MARK:- 根据对应目录获取音乐列表
- (NSArray <MusicInfo *>*)getMusicListFromType:(APClassModel *)model{
    NSString *flag = [NSString stringWithFormat:@"%ld",(long)model.classId];
    NSArray *models = [self searchModelsByModelClass:MusicInfo.class
                         AndSearchPropertyDictionary:@{@"flag":flag}
                                       AndSortColumn:@"index"
                                         AndSortType:Sql_Sort_Type_Asc];
    
    if (models.count <= 0){
        NSMutableArray *m = [NSMutableArray array];
        //如果数据库没有 从 Bundle 加载 data
        NSString *path = [[NSBundle mainBundle] pathForResource:@"musicList.json" ofType:nil];
        NSData *data = [NSData dataWithContentsOfFile:path];
        models = [NSArray yy_modelArrayWithClass:[MusicInfo class] json:data];
        //            NSLog(@"%@", models);
        for (MusicInfo *model in models){
            if(model.flag == flag.integerValue){
                [m addObject:model];
            }
        }
        models = m.copy;
    }
    return models;
}




@end
