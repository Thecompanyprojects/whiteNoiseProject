//
//  APSQLiteManager.m
//  Sound
//
//  Created by 郭连城 on 2018/7/27.
//  Copyright © 2018年 DDTR. All rights reserved.
//

#import "APSQLiteManager.h"
#import "MusicInfo.h"
#import <FMDBMigrationManager/FMDBMigrationManager.h>
#import "Migration.h"
#import <YYModel.h>
@interface APSQLiteManager()

@property (nonatomic,strong)APSQLiteManagerHelper *helper;
//用来存储class的数组
@property (nonatomic,strong) NSMutableArray *classNameArray;

@end


@implementation APSQLiteManager

static APSQLiteManager *instance;


- (void)updateSQL{
    
    NSString *dbpath = [[APSQLiteManagerHelper new] dbPath];
    FMDBMigrationManager * manager = [FMDBMigrationManager managerWithDatabaseAtPath: dbpath migrationsBundle:[NSBundle mainBundle]];
    
    //    Migration * migration_1=[[Migration alloc]initWithName:@"新增USer表" andVersion:1 andExecuteUpdateArray:@[@"create table User(name text,age integer)"]];
    //    Migration * migration_2=[[Migration alloc]initWithName:@"SleepMusicInfo表新增字段email"
    //                                                andVersion:6
    //                                     andExecuteUpdateArray:@[@"alter table MusicInfo add name_en text",
    //                                                             @"alter table SleepMusicInfo add name_en text"]];
    //
    //    [manager addMigration:migration_1];
    //    [manager addMigration:migration_2];
    
    
    if (!manager.hasMigrationsTable) {
        [manager createMigrationsTable:nil];
    }
    
    [manager migrateDatabaseToVersion:UINT64_MAX progress:^(NSProgress *progress) {
        NSLog(@"数据库升级进度%@",progress);
    } error:nil];
    
    //    BOOL resultState = NO;
    //    NSError * error=nil;
    //    if (!manager.hasMigrationsTable) {
    //        resultState=[manager createMigrationsTable:&error];
    //    }
    //    resultState = [manager migrateDatabaseToVersion:UINT64_MAX progress:^(NSProgress *progress) {
    //        NSLog(@"数据库升级进度%@",progress);
    //    } error:&error];
}

+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[APSQLiteManager alloc]init];
    });
    return instance;
}

- (instancetype)init{
    __block APSQLiteManager *temp = self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ((temp = [super init]) != nil) {
            NSString *path = [self.helper dbPath];
            self->_dbQueue = [[FMDatabaseQueue alloc]initWithPath:path];
        }
    });
    self = temp;
    return self;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

#pragma mark 条件查找
- (NSArray *)searchModelsByModelClass:(Class)modelClass{
    NSArray * arr = [self searchModelsByModelClass:modelClass
                       AndSearchPropertyDictionary:nil
                                     AndSortColumn:nil
                                       AndSortType: Sql_Sort_Type_Asc];
    
    return arr;
}
#pragma mark 条件查找
- (NSArray *)searchModelsByModelClass:(Class)modelClass
          AndSearchPropertyDictionary:(NSDictionary *)propertyDictionary
                        AndSortColumn:(NSString *)sortName
                          AndSortType:(Sql_Sort_Type)sortType{
    //建表或
    [self createTable:modelClass];
    
    NSMutableArray *models = [NSMutableArray array];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sqlString = [self.helper searchModelToFmdbWithModelClass:modelClass AndInfoDictionary:propertyDictionary AndSortColumn:sortName AndSortType:sortType];
        
        FMResultSet *resultSet = [db executeQuery:sqlString];
        while ([resultSet next]) {
            NSObject <APSQLProtocol> *model = [self.helper modelByModelClass:modelClass AndGetModelValueBlock:^id(NSString *columeName, Property_Type type) {
                switch (type) {
                    case Property_Type_String:
                        return [resultSet stringForColumn:columeName];
                    case Property_Type_Data:
                        return [resultSet dataForColumn:columeName];
                    case Property_Type_Longlong:
                        return @([resultSet longLongIntForColumn:columeName]);
                }
            }];
            [models addObject:model];
            FMDBRelease(model);
        }
    }];
    return models;
}



