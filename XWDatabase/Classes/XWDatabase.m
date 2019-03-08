//
//  XWDatabase.m
//  XWDatabase
//
//  Created by 邱学伟 on 2018/11/29.
//  Copyright © 2018 邱学伟. All rights reserved.
//

#import <FMDB/FMDB.h>
#import "XWDatabase.h"
#import "XWDatabaseSQL.h"
#import "XWLivingThread.h"
#import "XWDatabaseModel.h"
#import "XWDatabaseQueue.h"
#import "NSObject+XWModel.h"

@implementation XWDatabase

#pragma mark - public
#pragma mark  增
/**
 保存模型
 
 @param obj 模型
 @param completion 保存 成功/失败
 */
+ (void)saveModel:(NSObject <XWDatabaseModelProtocol>*)obj completion:(XWDatabaseCompletion _Nullable)completion {
    [self saveModel:obj identifier:nil completion:completion];
}

/**
 保存模型 (表中不存在插入, 已存在更新)
 
 @param obj 模型
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param completion 保存 成功/失败
 */
+ (void)saveModel:(NSObject <XWDatabaseModelProtocol>*)obj identifier:(NSString * _Nullable)identifier completion:(XWDatabaseCompletion _Nullable)completion {
    if (!obj) {
        completion ? completion(NO) : nil;
        return;
    }
    [XWLivingThread executeTaskInMain:^{
        [self p_saveModel:obj identifier:identifier completion:^(BOOL isSuccess) {
            completion ? completion(isSuccess) : nil;
        }];
    }];
}

/**
 保存模型数组
 
 @param objs 模型数组
 @param completion 保存 成功/失败
 */
+ (void)saveModels:(NSArray < NSObject <XWDatabaseModelProtocol>* > *)objs completion:(XWDatabaseCompletion _Nullable)completion {
    [self saveModels:objs identifier:nil completion:completion];
}

/**
 保存模型数组
 
 @param objs 模型数组
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param completion 保存 成功/失败
 */
+ (void)saveModels:(NSArray < NSObject <XWDatabaseModelProtocol>* > *)objs identifier:(NSString * _Nullable)identifier completion:(XWDatabaseCompletion _Nullable)completion {
    if (!objs || objs.count == 0) {
        completion ? completion(NO) : nil;
        return;
    }
    [XWLivingThread executeTaskInMain:^{
        [self p_saveModels:objs identifier:identifier completion:^(BOOL isSuccess) {
            completion ? completion(isSuccess) : nil;
        }];
    }];
}

#pragma mark  删
/**
 删除指定模型

 @param obj 模型 (主键不能为空)
 @param completion 成功/失败
 */
+ (void)deleteModel:(NSObject <XWDatabaseModelProtocol>*)obj completion:(XWDatabaseCompletion _Nullable)completion {
    [self deleteModel:obj identifier:nil completion:completion];
}

/**
 删除指定模型
 
 @param obj 模型
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param completion 成功/失败
 */
+ (void)deleteModel:(NSObject <XWDatabaseModelProtocol>*)obj identifier:(NSString * _Nullable)identifier completion:(XWDatabaseCompletion _Nullable)completion {
    if (!obj) {
        completion ? completion(NO) : nil;
        return;
    }
    [XWLivingThread executeTaskInMain:^{
        NSString *deleteColumnSql = [XWDatabaseSQL deleteColumn:obj identifier:identifier];
        if (!deleteColumnSql) {
            completion ? completion(NO) : nil;
            return;
        }
        [self p_executeUpdate:deleteColumnSql completion:completion];
    }];
}

/**
 删除指定模型所有数据
 
 @param cls 模型类
 @param completion 成功/失败
 */
+ (void)clearModel:(Class<XWDatabaseModelProtocol>)cls completion:(XWDatabaseCompletion _Nullable)completion {
    [self clearModel:cls identifier:nil condition:nil completion:completion];
}

/**
 删除指定模型所有数据
 
 @param cls 模型类
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param completion 成功/失败
 */
+ (void)clearModel:(Class<XWDatabaseModelProtocol>)cls identifier:(NSString * _Nullable)identifier completion:(XWDatabaseCompletion _Nullable)completion {
    [self clearModel:cls identifier:identifier condition:nil completion:completion];
}

