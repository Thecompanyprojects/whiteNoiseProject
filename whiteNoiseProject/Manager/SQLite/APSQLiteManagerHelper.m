

#import "APSQLiteManagerHelper.h"

@implementation APSQLiteManagerHelper

- (NSString *)dbPath{
    //数据库地址 测试的时候直接放在桌面
#if TARGET_IPHONE_SIMULATOR
    
    BOOL ii = [[NSFileManager defaultManager] fileExistsAtPath:@"/Users/guoliancheng/工程代码/joopic-ios.zip"];
    if (ii) {
        NSString * path=@"/Users/guoliancheng/Desktop/fmdbMigration.db";
        return path;
    }else{
        return [self dbPathByString:@"music"];
    }
#elif TARGET_OS_IPHONE      //真机
    return [self dbPathByString:@"music"];
#endif
}

- (NSString *)classesBundlePath{
    return  [[NSBundle mainBundle] pathForResource:@"classes.json" ofType:nil];
}

- (NSString *)classesPath{
    NSString *jsonPath = [[APSQLiteManagerHelper new] dbPath];
    jsonPath = [jsonPath stringByDeletingLastPathComponent];
    jsonPath = [jsonPath stringByAppendingPathComponent:@"classes.json"];
    return  jsonPath;
}

/**
 @param modelClass    class
 @param saveNameArray 表的所有字段名称
 @param block 添加列的block
 
 */
- (void)SQLTableAddProHaveByModelClass:(Class)modelClass WithProSaveArray:(NSArray *)saveNameArray AndAPSQLBlock:(SQL_AddPropertyBlcok)block{
    NSString *tableName = [self tableNameByModelClass:modelClass];
    NSDictionary *propertysDictionary = [self getPropertysDictionaryByModelClass:modelClass];
    NSArray *properties = propertysDictionary.allKeys;
    
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",saveNameArray];
    NSArray *resultArray = [properties filteredArrayUsingPredicate:filterPredicate];
    for (NSString *column in resultArray) {
        NSString *proType = propertysDictionary[column];
        NSString *fieldSql = [NSString stringWithFormat:@"%@ %@",column,proType];
        NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ ",tableName,fieldSql];
        block(sqlString);//返回add列的sql语句
    }
}





/**
 * dbPathByString 根据名称生成数据库的路径
 * tableNameByModelClass 根据class生成表名
 */
