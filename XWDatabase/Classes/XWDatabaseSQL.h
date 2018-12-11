//
//  XWDatabaseSQL.h
//  XWDatabase
//
//  Created by 邱学伟 on 2018/12/1.
//  Copyright © 2018 邱学伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWDatabaseModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface XWDatabaseSQL : NSObject

#pragma mark - 增
/**
 保存单个对象SQL
 
 @param obj 模型
 @return 保存单个对象SQL
 */
+ (NSString *)saveOneObjSql:(NSObject <XWDatabaseModelProtocol> *)obj;

/**
 批量更新主键SQLS
 
 @param cls 模型
 @return 批量更新主键SQLS
 */
+ (NSArray *)insertPrimarys:(Class<XWDatabaseModelProtocol>)cls;

#pragma mark - 删
#pragma mark - 改
#pragma mark - 查

/**
 建表SQL
 
 @param cls 类
 @param isTtemporary 临时表
 @return 建表 sql
 */
+ (NSString *)createTableSql:(Class<XWDatabaseModelProtocol>)cls isTtemporary:(BOOL)isTtemporary;

/**
 数据库已存在表的建表语句
 
 @param cls 类
 @return 表 建表语句
 */
+ (NSString *)queryCreateTableSql:(Class<XWDatabaseModelProtocol>)cls;

/**
 查找某主键对象
 
 @param obj 模型
 @return 查找语句
 */
+ (NSString *)searchSql:(NSObject <XWDatabaseModelProtocol> *)obj;

/**
 查询表内所有数据 (可按照某字段排序)
 
 @param cls 模型
 @param sortColumn 排序字段
 @param isOrderDesc 是否降序
 @param condition 自定义条件
 @return 符合条件的表内所有数据
 */
+ (NSString *)searchSql:(Class<XWDatabaseModelProtocol>)cls sortColumn:(NSString *)sortColumn isOrderDesc:(BOOL)isOrderDesc condition:(NSString *)condition;

/**
 查找某条数据d是否存在
 
 @param obj 模型
 @return 是否存在
 */
+ (NSString *)isExistSql:(NSObject <XWDatabaseModelProtocol> *)obj;


/**
 更新单个对象SQL
 
 @param obj 模型
 @return 保存单个对象SQL
 */
+ (NSString *)updateOneObjSql:(NSObject <XWDatabaseModelProtocol> *)obj;

/**
 更新单个对象SQL
 
 @param obj 模型
 @param updatePropertys 自定义更新的字段
 @return 保存单个对象SQL
 */
+ (NSString *)updateOneObjSql:(NSObject <XWDatabaseModelProtocol>*)obj updatePropertys:(NSArray <NSString *> *)updatePropertys;

/**
 更新字段值 SQL
 
 @param cls 类
 @param columName 字段名
 @return 更新字段值 SQL
 */
+ (NSString *)updateColumn:(Class<XWDatabaseModelProtocol>)cls columName:(NSString *)columName;

/**
 删除表 SQL
 
 @param cls 类
 @return 删除表 SQL
 */
+ (NSString *)dropTable:(Class<XWDatabaseModelProtocol>)cls;

/**
 表重命名 SQL
 
 @param cls 类
 @return 表重命名 SQL
 */
+ (NSString *)renameTable:(Class<XWDatabaseModelProtocol>)cls;

/**
 删除表中某条数据
 
 @param obj 模型
 @return 是否删除成功
 */
+ (NSString *)deleteColumn:(NSObject <XWDatabaseModelProtocol> *)obj;

/**
 清空表中所有字段
 
 @param cls 模型类
 @param condition 条件
 @return 是否删除成功
 */
+ (NSString *)clearColumn:(Class<XWDatabaseModelProtocol>)cls condition:(NSString * _Nullable )condition;

@end

NS_ASSUME_NONNULL_END