/**
 删除指定模型所有数据
 
 @param cls 模型类
 @param condition 自定义条件 (为空删除所有数据,有值根据自定义的条件删除)
 @param completion 成功/失败
 */
+ (void)clearModel:(Class<XWDatabaseModelProtocol>)cls condition:(NSString * _Nullable)condition completion:(XWDatabaseCompletion _Nullable)completion {
    [self clearModel:cls identifier:nil condition:condition completion:completion];
}

/**
 删除指定模型所有数据
 
 @param cls 模型类
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param condition 自定义条件 (为空删除所有数据,有值根据自定义的条件删除)
 @param completion 成功/失败
 */
+ (void)clearModel:(Class<XWDatabaseModelProtocol>)cls identifier:(NSString * _Nullable)identifier condition:(NSString * _Nullable)condition completion:(XWDatabaseCompletion _Nullable)completion {
    if (!cls) {
        completion ? completion(NO) : nil;
        return;
    }
    [XWLivingThread executeTaskInMain:^{
        NSString *clearColumnSql = [XWDatabaseSQL clearColumn:cls identifier:identifier condition:condition];
        [self p_executeUpdate:clearColumnSql completion:completion];
    }];
}

#pragma mark  改
/**
 更新现有表结构 (增删字段,数据迁移)
 
 @param cls 模型类
 @param completion 是否更新成功
 */
+ (void)updateTable:(Class<XWDatabaseModelProtocol>)cls completion:(XWDatabaseCompletion _Nullable)completion {
    if (!cls) {
        completion ? completion(NO) : nil;
        return;
    }
    [XWLivingThread executeTaskInMain:^{
        [self p_updateTable:cls completion:completion];
    }];
}

/**
 更新模型
 
 @param obj 模型
 @param updatePropertys 所更新的字段数组 (无自定义全量更新)
 @param completion 保存 成功/失败
 */
+ (void)updateModel:(NSObject <XWDatabaseModelProtocol>*)obj updatePropertys:(NSArray <NSString *> * _Nullable)updatePropertys completion:(XWDatabaseCompletion _Nullable)completion {
    [self updateModel:obj identifier:nil updatePropertys:updatePropertys completion:completion];
}

/**
 更新模型
 
 @param obj 模型
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param updatePropertys 所更新的字段数组 (无自定义全量更新)
 @param completion 保存 成功/失败
 */
+ (void)updateModel:(NSObject <XWDatabaseModelProtocol>*)obj identifier:(NSString * _Nullable)identifier updatePropertys:(NSArray <NSString *> * _Nullable)updatePropertys completion:(XWDatabaseCompletion _Nullable)completion {
    if (!obj) {
        completion ? completion(NO) : nil;
        return;
    }
    [XWLivingThread executeTaskInMain:^{
        NSString *updateModelSQL = [XWDatabaseSQL updateOneObjSql:obj identifier:identifier updatePropertys:updatePropertys];
        if (!updateModelSQL) {
            completion ? completion(NO) : nil;
            return ;
        }
        [self p_executeUpdate:updateModelSQL completion:completion];
    }];
}

/**
 更新模型数组
 
 @param objs 模型数组
 @param updatePropertys 所更新的字段数组
 @param completion 保存 成功/失败
 */
+ (void)updateModels:(NSArray < NSObject <XWDatabaseModelProtocol>* > *)objs updatePropertys:(NSArray <NSString *> * _Nullable)updatePropertys completion:(XWDatabaseCompletion _Nullable)completion {
    [self updateModels:objs identifier:nil updatePropertys:updatePropertys completion:completion];
}

/**
 更新模型数组 - 标示符区分
 
 @param objs 模型数组
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param updatePropertys 所更新的字段数组 (若为 nil -> 全量更新)
 @param completion 保存 成功/失败
 */
+ (void)updateModels:(NSArray < NSObject <XWDatabaseModelProtocol>* > *)objs identifier:(NSString * _Nullable)identifier updatePropertys:(NSArray <NSString *> * _Nullable)updatePropertys completion:(XWDatabaseCompletion _Nullable)completion {
    if (!objs || !objs.count) {
        completion ? completion(NO) : nil;
        return;
    }
    [XWLivingThread executeTaskInMain:^{
        NSMutableArray *sqls = [NSMutableArray array];
        for (NSObject *obj in objs) {
            NSString *updateModelSQL = [XWDatabaseSQL updateOneObjSql:obj identifier:identifier updatePropertys:updatePropertys];
            if (updateModelSQL) {
                [sqls addObject:updateModelSQL];
            }
        }
        [self executeUpdateSqls:sqls completion:completion];
    }];
}