- (NSString *)dbPathByString:(NSString *)sqlLibName{
    NSString *pathString = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //拼接document
    NSFileManager *filemanage = [NSFileManager defaultManager];
    pathString = [pathString stringByAppendingPathComponent:@"XYTool"];
    BOOL isDir;
    BOOL exit =[filemanage fileExistsAtPath:pathString isDirectory:&isDir];
    //    BOOL success = false;
    if (!exit || !isDir) {
        [filemanage createDirectoryAtPath:pathString withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *dbpath = nil;
    if (sqlLibName == nil || sqlLibName.length == 0) {
        dbpath = [pathString stringByAppendingPathComponent:@"tool.db"];
    } else {
        dbpath = [pathString stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",sqlLibName]];
    }
    NSLog(@"数据库路径：%@",dbpath);
    return dbpath;
}
- (NSString *)tableNameByModelClass:(Class)modelClass{
    NSString *className = NSStringFromClass(modelClass);
    return className;
}

//MARK:- sql 语句
//MARK: 查找
- (NSString *)searchModelToFmdbWithModelClass:(Class)modelClass
                            AndInfoDictionary:(NSDictionary *)infoDictionary
                                AndSortColumn:(NSString *)sortName
                                  AndSortType:(Sql_Sort_Type)sortType{
    
    NSMutableString *sqlString = [NSMutableString string];
    NSArray *proNamesArray = infoDictionary.allKeys;
    NSString *tableName = NSStringFromClass(modelClass);
    
    //查找全部
    if (!infoDictionary) {
        return [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
    }
    //条件查询
    for (int i = 0; i<proNamesArray.count; i++) {
        NSString *proname = proNamesArray[i];
        id provalue = infoDictionary[proname];
        if ([[provalue class] isSubclassOfClass:[NSString class]]) {
            [sqlString appendFormat:@"SELECT * FROM %@ WHERE %@='%@'",tableName, proname,provalue];
        }else{
            [sqlString appendFormat:@"SELECT * FROM %@ WHERE %@=%@",tableName, proname,provalue];
        }
        if(i+1 != proNamesArray.count)
       {
            [sqlString appendString:@","];
        }else{
            if (sortName != nil && sortName.length > 0){
                [sqlString appendFormat:@" ORDER BY \"%@\"",sortName];
            }
            if (sortType == Sql_Sort_Type_Desc){
                [sqlString appendString:@" DESC"];
            }else if (sortType == Sql_Sort_Type_Asc){
                //默认升序
            }
        }
    }
    return sqlString;
}

//MARK:- 此方法生成sql语句，以及与sql匹配的value数组
- (void)addModelToFmdbWithModel:(NSObject <APSQLProtocol>*)model
                AndIgnoreColumn:(NSArray <NSString*>*)ignoreColumn
                      AndResult:(SQL_AddModelBlock)block{
    
    NSString *tableName = NSStringFromClass(model.class);
    NSMutableString *keyString = [NSMutableString string];
    NSMutableString *valueString = [NSMutableString string];
    NSMutableArray *insertValues = [NSMutableArray  array];
    
    //属性名 字典
    NSDictionary *propertysDictionary = [self getPropertysDictionaryByModelClass:model.class];
    NSArray *proNamesArray = propertysDictionary.allKeys;
    for (int i = 0; i < proNamesArray.count; i++) {
        NSString *proname = proNamesArray[i];
        
        BOOL isHaveIgnore = NO;
        for (NSString *column in ignoreColumn){
            if ([proname isEqualToString:column]){
                isHaveIgnore = YES;
            }
        }
        if (isHaveIgnore) { continue;}
        
        [keyString appendFormat:@"'%@'", proname];
        [valueString appendString:@"?"];
        if(i+1 != proNamesArray.count){
            [keyString appendString:@","];
            [valueString appendString:@","];
        }
        
        id value = [model valueForKey:proname];
        if (!value) {
            value = @"";
        }
        [insertValues addObject:value];
    }
    
    NSString *sqlString = [NSString stringWithFormat:@"INSERT OR IGNORE INTO %@(%@) VALUES (%@);", tableName, keyString, valueString];
    block(sqlString,insertValues);
}


//MARK:- 删除操作 通过model的delegate 获取 主键 通过主键删除;
- (void)removeModelToFmdbWithModel:(NSObject <APSQLProtocol>*)model
                         AndResult:(SQL_AddModelBlock)block{
    NSString *tableName = NSStringFromClass(model.class);
    NSString *mainKeyString = [self mainKeyByClass:model.class];
    id value = [model valueForKey:mainKeyString];
    
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",tableName,mainKeyString];
    block(sqlString,@[value]);
}

/**
 * 修改（根据主键更新）
 * 通过model的delegate获取主键
 *
 *
 */
- (void)updateModelToFmdbWithModel:(NSObject <APSQLProtocol>*)model
                   AndIgnoreColumn:(NSArray <NSString*>*)ignoreColumn
                         AndResult:(SQL_AddModelBlock)block{
    NSString *tableName = NSStringFromClass(model.class);
    NSString *mainKeyString = [self mainKeyByClass:model.class];
    NSMutableString *keyString = [NSMutableString string];
    NSMutableArray *updateValues = [NSMutableArray  array];
    
    //属性名 字典
    NSDictionary *propertysDictionary = [self getPropertysDictionaryByModelClass:model.class];
    NSArray *proNamesArray = propertysDictionary.allKeys;
    
    for (int i = 0; i < proNamesArray.count; i++) {
        NSString *proname = proNamesArray[i];
        
        BOOL isHaveIgnore = NO;
        for (NSString *column in ignoreColumn){
            if ([proname isEqualToString:column]){
                isHaveIgnore = YES;
            }
        }
        if (isHaveIgnore) { continue;}
        
        [keyString appendFormat:@"'%@'=?", proname];
        if(i+1 != proNamesArray.count){
            [keyString appendString:@","];
        }
        
        id value = [model valueForKey:proname];
        if (!value) {
            value = @"";
        }
        [updateValues addObject:value];
    }
    
    NSString *sqlString = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = ?;", tableName, keyString, mainKeyString];
    //别忘了 补上主键对应的————值
    id primaryValue = [model valueForKey:mainKeyString];
    [updateValues addObject:primaryValue];
    block(sqlString,updateValues);
}


//MARK:- 更新指定字段的 某些字段数据
- (NSString *)updateModelClass:(Class)modelClass
                        AndDic:(NSDictionary *)updateDic
                      forWhere:(NSDictionary *)whereDic{
    
    NSString *tableName = NSStringFromClass(modelClass);
    
    NSMutableString *keyString = [NSMutableString string];
    for (NSString *proName in updateDic.allKeys) {
        [keyString appendFormat:@"%@ = '%@',", proName,updateDic[proName]];
    }
    NSRange range = NSMakeRange(keyString.length-1, @",".length);
    [keyString deleteCharactersInRange:range];
    
    NSMutableString *mainKeyString = [NSMutableString string];
    for (NSString *where in whereDic.allKeys) {
        [mainKeyString appendFormat:@" %@ = '%@' AND", where,whereDic[where]];
    }
    
    range = NSMakeRange(mainKeyString.length-3, @"AND".length);
    [mainKeyString deleteCharactersInRange:range];
    
    NSString *sqlString = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@;", tableName, keyString, mainKeyString];
    NSLog(@"%@", sqlString);
    return sqlString;
    
}

//MARK:- 根据给定名称创建表
- (NSString *)createSQLTableByModelClass:(Class)modelClass AndTableName:(NSString *)tableName{
    
    NSString *sqlTableName;
    if (sqlTableName == nil || tableName.length <= 0){
        sqlTableName = NSStringFromClass(modelClass);
    }else{
        sqlTableName = tableName;
    }
    
    NSString *mainKeyString = [self mainKeyByClass:modelClass];
    //属性名 字典
    NSDictionary *propertysDictionary = [self getPropertysDictionaryByModelClass:modelClass];
    NSString *columeAndTypeString = [self getColumeAndTypeString:propertysDictionary WithMainKey:mainKeyString];
    
    NSString *sqlString = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@);",sqlTableName,columeAndTypeString];
    return sqlString;
}


- (NSString *)SQLTableHaveByModelClass:(Class)modelClass{
    //NSString *tableName = [self tableNameByModelClass:modelClass];
    
    //    NSString *sqlString = [NSString stringWithFormat:@"select count(*) as 'count' from sqlite_master where type ='table' and name = %@", tableName];
    
    NSString *sqlString = [NSString stringWithFormat:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?"];
    return sqlString;
}
//MARK:- 根据类名创建表
- (NSString *)createSQLTableByModelClass:(Class)modelClass{
    return [self createSQLTableByModelClass:modelClass AndTableName:nil];
}





- (NSObject <APSQLProtocol> *)modelByModelClass:(Class)modelClass AndGetModelValueBlock:(GetModelValueBlock)block{
    //属性名 字典
    NSDictionary *propertysDictionary = [self getPropertysDictionaryByModelClass:modelClass];
    NSArray *proNamesArray = propertysDictionary.allKeys;
    NSObject <APSQLProtocol> *model = [[modelClass alloc] init];
    
    for (int i = 0; i<proNamesArray.count; i++) {
        NSString *proname = proNamesArray[i];
        NSString *protype = propertysDictionary[proname];
        if ([protype isEqualToString:SQLTEXT]) {
            [model setValue:block(proname,Property_Type_String) forKey:proname];
        } else if ([protype isEqualToString:SQLBLOB]) {
            [model setValue:block(proname,Property_Type_Data) forKey:proname];
        } else {
            [model setValue:block(proname,Property_Type_Longlong) forKey:proname];
        }
    }
    return model;
}

//MARK:- 获取对象所有属性
/**
 * 类也是一个对象
 * http://blog.csdn.net/yohunl/article/details/51799784 理解
 * - (BOOL)respondsToSelector:(SEL)aSelector; 一个类的实例是否能够响应某个方法
 * + (BOOL)instancesRespondToSelector:(SEL)aSelector; 某个类是否响应其中一个方法
 * - (BOOL)conformsToProtocol:(Protocol *)aProtocol 一个类的实例是否遵循某个协议
 * + (BOOL)conformsToProtocol:(Protocol *)aProtocol 一个类是否遵循某个协议
 */
- (NSDictionary *)getPropertysDictionaryByModelClass:(Class)modelClass{
    NSArray *transientsArray = nil;
    NSMutableDictionary *propertysMuDic = [NSMutableDictionary dictionary];
    if ([modelClass respondsToSelector:@selector(transients)]) {//相应类方法
        transientsArray = [modelClass transients];
    }
    unsigned int outCount, i;
    
    objc_property_t *properties = class_copyPropertyList(modelClass, &outCount);
    
    if (outCount == 4) {
        Class aa = class_getSuperclass(modelClass);
        properties = class_copyPropertyList(aa, &outCount);
    }
    
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        //获取属性名
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if ([propertyName isEqualToString:@"description"]) {
            continue;
        }
        if ([propertyName isEqualToString:@"debugDescription"]) {
            continue;
        }
        if ([propertyName isEqualToString:@"hash"]) {
            continue;
        }
        if ([propertyName isEqualToString:@"superclass"]) {
            continue;
        }
        //        if ([propertyName isEqualToString:NSStringFromSelector(@selector(classMappingDictionary))]) {
        //            continue;
        //        }
        if ([transientsArray containsObject:propertyName]) {
            continue;
        }
        //获取属性类型等参数
        NSString *propertyType = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
        /*
         各种符号对应类型，部分类型在新版SDK中有所变化，如long 和long long
         c char         C unsigned char
         i int          I unsigned int
         l long         L unsigned long
         s short        S unsigned short
         d double       D unsigned double
         f float        F unsigned float
         q long long    Q unsigned long long
         B BOOL
         @ 对象类型 //指针 对象类型 如NSString 是@“NSString”
         
         64位下long 和long long 都是Tq
         SQLite 默认支持五种数据类型TEXT、INTEGER、REAL、BLOB、NULL
         因为在项目中用的类型不多，故只考虑了少数类型
         */
        NSString *typeString = nil;
        if ([propertyType hasPrefix:@"T@\"NSString\""]) {
            typeString = SQLTEXT;
        } else if ([propertyType hasPrefix:@"T@\"NSData\""]) {
            typeString = SQLBLOB;
        } else if ([propertyType hasPrefix:@"Ti"]||[propertyType hasPrefix:@"TI"]||[propertyType hasPrefix:@"Ts"]||[propertyType hasPrefix:@"TS"]||[propertyType hasPrefix:@"TB"]||[propertyType hasPrefix:@"Tq"]||[propertyType hasPrefix:@"TQ"]) {
            typeString = SQLINTEGER;
        } else {
            typeString = SQLREAL;
        }
        propertysMuDic[propertyName] = typeString;
    }
    free(properties);
    [self mainKeySetSuccseeful:propertysMuDic AndModelClass:modelClass];
    return propertysMuDic;
}



//MARK:- 辅助方法
- (NSString *)getColumeAndTypeString:(NSDictionary *)dictionary WithMainKey:(NSString *)mainKeyString{
    NSMutableString* pars = [NSMutableString string];
    NSArray *proNames = dictionary.allKeys;
    for (int i=0; i< proNames.count; i++) {
        NSString *proname = proNames[i];
        NSString *protype = dictionary[proname];
        if ([proname isEqualToString:mainKeyString]) {
            [pars appendString:[NSString stringWithFormat:@"%@ %@ %@",mainKeyString,protype,PrimaryKey]];
        }else{
            [pars appendFormat:@"%@ %@",proname,protype];
        }
        if(i+1 != proNames.count)
       {
            [pars appendString:@","];
        }
    }
    return pars;
}


- (void)mainKeySetSuccseeful:(NSDictionary *)proDictioary AndModelClass:(Class)modelClass{
    NSString *mainKey = [self mainKeyByClass:modelClass];
    if (![proDictioary.allKeys containsObject:mainKey]) {
        //抛出异常
        XY_Exception(NSStringFromClass(modelClass),@"％@主键的设置")
    }
}

- (NSString *)mainKeyByClass:(Class)modelClass{
    if ([modelClass respondsToSelector:@selector(transients)]) {//相应类方法
        return [modelClass mainKey];
    }
    NSString *mainKey = [[[modelClass alloc] init] mainKey];
    if (mainKey.length == 0) {
        //抛出异常
        XY_Exception(NSStringFromClass(modelClass),@"必须至少实现一个获取主键的方法")
    }
    return mainKey;
}
@end
