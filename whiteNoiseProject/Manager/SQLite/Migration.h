
#import <FMDBMigrationManager.h>
#import <Foundation/Foundation.h>

@interface Migration : NSObject<FMDBMigrating>

- (instancetype)initWithName:(NSString *)name
                  andVersion:(uint64_t)version
       andExecuteUpdateArray:(NSArray *)updateArray;//自定义方法



- (instancetype)initWithName:(NSString *)name
                  andVersion:(uint64_t)version
    andExecuteUpdateDicArray:(NSArray *)sqlUpdateDicArray;


@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) uint64_t version;
- (BOOL)migrateDatabase:(FMDatabase *)database error:(out NSError *__autoreleasing *)error;


@end