#pragma mark  查
/**
 查询模型
 
 @param obj 查询对象(必须保证主键 不为空)
 @param completion 结果
 */
+ (void)getModel:(NSObject <XWDatabaseModelProtocol>*)obj completion:(XWDatabaseReturnObject _Nullable)completion {
    [self getModel:obj identifier:nil completion:completion];
}

/**
 查询模型

 @param obj 查询对象(必须保证主键 不为空)
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param completion 结果
 */
+ (void)getModel:(NSObject <XWDatabaseModelProtocol>*)obj identifier:(NSString * _Nullable)identifier completion:(XWDatabaseReturnObject _Nullable)completion {
    if (!completion) {
        return;
    }
    if (!obj) {
        completion ? completion(nil) : nil;
        return;
    }
    
    [XWLivingThread executeTaskInMain:^{
        [self p_getModel:obj identifier:identifier completion:completion];
    }];
}

/**
 查询模型数组
 
 @param cls 模型类
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls completion:(XWDatabaseReturnObjects _Nullable)completion {
    [self getModels:cls sortColumn:nil isOrderDesc:NO condition:nil completion:completion];
}

/**
 查询模型数组
 
 @param cls 模型类
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls identifier:(NSString * _Nullable)identifier completion:(XWDatabaseReturnObjects _Nullable)completion {
    [self getModels:cls sortColumn:nil isOrderDesc:NO condition:nil completion:completion];
}

/**
 查询模型数组 - 自定义条件
 
 @param cls 模型类
 @param condition 条件
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls condition:(NSString * _Nullable)condition completion:(XWDatabaseReturnObjects _Nullable)completion {
    [self getModels:cls sortColumn:nil isOrderDesc:NO condition:condition completion:completion];
}

/**
 查询模型数组 - 自定义条件
 
 @param cls 模型类
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param condition 条件
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls identifier:(NSString * _Nullable)identifier condition:(NSString * _Nullable)condition completion:(XWDatabaseReturnObjects _Nullable)completion {
    [self getModels:cls sortColumn:nil isOrderDesc:NO condition:condition completion:completion];
}

/**
 查询模型数组 - 按某字段排序
 
 @param cls 模型类
 @param sortColumn 排序字段
 @param isOrderDesc 是否降序 (YES: 降序  NO: 升序)
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls sortColumn:(NSString * _Nullable)sortColumn isOrderDesc:(BOOL)isOrderDesc completion:(XWDatabaseReturnObjects _Nullable)completion {
    [self getModels:cls sortColumn:sortColumn isOrderDesc:isOrderDesc condition:nil completion:completion];
}

/**
 查询模型数组 - 按某字段排序
 
 @param cls 模型类
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param sortColumn 排序字段
 @param isOrderDesc 是否降序 (YES: 降序  NO: 升序)
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls identifier:(NSString * _Nullable)identifier sortColumn:(NSString * _Nullable)sortColumn isOrderDesc:(BOOL)isOrderDesc completion:(XWDatabaseReturnObjects _Nullable)completion {
    [self getModels:cls sortColumn:sortColumn isOrderDesc:isOrderDesc condition:nil completion:completion];
}

/**
 查询模型数组 - 自定义条件 + 按某字段排序
 
 @param cls 模型类
 @param sortColumn 排序字段
 @param isOrderDesc 是否降序
 @param condition 条件
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls sortColumn:(NSString * _Nullable)sortColumn isOrderDesc:(BOOL)isOrderDesc condition:(NSString * _Nullable)condition completion:(XWDatabaseReturnObjects _Nullable)completion {
    
    [self getModels:cls identifier:nil sortColumn:sortColumn isOrderDesc:isOrderDesc condition:condition completion:completion];
}

/**
 查询模型数组 - 自定义条件 + 按某字段排序
 
 @param cls 模型类
 @param identifier 唯一标识,用于区分不同数据组 (如: userID)
 @param sortColumn 排序字段
 @param isOrderDesc 是否降序
 @param condition 条件
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls identifier:(NSString * _Nullable)identifier sortColumn:(NSString * _Nullable)sortColumn isOrderDesc:(BOOL)isOrderDesc condition:(NSString * _Nullable)condition completion:(XWDatabaseReturnObjects _Nullable)completion {
    if (!completion) {
        return;
    }
    if (!cls) {
        completion ? completion(nil) : nil;
        return;
    }
    [XWLivingThread executeTaskInMain:^{
        [self p_getModels:cls identifier:identifier sortColumn:sortColumn isOrderDesc:isOrderDesc condition:condition completion:completion];
    }];
}

#pragma mark - 执行自定义SQL语句

/**
 执行单条自定义 SQL 更新语句

 @param sql 自定义 SQL 更新语句
 @param completion 完成回调
 */
