//
//  XWDatabase.h
//  XWDatabase
//
//  Created by 邱学伟 on 2018/11/29.
//  Copyright © 2018 邱学伟. All rights reserved.
//  V 1.1

#import <Foundation/Foundation.h>
#import "XWDatabaseModelProtocol.h"
@class FMResultSet;

NS_ASSUME_NONNULL_BEGIN

typedef void(^XWDatabaseCompletion)(BOOL isSuccess);                        /// 操作回调
typedef void(^XWDatabaseReturnObject)(id _Nullable obj);                    /// 返回对象
typedef void(^XWDatabaseReturnObjects)(NSArray * _Nullable objs);           /// 返回对象数组
typedef void(^XWDatabaseReturnResultSet)(FMResultSet * _Nullable resultSet);/// 返回 FMResultSet 原生查询结果-需自己解析

@interface XWDatabase : NSObject

#pragma mark - 增
/**
 保存模型 (表中不存在插入, 已存在更新)
 
 @param obj 模型
 @param completion 保存 成功/失败
 */
+ (void)saveModel:(NSObject <XWDatabaseModelProtocol>*)obj completion:(XWDatabaseCompletion _Nullable)completion;

/**
 保存模型 (表中不存在插入, 已存在更新) - 标示符区分
 
 @param obj 模型
 @param identifier 唯一标识,用于区分不同数据组 (如: userID), 若模型无主键或联合主键则会统一插入数据
 @param completion 保存 成功/失败
 */
+ (void)saveModel:(NSObject <XWDatabaseModelProtocol>*)obj identifier:(NSString * _Nullable)identifier completion:(XWDatabaseCompletion _Nullable)completion;

/**
 保存模型数组
 
 @param objs 模型数组
 @param completion 保存 成功/失败
 */
+ (void)saveModels:(NSArray < NSObject <XWDatabaseModelProtocol>* > *)objs completion:(XWDatabaseCompletion _Nullable)completion;

/**
 保存模型数组 - 标示符区分
 
 @param objs 模型数组
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param completion 保存 成功/失败
 */
+ (void)saveModels:(NSArray < NSObject <XWDatabaseModelProtocol>* > *)objs identifier:(NSString * _Nullable)identifier completion:(XWDatabaseCompletion _Nullable)completion;


#pragma mark - 删
/**
 删除指定某个模型, 主键不能为空
 
 @param obj 模型 (主键不能为空)
 @param completion 成功/失败
 */
+ (void)deleteModel:(NSObject <XWDatabaseModelProtocol>*)obj completion:(XWDatabaseCompletion _Nullable)completion;

/**
 删除指定某个模型, 主键不能为空 - 标示符区分
 
 @param obj 模型
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param completion 成功/失败
 */
+ (void)deleteModel:(NSObject <XWDatabaseModelProtocol>*)obj identifier:(NSString * _Nullable)identifier completion:(XWDatabaseCompletion _Nullable)completion;

/**
 删除指定模型所有数据
 
 @param cls 模型类
 @param completion 成功/失败
 */
+ (void)clearModel:(Class<XWDatabaseModelProtocol>)cls completion:(XWDatabaseCompletion _Nullable)completion;

/**
 删除指定模型所有数据 - 标示符区分
 
 @param cls 模型类
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param completion 成功/失败
 */
+ (void)clearModel:(Class<XWDatabaseModelProtocol>)cls identifier:(NSString * _Nullable)identifier completion:(XWDatabaseCompletion _Nullable)completion;

/**
 删除指定模型所有数据 - 自定义条件
 
 @param cls 模型类
 @param condition 自定义条件 (为空删除所有数据,有值根据自定义的条件删除 eg: 条件 (age > 60) )
 @param completion 成功/失败
 */
+ (void)clearModel:(Class<XWDatabaseModelProtocol>)cls condition:(NSString * _Nullable)condition completion:(XWDatabaseCompletion _Nullable)completion;

