//
//  XWDatabase.h
//  XWDatabase
//
//  Created by 邱学伟 on 2018/11/29.
//  Copyright © 2018 邱学伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWDatabaseModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^XWDatabaseCompletion)(BOOL isSuccess);                    /// 操作回调
typedef void(^XWDatabaseReturnSql)(NSString *sql);                      /// 生成 Sql 语句
typedef void(^XWDatabaseReturnObject)(id _Nullable obj);                /// 返回对象
typedef void(^XWDatabaseReturnObjects)(NSArray * _Nullable objs);       /// 返回对象数组

@interface XWDatabase : NSObject

/**
 根据模型创建数据库表
 
 @param cls 模型类
 @completion 是否创建数据库表 成功/失败
 */
+ (void)creatTableFromClass:(Class<XWDatabaseModelProtocol>)cls completion:(XWDatabaseCompletion)completion;

#pragma mark - 增
/**
 保存模型
 
 @param obj 模型
 @param completion 保存 成功/失败
 */
+ (void)saveModel:(NSObject <XWDatabaseModelProtocol>*)obj completion:(XWDatabaseCompletion)completion;

/**
 保存模型数组
 
 @param objs 模型数组
 @param completion 保存 成功/失败
 */
+ (void)saveModels:(NSArray < NSObject <XWDatabaseModelProtocol>* > *)objs completion:(XWDatabaseCompletion)completion;

#pragma mark - 删
/**
 删除指定模型
 
 @param obj 模型 (主键不能为空)
 @param completion 成功/失败
 */
+ (void)deleteModel:(NSObject <XWDatabaseModelProtocol>*)obj completion:(XWDatabaseCompletion)completion;

/**
 删除指定模型所有数据
 
 @param cls 模型类
 @param completion 成功/失败
 */
+ (void)clearModel:(Class<XWDatabaseModelProtocol>)cls completion:(XWDatabaseCompletion)completion;

#pragma mark - 改
/**
 更新现有表结构 (增删字段,数据迁移)
 
 @param cls 模型类
 @param completion 是否更新成功
 */
+ (void)updateTable:(Class<XWDatabaseModelProtocol>)cls completion:(XWDatabaseCompletion)completion;

#pragma mark - 查
/**
 查询模型
 
 @param obj 查询对象(必须保证主键 不为空)
 @param completion 结果
 */
+ (void)getModel:(NSObject <XWDatabaseModelProtocol>*)obj completion:(XWDatabaseReturnObject)completion;

/**
 查询模型数组
 
 @param cls 模型类
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls completion:(XWDatabaseReturnObjects)completion;

/**
 查询模型数组 - 按某字段排序
 
 @param cls 模型类
 @param sortColum 排序字段
 @param isOrderDesc 是否降序
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls sortColum:(NSString *)sortColum isOrderDesc:(BOOL)isOrderDesc completion:(XWDatabaseReturnObjects)completion;

/**
 查询模型数组 - 自定义条件
 
 @param cls 模型类
 @param condition 条件 (name like '%学伟')
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls condition:(NSString *)condition completion:(XWDatabaseReturnObjects)completion;

/**
 查询模型数组 - 自定义条件 + 按某字段排序
 
 @param cls 模型类
 @param sortColum 排序字段
 @param isOrderDesc 是否降序
 @param condition 条件
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls sortColum:(NSString * _Nullable)sortColum isOrderDesc:(BOOL)isOrderDesc condition:(NSString * _Nullable)condition completion:(XWDatabaseReturnObjects)completion;
@end

NS_ASSUME_NONNULL_END