+ (void)executeUpdateSql:(NSString *)sql completion:(XWDatabaseCompletion _Nullable)completion {
    if (!sql || sql.length == 0) {
        completion ? completion(NO) : nil;
        return;
    }
    [XWLivingThread executeTaskInMain:^{
        [self p_executeUpdate:sql completion:completion];
    }];
}

/**
 执行多条自定义 SQL 更新语句
 
 @param sqls 多条自定义 SQL 更新语句
 @param completion 完成回调
 */
+ (void)executeUpdateSqls:(NSArray <NSString *> *)sqls completion:(XWDatabaseCompletion _Nullable)completion {
    if (!sqls || sqls.count == 0) {
        completion ? completion(NO) : nil;
        return;
    }
    [XWLivingThread executeTaskInMain:^{
        [[XWDatabaseQueue shareInstance] inTransaction:^(FMDatabase * _Nonnull database, BOOL * _Nonnull rollback) {
            [sqls enumerateObjectsUsingBlock:^(NSString * sql, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![database executeUpdate:sql]) {
                    completion ? completion(NO) : nil;
                    *rollback = YES;
                    return ;
                }
                if (idx == sqls.count - 1) {
                    completion ? completion(YES) : nil;
                }
            }];
        }];
    }];
}

/**
 执行单条自定义 SQL 查询语句
 
 @param sql 自定义 SQL 查询语句
 @param completion 完成回调
 */
+ (void)executeQuerySql:(NSString *)sql completion:(XWDatabaseReturnResultSet _Nullable)completion {
    if (!sql || sql.length == 0) {
        completion ? completion(nil) : nil;
        return;
    }
    [XWLivingThread executeTaskInMain:^{
        [[XWDatabaseQueue shareInstance] inDatabase:^(FMDatabase * _Nonnull database) {
            FMResultSet *resultSet = [XWDatabaseQueue executeQuerySql:sql database:database];
            completion ? completion(resultSet) : nil;
        }];
    }];
}


#pragma mark - private
#pragma mark  增
+ (void)p_saveModel:(NSObject <XWDatabaseModelProtocol>*)obj identifier:(NSString * _Nullable)identifier completion:(XWDatabaseCompletion _Nullable)completion {
    
    [[XWDatabaseQueue shareInstance] inDatabase:^(FMDatabase * _Nonnull database) {
        
        if (![self p_createTable:obj.class database:database]) {
            completion ? completion(NO) : nil;
            return ;
        }
        
        /// 不存在直接插入
        void(^insertOperate)(void) = ^ {
            NSString *saveSql = [XWDatabaseSQL insertOneObjSql:obj identifier:identifier];
            BOOL isSuccess = [XWDatabaseQueue executeUpdateSql:saveSql database:database];
            completion ? completion(isSuccess) : nil;
        };
        
        NSString *searchSql = [XWDatabaseSQL isExistSql:obj identifier:identifier];
        if (!searchSql) {
            insertOperate();
            return;
        }
        /// 已存在根据传入的模型全量更新
        void(^updateOperate)(void) = ^ {
            NSString *updateSql = [XWDatabaseSQL updateOneObjSql:obj identifier:identifier];
            BOOL isSuccess = [XWDatabaseQueue executeUpdateSql:updateSql database:database];
            completion ? completion(isSuccess) : nil;
        };
        
        [XWDatabaseQueue executeStatementQuerySql:searchSql database:database completion:^(int count) {
            if (count < 0) {
                completion ? completion(NO) : nil;
                return ;
            }
            if (count) {
                updateOperate();
            } else {
                insertOperate();
            }
        }];
    }];
}

