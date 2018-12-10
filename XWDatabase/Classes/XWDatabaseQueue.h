//
//  XWDatabaseQueue.h
//  XWDatabase
//
//  Created by 邱学伟 on 2018/12/1.
//  Copyright © 2018 邱学伟. All rights reserved.
//  FMDB 线程安全操作类

#import <Foundation/Foundation.h>
@class FMResultSet,FMDatabase;

NS_ASSUME_NONNULL_BEGIN

typedef void(^XWDatabaseQueueUpdateResult)(BOOL isSuccess);
typedef void(^XWDatabaseQueueQueryCountResult)(int count);
typedef void(^XWDatabaseQueueDatabaseHandle)(FMDatabase * _Nonnull database);
typedef void(^XWDatabaseQueueTransactionHandle)(FMDatabase * _Nonnull database, BOOL * _Nonnull rollback);
typedef void(^XWDatabaseQueueQueryResult)(FMResultSet * _Nullable resultSet);
typedef void(^XWDatabaseQueueQueryResults)(NSArray < FMResultSet *>  * _Nullable resultSets);

@interface XWDatabaseQueue : NSObject

/**
 单例

 @return 单例对象
 */
+ (instancetype)shareInstance;

/**
 数据库操作队列
 
 @param block 队列内操作
 */
- (void)inDatabase:(XWDatabaseQueueDatabaseHandle)block;

/**
 数据库事务操作队列
 
 @param block 队列内操作
 */
- (void)inTransaction:(XWDatabaseQueueTransactionHandle)block;

/**
 执行更新操作 (单语句)
 
 @param sql 所执行的 SQL
 @param database 数据库
 */
+ (BOOL)executeUpdateSql:(NSString *)sql database:(FMDatabase *)database;

/**
 执行查询操作 (单语句)
 
 @param sql 所执行的 SQL
 @param database 数据库
 */
+ (FMResultSet *)executeQuerySql:(NSString *)sql database:(FMDatabase *)database;

/**
 执行查询操作 (单语句)
 
 @param sql 所执行的 SQL
 @param database 数据库
 */
+ (void)executeStatementQuerySql:(NSString *)sql database:(FMDatabase *)database completion:(XWDatabaseQueueQueryCountResult)completion;

@end

NS_ASSUME_NONNULL_END
