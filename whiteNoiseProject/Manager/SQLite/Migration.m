//
//  Migration.m
//  Sound
//
//  Created by 郭连城 on 2018/8/2.
//  Copyright © 2018年 DDTR. All rights reserved.
//
#import "APSQLiteManagerHelper.h"
#import "Migration.h"
@interface Migration()
@property(nonatomic,copy)NSString * myName;
@property(nonatomic,assign)uint64_t myVersion;
@property(nonatomic,strong) NSArray * updateArray;
@property(nonatomic,strong) NSArray<NSDictionary *> *sqlUpdateDicArray;
@end


@implementation Migration

- (instancetype)initWithName:(NSString *)name
                  andVersion:(uint64_t)version
       andExecuteUpdateArray:(NSArray *)updateArray{
    if (self=[super init]) {
        _myName=name;
        _myVersion=version;
        _updateArray=updateArray;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name
                  andVersion:(uint64_t)version
    andExecuteUpdateDicArray:(NSArray *)sqlUpdateDicArray{
    if (self=[super init]) {
        _myName=name;
        _myVersion=version;
        _sqlUpdateDicArray=sqlUpdateDicArray;
    }
    return self;
}

- (NSString *)name{
    return _myName;
}

- (uint64_t)version{
    return _myVersion;
}

- (BOOL)migrateDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error{
    for(NSString * updateStr in _updateArray){
        [database executeUpdate:updateStr];
    }
    
    for(NSDictionary<NSString *,NSArray*> *dic in _sqlUpdateDicArray){
        for(NSString *sql in dic.allKeys){
            [database executeUpdate:sql withArgumentsInArray:dic[sql]];
        }
    }
    return YES;
}



@end