+ (void)p_saveModels:(NSArray < NSObject <XWDatabaseModelProtocol>* > *)objs identifier:(NSString * _Nullable)identifier completion:(XWDatabaseCompletion _Nullable)completion {
    
    [[XWDatabaseQueue shareInstance] inTransaction:^(FMDatabase * _Nonnull database, BOOL * _Nonnull rollback) {
        @autoreleasepool {
            
            NSObject *firstObj = objs.firstObject;
            if (![self p_createTable:firstObj.class database:database]) {
                completion ? completion(NO) : nil;
                *rollback = YES;
                return ;
            }
            
            __block NSMutableArray *updateSqls = [[NSMutableArray alloc] init];
            
            /// 添加插入语句
            void(^appendInsertSql)(NSObject <XWDatabaseModelProtocol>*) = ^ (NSObject <XWDatabaseModelProtocol> *obj) {
                NSString *insertSql = [XWDatabaseSQL insertOneObjSql:obj identifier:identifier];
                if (insertSql) {                
                    [updateSqls addObject:insertSql];
                }
            };
            
            /// 添加更新语句
            void(^appendUpdateSql)(NSObject <XWDatabaseModelProtocol>*) = ^ (NSObject <XWDatabaseModelProtocol> *obj) {
                NSString *updateSql = [XWDatabaseSQL updateOneObjSql:obj identifier:identifier];
                if (updateSql) {                
                    [updateSqls addObject:updateSql];
                }
            };
            
            for (NSObject <XWDatabaseModelProtocol> *obj in objs) {
                NSString *searchSql = [XWDatabaseSQL isExistSql:obj identifier:identifier];
                if (!searchSql) {
                    appendInsertSql(obj);
                    continue;
                }
                [XWDatabaseQueue executeStatementQuerySql:searchSql database:database completion:^(int count) {
                    if (count < 0) {
                        completion ? completion(NO) : nil;
                        *rollback = YES;
                        return ;
                    }
                    if (count) {
                        appendUpdateSql(obj);
                    } else {
                        appendInsertSql(obj);
                    }
                }];
            }
            
            [updateSqls enumerateObjectsUsingBlock:^(NSString * sql, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![database executeUpdate:sql]) {
                    completion ? completion(NO) : nil;
                    *rollback = YES;
                    return ;
                }
                if (idx == updateSqls.count - 1) {
                    completion ? completion(YES) : nil;
                    return;
                }
            }];
        }
    }];
}
#pragma mark  删
#pragma mark  改
+ (void)p_updateTable:(Class<XWDatabaseModelProtocol>)cls completion:(XWDatabaseCompletion _Nullable)completion {
    
    [[XWDatabaseQueue shareInstance] inTransaction:^(FMDatabase * _Nonnull database, BOOL * _Nonnull rollback) {
        
        NSString * queryCreateTableSql = [XWDatabaseSQL queryCreateTableSql:cls];
        FMResultSet *resultSet = [XWDatabaseQueue executeQuerySql:queryCreateTableSql database:database];
        NSString *createTableSql;
        while (resultSet.next) {
            createTableSql = [resultSet stringForColumnIndex:4];
        }
        if (!createTableSql || createTableSql.length == 0) {
            /// 本地数据库无当前表结构 -> 建表!
            BOOL isCreatTableSuccess = [self p_createTable:cls database:database];
            completion ? completion(isCreatTableSuccess) : nil;
            if (!isCreatTableSuccess) {
                *rollback = YES;
            }
            return;
        }
        
        // @"CREATE TABLE XWStuModel(age integer,stuNum integer,name text,primary key(stuNum))"
        //1.age integer,stuNum integer,name text,primary key
        NSString *nameTypeStr = [createTableSql componentsSeparatedByString:@"("][1];
        NSArray *nameTypeArr = [nameTypeStr componentsSeparatedByString:@","];
        NSMutableArray *columnNamesSorted = [NSMutableArray array];
        for (NSString *nameTypeCase in nameTypeArr) {
            if ([nameTypeCase containsString:@"PRIMARY"]) {
                /// 忽略主键
                continue;
            }
            if ([nameTypeCase isEqualToString:[NSString stringWithFormat:@"%@ text",kXWDB_IDENTIFIER_COLUMNNAME]]) {
                /// 忽略标识字段
                continue;                
            }
            //age integer
            NSString *columName = [nameTypeCase componentsSeparatedByString:@" "][0];
            [columnNamesSorted addObject:columName];
        }
        [columnNamesSorted sortUsingComparator:^NSComparisonResult(NSString *obj1,NSString *obj2) {
            return [obj1 compare:obj2];
        }];
        
        if (!columnNamesSorted) {
            completion ? completion(NO) : nil;
            return ;
        }
        
        NSArray *ivarNamesSorted = [XWDatabaseModel sortedIvarNames:cls];
//        NSLog(@"sortedIvarNames : %@ \n\n columnNames:%@",ivarNamesSorted,columnNamesSorted);
        BOOL isEqual = [ivarNamesSorted isEqualToArray:columnNamesSorted];
        if (isEqual) {  /// 模型字段和数据库表字段相同,无需更新
            completion ? completion(YES) : nil;
        } else {
            
            NSMutableArray *sqls = [[NSMutableArray alloc] init];
            
            /// 创建临时表
            NSString *creatTempTableSql = [XWDatabaseSQL createTableSql:cls isTtemporary:YES];
            [sqls addObject:creatTempTableSql];
            
            /// 更新主键
            NSArray *insertPrimarys = [XWDatabaseSQL insertPrimarys:cls];
            [sqls addObjectsFromArray:insertPrimarys];
            
            /// 更新标识字段
            NSString *updateIdentifierColumSql = [XWDatabaseSQL updateColumn:cls columName:kXWDB_IDENTIFIER_COLUMNNAME];
            [sqls addObject:updateIdentifierColumSql];
        
            /// 分别更新原有表字段
            for (NSString *ivar in ivarNamesSorted) {
                if (![columnNamesSorted containsObject:ivar]) {
                    continue;
                }
                NSString *updateColumSql = [XWDatabaseSQL updateColumn:cls columName:ivar];
                [sqls addObject:updateColumSql];
            }
            
            /// 删除旧表!
            NSString *dropTableSql = [XWDatabaseSQL dropTable:cls];
            [sqls addObject:dropTableSql];
            
            /// 重命名临时表
            NSString *renameTableSql = [XWDatabaseSQL renameTable:cls];
            [sqls addObject:renameTableSql];
            
            [sqls enumerateObjectsUsingBlock:^(NSString * sql, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![database executeUpdate:sql]) {
//                    NSLog(@"+++ 事务 %@ 执行失败!!",sql);
                    completion ? completion(NO) : nil;
                    *rollback = YES;
                }
                
                if (idx == sqls.count - 1) {
                    completion ? completion(YES) : nil;
                }
            }];
        }
    }];
}