/**
 删除指定模型所有数据 - 自定义条件 - 标示符区分
 
 @param cls 模型类
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param condition 自定义条件 (为空删除所有数据,有值根据自定义的条件删除)
 @param completion 成功/失败
 */
+ (void)clearModel:(Class<XWDatabaseModelProtocol>)cls identifier:(NSString * _Nullable)identifier condition:(NSString * _Nullable)condition completion:(XWDatabaseCompletion _Nullable)completion;

#pragma mark - 改
/**
 更新现有表结构 (增删字段,数据迁移)
 
 @param cls 模型类
 @param completion 是否更新成功
 */
+ (void)updateTable:(Class<XWDatabaseModelProtocol>)cls completion:(XWDatabaseCompletion _Nullable)completion;

/**
 更新模型
 
 @param obj 模型 (主键(或联合主键)不能为空)
 @param updatePropertys 所更新的字段数组 (若为 nil -> 全量更新)
 @param completion 保存 成功/失败
 */
+ (void)updateModel:(NSObject <XWDatabaseModelProtocol>*)obj updatePropertys:(NSArray <NSString *> * _Nullable)updatePropertys completion:(XWDatabaseCompletion _Nullable)completion;

/**
 更新模型 - 标示符区分
 
 @param obj 模型 (主键(或联合主键)不能为空)
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param updatePropertys 所更新的字段数组 (无自定义全量更新)
 @param completion 保存 成功/失败
 */
+ (void)updateModel:(NSObject <XWDatabaseModelProtocol>*)obj identifier:(NSString * _Nullable)identifier updatePropertys:(NSArray <NSString *> * _Nullable)updatePropertys completion:(XWDatabaseCompletion _Nullable)completion;

/**
 更新模型数组
 
 @param objs 模型数组 (主键(或联合主键)不能为空)
 @param updatePropertys 所更新的字段数组 (若为 nil -> 全量更新)
 @param completion 保存 成功/失败
 */
+ (void)updateModels:(NSArray < NSObject <XWDatabaseModelProtocol>* > *)objs updatePropertys:(NSArray <NSString *> * _Nullable)updatePropertys completion:(XWDatabaseCompletion _Nullable)completion;

/**
 更新模型数组 - 标示符区分
 
 @param objs 模型数组 (主键(或联合主键)不能为空)
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param updatePropertys 所更新的字段数组 (若为 nil -> 全量更新)
 @param completion 保存 成功/失败
 */
+ (void)updateModels:(NSArray < NSObject <XWDatabaseModelProtocol>* > *)objs identifier:(NSString * _Nullable)identifier updatePropertys:(NSArray <NSString *> * _Nullable)updatePropertys completion:(XWDatabaseCompletion _Nullable)completion;

/**
 更新模型数组,自定义更新条件
 
 @param obj 模型
 @param updatePropertys 所更新的字段数组 (若为 nil -> 全量更新)
 @param condition 条件 (自定义条件不能为空!)
 @param completion 保存 成功/失败
 */
+ (void)updateModels:(NSObject *)obj updatePropertys:(NSArray <NSString *> * _Nullable)updatePropertys condition:(NSString * _Nullable)condition completion:(XWDatabaseCompletion _Nullable)completion;

/**
 更新模型数组,自定义更新条件 - 标示符区分
 
 @param obj 模型
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param updatePropertys 所更新的字段数组 (若为 nil -> 全量更新)
 @param condition 条件 (自定义条件不能为空!)
 @param completion 保存 成功/失败
 */
+ (void)updateModels:(NSObject *)obj identifier:(NSString * _Nullable)identifier updatePropertys:(NSArray <NSString *> * _Nullable)updatePropertys condition:(NSString * _Nullable)condition completion:(XWDatabaseCompletion _Nullable)completion;

#pragma mark - 查
/**
 查询模型
 
 @param obj 查询对象(必须保证主键 不为空/或唯一标识属性 不为空)
 @param completion 结果
 */
+ (void)getModel:(NSObject <XWDatabaseModelProtocol>*)obj completion:(XWDatabaseReturnObject _Nullable)completion;

