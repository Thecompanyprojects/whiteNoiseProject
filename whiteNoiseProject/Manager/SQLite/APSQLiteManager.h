//
//  APSQLiteManager.h
//  Sound
//
//  Created by 郭连城 on 2018/7/27.
//  Copyright © 2018年 DDTR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APSQLiteManagerHelper.h"
#import <fmdb/FMDB.h>
typedef NS_ENUM(NSInteger) {
    Sql_Manager_Type_Add = 0,
    Sql_Manager_Type_Del = 1,
    Sql_Manager_Type_Change = 2
}Sql_Manager_Type;



@interface APSQLiteManager : NSObject

- (void)updateSQL;

+ (instancetype)shared;


/**
 单个增删改
 
 @param type type description
 @param model model description
 @return return value description
 */

- (BOOL)updataModelByType:(Sql_Manager_Type)type
                WithModel:(NSObject <APSQLProtocol>*)model
         WithIgnoreColumn:(NSArray *)ignoreColumn;
/**
 批量正删改
 
 @param type type description
 @param models models description
 @param block 失败会返回失败的数组
 */
- (void)updateModelsByType:(Sql_Manager_Type)type
                WithModels:(NSArray <NSObject <APSQLProtocol>*> *)models
          WithIgnoreColumn:(NSArray *)ignoreColumn
            AndFinishBlock:(SQL_ResultBlock)block;

/**
 查接口
 
 @param modelClass modelClass description
 @return return value description
 */
- (NSArray *)searchModelsByModelClass:(Class)modelClass;

//- (NSArray *)searchModelsByModelClass:(Class)modelClass AndSearchPropertyDictionary:(NSDictionary *)propertyDictionary;

- (NSArray *)searchModelsByModelClass:(Class)modelClass
          AndSearchPropertyDictionary:(NSDictionary *)propertyDictionary
                        AndSortColumn:(NSString *)sortName
                          AndSortType:(Sql_Sort_Type)sortType;

/**
 * FMDB全局队列对象
 */
@property (nonatomic,strong)FMDatabaseQueue *dbQueue;
@end
