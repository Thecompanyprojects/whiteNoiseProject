
#import "APSQLProtocol.h"
#import "APSQLBlock.h"
#import "APSQLiteManager.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
/** SQLite五种数据类型 */
#define SQLTEXT     @"TEXT"
#define SQLINTEGER  @"INTEGER"
#define SQLREAL     @"REAL"
#define SQLBLOB     @"BLOB"
#define SQLNULL     @"NULL"

//sql 关键字
#define PrimaryKey  @"primary key"

#define XY_Exception(class,reasion) @throw [NSException exceptionWithName:class reason:reasion userInfo:nil];

@interface APSQLiteManagerHelper : NSObject
/**
 * 数据库路径
 */
- (NSString *)dbPath;


/**
 分类目录路径
 
 @return return value description
 */
- (NSString *)classesPath;
///包内的路径。网络取不到的时候用的
- (NSString *)classesBundlePath;
- (NSString *)tableNameByModelClass:(Class)modelClass;//根据class生成表名


/**
 创表语句 1
 * SQLTableAddProHaveByModelClass 判断是否需要生成新列，若有block(sqlstring);
 * SQLTableHaveByModelClass判断表存在的sql语句
 * createSQLTableByModelClass根据类名创建表
 */
- (void)SQLTableAddProHaveByModelClass:(Class)modelClass WithProSaveArray:(NSArray *)saveNameArray AndAPSQLBlock:(SQL_AddPropertyBlcok)block;
- (NSString *)SQLTableHaveByModelClass:(Class)modelClass;
- (NSString *)createSQLTableByModelClass:(Class)modelClass;



/**
 创表语句 2
 
 @param modelClass 类名
 @param tableName 表名
 @return return value description
 */
//- (NSString *)createSQLTableByModelClass:(Class)modelClass
//                           AndTableName:(NSString *)tableName;

//- (void)addModelToFmdbWithModel:(NSObject <APSQLProtocol>*)model
//                      AndResult:(SQL_AddModelBlock)block;

- (void)addModelToFmdbWithModel:(NSObject <APSQLProtocol>*)model
                AndIgnoreColumn:(NSArray <NSString*>*)ignoreColumn
                      AndResult:(SQL_AddModelBlock)block;
/**
 * 查找 1
 *  生成sql语句
 */
- (NSString *)searchModelToFmdbWithModelClass:(Class)modelClass
                            AndInfoDictionary:(NSDictionary *)infoDictionary
                                AndSortColumn:(NSString *)sortName
                                  AndSortType:(Sql_Sort_Type)sortType;

- (NSObject <APSQLProtocol> *)modelByModelClass:(Class)modelClass
                         AndGetModelValueBlock:(GetModelValueBlock)block;

/**
 删除操作
 
 @param model 通过model的delegate 获取 主键 通过主键删除;
 @param block block description
 */
- (void)removeModelToFmdbWithModel:(NSObject <APSQLProtocol>*)model
                         AndResult:(SQL_AddModelBlock)block;


/**
 修改（根据主键更新）
 
 @param model 模型类
 @param ignoreColumn 要忽略的字段数组
 @param block block description
 *通过model的delegate获取主键
 */
- (void)updateModelToFmdbWithModel:(NSObject <APSQLProtocol>*)model
                   AndIgnoreColumn:(NSArray <NSString*>*)ignoreColumn
                         AndResult:(SQL_AddModelBlock)block;

/**
 修改（根据指定字段更新）
 
 @param modelClass 模型类
 @param updateDic 要更新的字段和值
 @param whereDic 限定的字段
 */
- (NSString *)updateModelClass:(Class)modelClass
                        AndDic:(NSDictionary *)updateDic
                      forWhere:(NSDictionary *)whereDic;
@end