#pragma mark  查
+ (void)p_getModel:(NSObject <XWDatabaseModelProtocol>*)obj identifier:(NSString * _Nullable)identifier completion:(XWDatabaseReturnObject _Nullable)completion {
    [[XWDatabaseQueue shareInstance] inDatabase:^(FMDatabase * _Nonnull database) {
        
        NSString *isExistSql = [XWDatabaseSQL isExistSql:obj identifier:identifier];
        if (!isExistSql) {
            completion ? completion(nil) : nil;
            return ;
        }
        [XWDatabaseQueue executeStatementQuerySql:isExistSql database:database completion:^(int count) {
            if (count > 0) {
                NSString *searchSql = [XWDatabaseSQL searchSql:obj identifier:identifier];
                if (!searchSql) {
                    completion ? completion(nil) : nil;
                    return ;
                }
                FMResultSet *resultSet = [XWDatabaseQueue executeQuerySql:searchSql database:database];
                Class modelClass = obj.class;
                id model = [[modelClass alloc] init];
                while (resultSet.next) {
                    [[XWDatabaseModel classColumnIvarNameTypeDict:modelClass] enumerateKeysAndObjectsUsingBlock:^(NSString * columnIvarName, NSString * ivarType, BOOL * _Nonnull stop) {
                        [self p_setModel:model cls:modelClass resultSet:resultSet columnIvarName:columnIvarName ivarType:ivarType];
                    }];
                }
                completion ? completion(model) : nil;
            } else {
                completion ? completion(nil) : nil;
            }
        }];
    }];
}