//MARK:- 单个___增删改
- (BOOL)updataModelByType:(Sql_Manager_Type)type
                WithModel:(NSObject <APSQLProtocol>*)model
         WithIgnoreColumn:(NSArray *)ignoreColumn{
    
    [self createTable:model.class];
    
    __block BOOL res = NO;
    [_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        switch (type) {
            case Sql_Manager_Type_Add:
                res = [self addAction:db withIgnoreColumn:ignoreColumn withModel:model];
                break;
            case Sql_Manager_Type_Del:
                res = [self removeAction:db withModel:model];
                break;
            case Sql_Manager_Type_Change:
                res = [self updateAction:db withIgnoreColumn:ignoreColumn withModel:model];
                break;
        }
    }];
    return res;
}

//MARK:- 批量___增删改
- (void)updateModelsByType:(Sql_Manager_Type)type
                WithModels:(NSArray <NSObject <APSQLProtocol>*> *)models
          WithIgnoreColumn:(NSArray *)ignoreColumn
            AndFinishBlock:(SQL_ResultBlock)block{
    
    __weak typeof(self) weakSelf = self;
    BOOL(^swithBlock)(Sql_Manager_Type type,NSObject<APSQLProtocol> *model,FMDatabase *db) = ^(Sql_Manager_Type type,NSObject<APSQLProtocol> *model,FMDatabase *db){
        BOOL res = NO;
        switch (type) {
            case Sql_Manager_Type_Add:
                res = [weakSelf addAction:db withIgnoreColumn:ignoreColumn withModel:model];
                break;
            case Sql_Manager_Type_Del:
                res = [weakSelf removeAction:db withModel:model];
                break;
            case Sql_Manager_Type_Change:
                res = [weakSelf updateAction:db withIgnoreColumn:ignoreColumn withModel:model];
                break;
        }
        return res;
    };
    
    
    NSMutableArray *fairModelArray = [NSMutableArray array];
    
    [_dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (NSObject<APSQLProtocol> *model in models) {
            //建表
            [weakSelf createTableAction:db WithRollback:rollback AndClass:model.class];
            //不同的操作
            BOOL success = swithBlock(type,model,db);
            if (!success) [fairModelArray addObject:model];
        }
    }];
    
    if (fairModelArray.count == 0){
        if (block){
            block(YES,nil);
        }
    }else{
        if (block){
            block(NO,fairModelArray);
        }
    }
}

/**
 * 改
 * 批量改
 * 单个改
 *
 */

- (BOOL)updateAction:(FMDatabase *)db
    withIgnoreColumn:(NSArray *)ignoreColumn
           withModel:(NSObject <APSQLProtocol>*)model{
    __block BOOL res = NO;
    [self.helper updateModelToFmdbWithModel:model
                            AndIgnoreColumn:ignoreColumn
                                  AndResult:^(NSString *sqlString, NSArray *valueArray) {
                                      
                                      res = [db executeUpdate:sqlString withArgumentsInArray:valueArray];
                                      if (!res){
                                          NSLog(@"%@,%@",res?@"成功":@"失败",sqlString);
                                      }
                                  }];
    return res;
}



/**
 * 删
 * 批量删
 * 单个删
 *
 */
- (BOOL)removeAction:(FMDatabase *)db
           withModel:(NSObject <APSQLProtocol>*)model{
    __block BOOL res = NO;
    [self.helper removeModelToFmdbWithModel:model AndResult:^(NSString *sqlString, NSArray *valueArray) {
        res = [db executeUpdate:sqlString withArgumentsInArray:valueArray];
        if (!res){
            NSLog(@"%@,%@",res?@"成功":@"失败",sqlString);
        }
    }];
    return res;
}


/**
 添加
 
 @param db db description
 @param model model description
 @return return value description
 */