/**
 查询模型 - 标示符区分 (主键不可为空)
 
 @param obj 查询对象(必须保证主键 不为空)
 @param identifier 唯一标识,用于区分不同数据组 (如: userID), 若模型无 主键或联合主键 不会获取到任何结果 可使用 '
 @selector(getModels:identifier:completion:)' 获取模型数组
 @param completion 结果
 */
+ (void)getModel:(NSObject <XWDatabaseModelProtocol>*)obj identifier:(NSString * _Nullable)identifier completion:(XWDatabaseReturnObject _Nullable)completion;

/**
 查询模型数组
 
 @param cls 模型类
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls completion:(XWDatabaseReturnObjects _Nullable)completion;

/**
 查询模型数组 - 标示符区分
 
 @param cls 模型类
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls identifier:(NSString * _Nullable)identifier completion:(XWDatabaseReturnObjects _Nullable)completion;

/**
 查询模型数组 - 自定义条件
 
 @param cls 模型类
 @param condition 条件 (name like '%学伟')
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls condition:(NSString * _Nullable)condition completion:(XWDatabaseReturnObjects _Nullable)completion;

/**
 查询模型数组 - 自定义条件 - 标示符区分
 
 @param cls 模型类
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param condition 条件
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls identifier:(NSString * _Nullable)identifier condition:(NSString * _Nullable)condition completion:(XWDatabaseReturnObjects _Nullable)completion;


/**
 查询模型数组 - 按某字段排序
 
 @param cls 模型类
 @param sortColumn 排序字段
 @param isOrderDesc 是否降序 (YES: 降序  NO: 升序)
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls sortColumn:(NSString * _Nullable)sortColumn isOrderDesc:(BOOL)isOrderDesc completion:(XWDatabaseReturnObjects _Nullable)completion;

/**
 查询模型数组 - 按某字段排序 - 标示符区分
 
 @param cls 模型类
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param sortColumn 排序字段
 @param isOrderDesc 是否降序 (YES: 降序  NO: 升序)
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls identifier:(NSString * _Nullable)identifier sortColumn:(NSString * _Nullable)sortColumn isOrderDesc:(BOOL)isOrderDesc completion:(XWDatabaseReturnObjects _Nullable)completion;

/**
 查询模型数组 - 自定义条件 + 按某字段排序
 
 @param cls 模型类
 @param sortColumn 排序字段
 @param isOrderDesc 是否降序 (YES: 降序  NO: 升序)
 @param condition 条件
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls sortColumn:(NSString * _Nullable)sortColumn isOrderDesc:(BOOL)isOrderDesc condition:(NSString * _Nullable)condition completion:(XWDatabaseReturnObjects _Nullable)completion;

/**
 查询模型数组 - 自定义条件 + 按某字段排序 - 标示符区分
 
 @param cls 模型类
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param sortColumn 排序字段
 @param isOrderDesc 是否降序
 @param condition 条件
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls identifier:(NSString * _Nullable)identifier sortColumn:(NSString * _Nullable)sortColumn isOrderDesc:(BOOL)isOrderDesc condition:(NSString * _Nullable)condition completion:(XWDatabaseReturnObjects _Nullable)completion;

#pragma mark - 执行自定义SQL语句

/**
 执行单条自定义 SQL 更新语句
 
 @param sql 自定义 SQL 更新语句
 @param completion 完成回调
 */
+ (void)executeUpdateSql:(NSString *)sql completion:(XWDatabaseCompletion _Nullable)completion;

/**
 执行多条自定义 SQL 更新语句
 
 @param sqls 多条自定义 SQL 更新语句
 @param completion 完成回调
 */
+ (void)executeUpdateSqls:(NSArray <NSString *> *)sqls completion:(XWDatabaseCompletion _Nullable)completion;

/**
 执行单条自定义 SQL 查询语句
 
 @param sql 自定义 SQL 查询语句
 @param completion 完成回调
 */
+ (void)executeQuerySql:(NSString *)sql completion:(XWDatabaseReturnResultSet _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