+ (void)p_getModels:(Class<XWDatabaseModelProtocol>)cls identifier:(NSString * _Nullable)identifier sortColumn:(NSString * _Nullable)sortColumn isOrderDesc:(BOOL)isOrderDesc condition:(NSString * _Nullable)condition completion:(XWDatabaseReturnObjects _Nullable)completion {
    
    [[XWDatabaseQueue shareInstance] inDatabase:^(FMDatabase * _Nonnull database) {
        @autoreleasepool {

            NSString *searchSql = [XWDatabaseSQL searchSql:cls identifier:identifier sortColumn:sortColumn isOrderDesc:isOrderDesc condition:condition];
            if (!searchSql) {
                completion ? completion(nil) : nil;
                return ;
            }
            FMResultSet *resultSet = [XWDatabaseQueue executeQuerySql:searchSql database:database];
            Class modelClass = cls;
            NSMutableArray *models = [[NSMutableArray alloc] init];
            while (resultSet.next) {
                id model = [[modelClass alloc] init];
                [[XWDatabaseModel classColumnIvarNameTypeDict:cls] enumerateKeysAndObjectsUsingBlock:^(NSString * columnIvarName, NSString * ivarType, BOOL * _Nonnull stop) {
                    [self p_setModel:model cls:modelClass resultSet:resultSet columnIvarName:columnIvarName ivarType:ivarType];
                }];
                if (model) {
                    [models addObject:model];
                }
            }
            completion ? completion(models) : nil;
            
        }
    }];
}

#pragma mark  通用
/// 建表
+ (BOOL)p_createTable:(Class<XWDatabaseModelProtocol>)cls database:(FMDatabase * _Nullable)database {
    NSString *creatTableSql = [XWDatabaseSQL createTableSql:cls isTtemporary:NO];
    return [XWDatabaseQueue executeUpdateSql:creatTableSql database:database];
}

+ (void)p_executeUpdate:(NSString *)sql completion:(XWDatabaseCompletion _Nullable)completion {
    [[XWDatabaseQueue shareInstance] inDatabase:^(FMDatabase * _Nonnull database) {
        BOOL isSuccess = [XWDatabaseQueue executeUpdateSql:sql database:database];
        completion ? completion(isSuccess) : nil;
    }];
}

