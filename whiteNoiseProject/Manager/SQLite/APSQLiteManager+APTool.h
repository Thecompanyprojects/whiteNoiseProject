
#import "APSQLiteManager.h"

#import "APClassModel.h"

static NSString *const MusicInfoUpdateFinishNotification = @"MusicInfoUpdateFinishNotification";

@interface APSQLiteManager (APTool)

/**
 保存类目信息
 
 @param dic dic description
 */
- (void)saveClassesInfo:(NSDictionary *)dic;
/**
 保存音乐信息
 
 @param dic dic description
 */
- (void)saveInfo:(NSDictionary *)dic;

- (void)saveFileRecord:(NSString *)url AndFileName:(NSString *)fimeName;


/**
 获取分类目录
 
 @return return value description
 */
- (NSArray <APClassModel *>*)getClassesModels;


/**
 获取对应分类目录下的音乐文件
 
 @param model model description
 @return return value description
 */
- (NSArray <MusicInfo *>*)getMusicListFromType:(APClassModel *)model;

/**
 把已购买ID更新
 
 @param productId productId description
 */
- (void)savePurchasedProduct:(NSString *)productId;
@end
