
#import "APSQLBlock.h"
typedef NS_ENUM(NSInteger) {
    Sql_Sort_Type_None = 0,
    Sql_Sort_Type_Desc = 1, //降序
    Sql_Sort_Type_Asc = 2,  //升序
}Sql_Sort_Type;


/**
 * 成功：返回yes，fireModelArray ＝ nil；
 * 失败：返回no ，fireModelArray ！＝ nil；
 */
typedef void(^SQL_ResultBlock)(BOOL successful,NSArray *fireModelArray);


/**
 * SQLAddModelBlock  增添
 *
 *
 */
typedef void(^SQL_AddModelBlock)(NSString *sqlString,NSArray *valueArray);

/**
 * GetModelValueBlock
 *
 *
 */
typedef NS_ENUM(NSInteger){
    Property_Type_String = 1,
    Property_Type_Data = 2,
    Property_Type_Longlong = 3
}Property_Type;
typedef id (^GetModelValueBlock)(NSString *columeName,Property_Type type);


/**
 * AddPropertyBlcok 添加 行列的 block
 *
 *
 */
typedef void (^SQL_AddPropertyBlcok)(NSString *sqlString);