- (BOOL)addAction:(FMDatabase *)db
 withIgnoreColumn:(NSArray *)ignoreColumn
        withModel:(NSObject <APSQLProtocol>*)model{
    __block BOOL res = NO;
    [self.helper addModelToFmdbWithModel:model
                         AndIgnoreColumn: ignoreColumn
                               AndResult:^(NSString *sqlString, NSArray *valueArray) {
                                   
                                   res = [db executeUpdate:sqlString withArgumentsInArray:valueArray];
                                   if (!res){
                                       NSLog(@"%@,%@",res?@"成功":@"失败",sqlString);
                                   }
                               }];
    return res;
}
/**
 * 建表
 * createTableAction 为了解决 addmodels 导致的嵌套死锁
 */
- (BOOL)createTableAction:(FMDatabase *)db WithRollback:(BOOL *)rollback AndClass:(Class)modelClass{
    __block BOOL res = YES;
    NSString *tableName = [self.helper tableNameByModelClass:modelClass];
    //不包含则 更新表 或者 创建表
    if ([self.classNameArray containsObject:tableName]) {
        return YES;
    }
    
    NSString *tableHaveSQLString = [self.helper SQLTableHaveByModelClass:modelClass];
    //    FMResultSet *rs = [db executeQuery:tableHaveSQLString];
    FMResultSet *rs = [db executeQuery:tableHaveSQLString,tableName];
    
    BOOL isCreate = NO;
    while ([rs next]) {
        NSInteger count = [rs intForColumn:@"count"];
        if (count != 0) isCreate = YES;
    }
    if (isCreate) {
        //已经创建：添加tab的 新列
        NSArray *columns = [self dataBaseProertyByFMDatabase:db AndTableName:tableName];
        [self.helper SQLTableAddProHaveByModelClass:modelClass WithProSaveArray:columns AndAPSQLBlock:^(NSString *sqlString) {//此处会多次执行
            if (![db executeUpdate:sqlString]) {
                res = NO;
                *rollback = YES;
                //                return ;
            }
        }];
    }else{
        //未被创建：创建tab
        NSString *tableCreateSQLString = [self.helper createSQLTableByModelClass:modelClass];
        if (![db executeUpdate:tableCreateSQLString]) {
            res = NO;
            *rollback = YES;
        };
    }
    
    //成功的话存储一下class
    if (res) {
        [self.classNameArray addObject:tableName];
    }
    return res;
}

- (BOOL)createTable:(Class)modelClass{
    __block BOOL res = YES;
    __weak typeof(self) weakSelf = self;
    //1. 判断表是否存在，存在则继续执行第二步,（不存在不需要执行第二步）
    //2. 判断是否属性有删减，
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        res = [weakSelf createTableAction:db WithRollback:rollback AndClass:modelClass];
    }];
    return res;
    
    //    [_dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
    //        NSString *tableName = NSStringFromClass(model);
    //        if ([db tableExists: tableName]){
    //            NSLog(@"表已创建");
    //            return;
    //        }
    //
    //        NSString *createSql = [self.helper createSQLTableByModelClass:model];
    //        if ([db executeStatements:createSql]){
    //            NSLog(@"创表成功");
    //        }else{
    //            NSLog(@"创表失败");
    //        }
    //    }];
}

//MARK:- 辅助方法。
- (NSArray *)dataBaseProertyByFMDatabase:(FMDatabase *)db AndTableName:(NSString *)tableName{
    NSMutableArray *columns = [NSMutableArray array];
    FMResultSet *resultSet = [db getTableSchema:tableName];
    while ([resultSet next]) {
        NSString *column = [resultSet stringForColumn:@"name"];
        [columns addObject:column];
    }
    return columns;
}


//mark:- 懒加载
- (APSQLiteManagerHelper *)helper{
    if (!_helper) {
        _helper = [[APSQLiteManagerHelper alloc] init];
    }
    return _helper;
}
- (NSMutableArray *)classNameArray{
    if (!_classNameArray) {
        _classNameArray = [NSMutableArray array];
    }
    return _classNameArray;
}
@end