+ (void)p_setModel:(id)model cls:(Class)cls resultSet:(FMResultSet *)resultSet columnIvarName:(NSString *)columnIvarName ivarType:(NSString *)ivarType {
    
    if ([resultSet columnIsNull:columnIvarName]) {
        return;
    }
    NSString *ivarName = columnIvarName;
    
    /// 自定义字段名
    NSDictionary *customColumnMapping = cls.xwdb_customColumnMapping;
    if (customColumnMapping && [customColumnMapping.allValues containsObject:columnIvarName]) {
        ivarName = [customColumnMapping allKeysForObject:columnIvarName].firstObject;
    }
    
     /// 自定义模型
    if (cls.xwdb_customModelMapping && [cls.xwdb_customModelMapping.allKeys containsObject:ivarName]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        id customModel = [XWDatabaseModel customModelWithString:string];
        [model setValue:customModel forKey:ivarName];
        return;
    }
    
    if ([ivarType isEqualToString:@"NSString"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        [model setValue:string forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSMutableString"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        NSMutableString *stringM = [NSMutableString stringWithString:string];
        [model setValue:stringM forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSNumber"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        NSNumber *number = [XWDatabaseModel numberWithString:string];
        [model setValue:number forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSArray"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        NSArray *array = [XWDatabaseModel arrayWithString:string];
        [model setValue:array forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSMutableArray"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        NSArray *array = [XWDatabaseModel arrayWithString:string];
        [model setValue:array.mutableCopy forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSDictionary"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        NSDictionary *dict = [XWDatabaseModel dictWithString:string];
        [model setValue:dict forKey:ivarName];
        
    } else if ( [ivarType isEqualToString:@"NSMutableDictionary"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        NSDictionary *dict = [XWDatabaseModel dictWithString:string];
        [model setValue:dict.mutableCopy forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"q"] || [ivarType isEqualToString:@"l"]) {
        [model setValue:[resultSet objectForColumn:columnIvarName] forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"i"]) {
        NSNumber *intNumber = [resultSet objectForColumn:columnIvarName];
        [model setValue:@(intNumber.intValue) forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"I"]) {
        NSNumber *integerNumber = [resultSet objectForColumn:columnIvarName];
        [model setValue:@(integerNumber.integerValue) forKey:ivarName];
        
    } else if([ivarType isEqualToString:@"d"]){
        [model setValue:[resultSet objectForColumn:columnIvarName] forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"f"]) {
        NSNumber *floatNumber = [resultSet objectForColumn:columnIvarName];
        [model setValue:@(floatNumber.floatValue) forKey:ivarName];
        
    }  else if([ivarType isEqualToString:@"c"] || [ivarType isEqualToString:@"B"]){
        NSNumber *boolNumber = [resultSet objectForColumn:columnIvarName];
        [model setValue:@(boolNumber.boolValue) forKey:ivarName];
        
    } else if([ivarType isEqualToString:@"s"]){
        NSNumber *shortNumber = [resultSet objectForColumn:columnIvarName];
        [model setValue:@(shortNumber.shortValue) forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"Q"]) {
        NSNumber *unsiginIntergerNumber = [resultSet objectForColumn:columnIvarName];
        [model setValue:@(unsiginIntergerNumber.unsignedIntegerValue) forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSData"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        NSData *data = [XWDatabaseModel dataWithString:string];
        [model setValue:data forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSMutableData"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        NSData *data = [XWDatabaseModel dataWithString:string];
        [model setValue:data.mutableCopy forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSSet"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        NSSet *set = [XWDatabaseModel setWithString:string];
        [model setValue:set forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSMutableSet"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        NSSet *set = [XWDatabaseModel setWithString:string];
        [model setValue:set.mutableCopy forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSDate"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        NSDate *date = [XWDatabaseModel dateWithString:string];
        [model setValue:date forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSAttributedString"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        NSAttributedString *attributedString = [XWDatabaseModel attributedStringWithString:string];
        [model setValue:attributedString forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSMutableAttributedString"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        NSAttributedString *attributedString = [XWDatabaseModel attributedStringWithString:string];
        [model setValue:attributedString.mutableCopy forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSIndexPath"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        NSIndexPath *indexPath = [XWDatabaseModel indexPathWithString:string];
        [model setValue:indexPath forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"UIImage"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        UIImage *image = [XWDatabaseModel imageWithString:string];
        [model setValue:image forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSURL"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        NSURL *URL = [XWDatabaseModel URLWithString:string];
        [model setValue:URL forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"{_NSRange=\"location\"Q\"length\"Q}"] || [ivarType isEqualToString:@"{_NSRange=\"location\"I\"length\"I}"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        NSRange range = NSRangeFromString(string);
        [model setValue:[NSValue valueWithRange:range] forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"{CGPoint=\"x\"d\"y\"d}"] || [ivarType isEqualToString:@"{CGPoint=\"x\"f\"y\"f}"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        CGPoint point = CGPointFromString(string);
        [model setValue:@(point) forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"{CGRect=\"origin\"{CGPoint=\"x\"d\"y\"d}\"size\"{CGSize=\"width\"d\"height\"d}}"] || [ivarType isEqualToString:@"{CGRect=\"origin\"{CGPoint=\"x\"f\"y\"f}\"size\"{CGSize=\"width\"f\"height\"f}}"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        CGRect rect = CGRectFromString(string);
        [model setValue:@(rect) forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"{CGSize=\"width\"d\"height\"d}"] || [ivarType isEqualToString:@"{CGSize=\"width\"f\"height\"f}"]) {
        NSString *string = [resultSet stringForColumn:columnIvarName];
        CGSize size = CGSizeFromString(string);
        [model setValue:@(size) forKey:ivarName];
        
    } else {
        [model setValue:[resultSet objectForColumn:columnIvarName] forKey:ivarName];
        
    }
    
    /*
     @"f":@"float",
     @"i":@"int",
     @"d":@"double",
     @"l":@"long",
     @"c":@"BOOL",
     @"s":@"short",
     @"q":@"long",
     @"I":@"NSInteger",
     @"Q":@"NSUInteger",
     @"B":@"BOOL",
     
     https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100
     */
}

@end
