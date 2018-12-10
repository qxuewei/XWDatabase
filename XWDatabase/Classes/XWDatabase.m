//
//  XWDatabase.m
//  XWDatabase
//
//  Created by 邱学伟 on 2018/11/29.
//  Copyright © 2018 邱学伟. All rights reserved.
//

#import "FMDB.h"
#import "XWDatabase.h"
#import "XWDatabaseSQL.h"
#import "XWLivingThread.h"
#import "XWDatabaseModel.h"
#import "XWDatabaseQueue.h"

/// NSLog 宏定义
//重写NSLog,Debug模式下打印日志和当前行数
#if DEBUG

#define NSLog(format, ...) do {                                             \
fprintf(stderr, "<%s : %d> %s\n",                                           \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
__LINE__, __func__);                                                        \
(NSLog)((format), ##__VA_ARGS__);                                           \
fprintf(stderr, "-------\n");                                               \
} while (0)

#else

#define NSLog(FORMAT, ...) nil

#endif


@implementation XWDatabase

#pragma mark - public

#pragma mark  增
/**
 保存模型
 
 @param obj 模型
 @param completion 保存 成功/失败
 */
+ (void)saveModel:(NSObject <XWDatabaseModelProtocol>*)obj completion:(XWDatabaseCompletion)completion {
    
    if (!obj || ![self isPrimaryKey:obj.class]) {
        completion ? completion(NO) : nil;
        return;
    }
    [XWLivingThread executeTaskInMain:^{
        [self p_saveModel:obj completion:^(BOOL isSuccess) {
            completion ? completion(isSuccess) : nil;
        }];
    }];
}

/**
 保存模型数组
 
 @param objs 模型数组
 @param completion 保存 成功/失败
 */
+ (void)saveModels:(NSArray < NSObject <XWDatabaseModelProtocol>* > *)objs completion:(XWDatabaseCompletion)completion {
   
    if (!objs || objs.count == 0) {
        completion ? completion(NO) : nil;
        return;
    }
    NSObject *firstObj = objs.firstObject;
    if (![self isPrimaryKey:firstObj.class]) {
        completion ? completion(NO) : nil;
        return;
    }
    [XWLivingThread executeTaskInMain:^{
        [self p_saveModels:objs completion:^(BOOL isSuccess) {
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
+ (void)deleteModel:(NSObject <XWDatabaseModelProtocol>*)obj completion:(XWDatabaseCompletion)completion {
    if (!obj || ![self isPrimaryKey:obj.class]) {
        completion ? completion(NO) : nil;
        return;
    }
    [XWLivingThread executeTaskInMain:^{
        NSString *deleteColumnSql = [XWDatabaseSQL deleteColumn:obj];
        [self p_executeUpdate:deleteColumnSql completion:completion];
    }];
}

/**
 删除指定模型所有数据
 
 @param cls 模型类
 @param completion 成功/失败
 */
+ (void)clearModel:(Class<XWDatabaseModelProtocol>)cls completion:(XWDatabaseCompletion)completion {
    [self clearModel:cls condition:nil completion:completion];
}

/**
 删除指定模型所有数据
 
 @param cls 模型类
 @param condition 自定义条件 (为空删除所有数据,有值根据自定义的条件删除)
 @param completion 成功/失败
 */
+ (void)clearModel:(Class<XWDatabaseModelProtocol>)cls condition:(NSString *)condition completion:(XWDatabaseCompletion)completion {
    if (!cls) {
        completion ? completion(NO) : nil;
        return;
    }
    [XWLivingThread executeTaskInMain:^{
        NSString *clearColumnSql = [XWDatabaseSQL clearColumn:cls condition:condition];
        [self p_executeUpdate:clearColumnSql completion:completion];
    }];
}

#pragma mark  改
/**
 更新现有表结构 (增删字段,数据迁移)
 
 @param cls 模型类
 @param completion 是否更新成功
 */
+ (void)updateTable:(Class<XWDatabaseModelProtocol>)cls completion:(XWDatabaseCompletion)completion {
    
    if (!cls || ![self isPrimaryKey:cls]) {
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
 @param updatePropertys 所更新的字段数组
 @param completion 保存 成功/失败
 */
+ (void)updateModel:(NSObject <XWDatabaseModelProtocol>*)obj updatePropertys:(NSArray <NSString *> *)updatePropertys completion:(XWDatabaseCompletion)completion {
    if (!obj || !updatePropertys || updatePropertys.count == 0 || ![self isPrimaryKey:obj.class]) {
        completion ? completion(NO) : nil;
        return;
    }
    [XWLivingThread executeTaskInMain:^{
        NSString *updateModelSQL = [XWDatabaseSQL updateOneObjSql:obj updatePropertys:updatePropertys];
        [self p_executeUpdate:updateModelSQL completion:completion];
    }];
}

#pragma mark  查
/**
 查询模型

 @param obj 查询对象(必须保证主键 不为空)
 @param completion 结果
 */
+ (void)getModel:(NSObject <XWDatabaseModelProtocol>*)obj completion:(XWDatabaseReturnObject)completion {
    if (!completion) {
        return;
    }
    if (!obj) {
        completion ? completion(nil) : nil;
        return;
    }
    [XWLivingThread executeTaskInMain:^{
        [self p_getModel:obj completion:completion];
    }];
}

/**
 查询模型数组
 
 @param cls 模型类
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls completion:(XWDatabaseReturnObjects)completion {
    [self getModels:cls sortColumn:nil isOrderDesc:NO condition:nil completion:completion];
}

/**
 查询模型数组 - 按某字段排序
 
 @param cls 模型类
 @param sortColumn 排序字段
 @param isOrderDesc 是否降序 (YES: 降序  NO: 升序)
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls sortColumn:(NSString *)sortColumn isOrderDesc:(BOOL)isOrderDesc completion:(XWDatabaseReturnObjects)completion {
    [self getModels:cls sortColumn:sortColumn isOrderDesc:isOrderDesc condition:nil completion:completion];
}

/**
 查询模型数组 - 自定义条件
 
 @param cls 模型类
 @param condition 条件
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls condition:(NSString *)condition completion:(XWDatabaseReturnObjects)completion {
    [self getModels:cls sortColumn:nil isOrderDesc:NO condition:condition completion:completion];
}

/**
 查询模型数组 - 自定义条件 + 按某字段排序
 
 @param cls 模型类
 @param sortColumn 排序字段
 @param isOrderDesc 是否降序
 @param condition 条件
 @param completion 结果
 */
+ (void)getModels:(Class<XWDatabaseModelProtocol>)cls sortColumn:(NSString *)sortColumn isOrderDesc:(BOOL)isOrderDesc condition:(NSString *)condition completion:(XWDatabaseReturnObjects)completion {
    if (!completion) {
        return;
    }
    if (!cls) {
        completion ? completion(nil) : nil;
        return;
    }
    [XWLivingThread executeTaskInMain:^{
        [self p_getModels:cls sortColumn:sortColumn isOrderDesc:isOrderDesc condition:condition completion:completion];
    }];
}



#pragma mark - private

#pragma mark  增
+ (void)creatTableFromClass:(Class<XWDatabaseModelProtocol>)cls completion:(XWDatabaseCompletion)completion {
    if (!cls) {
        return;
    }
    if (![self isPrimaryKey:cls]) {
        completion ? completion(NO) : nil;
        return;
    }
    [XWLivingThread executeTaskInMain:^{
        NSString *creatTableSql = [XWDatabaseSQL createTableSql:cls isTtemporary:NO];
        [self p_executeUpdate:creatTableSql completion:completion];
    }];
}

+ (void)p_saveModel:(NSObject <XWDatabaseModelProtocol>*)obj completion:(XWDatabaseCompletion)completion {
    
    [[XWDatabaseQueue shareInstance] inDatabase:^(FMDatabase * _Nonnull database) {
        
        NSString *creatTableSql = [XWDatabaseSQL createTableSql:obj.class isTtemporary:NO];
        BOOL isCreatTableSuccess = [XWDatabaseQueue executeUpdateSql:creatTableSql database:database];
        if (!isCreatTableSuccess) {
            completion ? completion(NO) : nil;
            return ;
        }
        
        NSString *searchSql = [XWDatabaseSQL isExistSql:obj];
        [XWDatabaseQueue executeStatementQuerySql:searchSql database:database completion:^(int count) {
            if (count < 0) {
                completion ? completion(NO) : nil;
                return ;
            }
            if (count) {
                NSString *updateSql = [XWDatabaseSQL updateOneObjSql:obj];
                BOOL isSuccess = [XWDatabaseQueue executeUpdateSql:updateSql database:database];
                completion ? completion(isSuccess) : nil;
            } else {
                NSString *saveSql = [XWDatabaseSQL saveOneObjSql:obj];
                BOOL isSuccess = [XWDatabaseQueue executeUpdateSql:saveSql database:database];
                completion ? completion(isSuccess) : nil;
            }
        }];
    }];
}

+ (void)p_saveModels:(NSArray < NSObject <XWDatabaseModelProtocol>* > *)objs completion:(XWDatabaseCompletion)completion {
    
    
    [[XWDatabaseQueue shareInstance] inTransaction:^(FMDatabase * _Nonnull database, BOOL * _Nonnull rollback) {
        @autoreleasepool {
            
            NSObject *firstObj = objs.firstObject;
            NSString *creatTableSql = [XWDatabaseSQL createTableSql:firstObj.class isTtemporary:NO];
            BOOL isCreatTableSuccess = [XWDatabaseQueue executeUpdateSql:creatTableSql database:database];
            if (!isCreatTableSuccess) {
                completion ? completion(NO) : nil;
                *rollback = YES;
                return ;
            }
            __block NSMutableArray *updateSqls = [[NSMutableArray alloc] init];
            
            for (NSObject <XWDatabaseModelProtocol> *obj in objs) {
                NSString *searchSql = [XWDatabaseSQL isExistSql:obj];
                [XWDatabaseQueue executeStatementQuerySql:searchSql database:database completion:^(int count) {
                    if (count < 0) {
                        completion ? completion(NO) : nil;
                        *rollback = YES;
                        return ;
                    }
                    if (count) {
                        NSString *updateSql = [XWDatabaseSQL updateOneObjSql:obj];
                        [updateSqls addObject:updateSql];
                    } else {
                        NSString *saveSql = [XWDatabaseSQL saveOneObjSql:obj];
                        [updateSqls addObject:saveSql];
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
+ (void)p_updateTable:(Class<XWDatabaseModelProtocol>)cls completion:(XWDatabaseCompletion)completion {
    
    if (![self isPrimaryKey:cls]) {
        completion ? completion(NO) : nil;
        return;
    }
    
    [[XWDatabaseQueue shareInstance] inTransaction:^(FMDatabase * _Nonnull database, BOOL * _Nonnull rollback) {
        
        NSString * queryCreateTableSql = [XWDatabaseSQL queryCreateTableSql:cls];
        FMResultSet *resultSet = [XWDatabaseQueue executeQuerySql:queryCreateTableSql database:database];
        NSString *createTableSql;
        while (resultSet.next) {
            createTableSql = [resultSet stringForColumnIndex:4];
        }
        if (!createTableSql || createTableSql.length == 0) {
            /// 本地数据库无当前表结构 -> 建表!
            NSString *creatTableSql = [XWDatabaseSQL createTableSql:cls isTtemporary:NO];
            BOOL isCreatTableSuccess = [XWDatabaseQueue executeUpdateSql:creatTableSql database:database];
            NSLog(@"++ 本地数据库无当前表结构 建表 (%@) -> (%@)",cls,isCreatTableSuccess?@"成功":@"失败");
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
            if ([nameTypeCase containsString:@"primary"]) {
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
            NSLog(@"++ 表更新 %@ 模型字段和数据库表字段相同,无需更新",cls);
            completion ? completion(YES) : nil;
        } else {
            
            NSMutableArray *sqls = [[NSMutableArray alloc] init];
            
            /// 创建临时表
            NSString *creatTempTableSql = [XWDatabaseSQL createTableSql:cls isTtemporary:YES];
            [sqls addObject:creatTempTableSql];
            
            /// 更新主键
            NSString *insertPrimarySql = [XWDatabaseSQL insertPrimary:cls];
            [sqls addObject:insertPrimarySql];
            
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
                    NSLog(@"+++ 事务 %@ 执行失败!!",sql);
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
+ (void)p_getModel:(NSObject <XWDatabaseModelProtocol>*)obj completion:(XWDatabaseReturnObject)completion {
    [[XWDatabaseQueue shareInstance] inDatabase:^(FMDatabase * _Nonnull database) {
        NSString *isExistSql = [XWDatabaseSQL isExistSql:obj];
        [XWDatabaseQueue executeStatementQuerySql:isExistSql database:database completion:^(int count) {
            if (count > 0) {
                NSString *searchSql = [XWDatabaseSQL searchSql:obj];
                FMResultSet *resultSet = [XWDatabaseQueue executeQuerySql:searchSql database:database];
                Class modelClass = obj.class;
                id model = [[modelClass alloc] init];
                NSDictionary *ivarNameTypeDict = [XWDatabaseModel classIvarNameTypeDict:modelClass];
                while (resultSet.next) {
                    [ivarNameTypeDict enumerateKeysAndObjectsUsingBlock:^(NSString * ivarName, NSString * ivarType, BOOL * _Nonnull stop) {
                        [self p_setModel:model resultSet:resultSet ivarName:ivarName ivarType:ivarType];
                    }];
                }
                completion ? completion(model) : nil;
            } else {
                completion ? completion(nil) : nil;
            }
        }];
    }];
}

+ (void)p_getModels:(Class<XWDatabaseModelProtocol>)cls sortColumn:(NSString *)sortColumn isOrderDesc:(BOOL)isOrderDesc condition:(NSString *)condition completion:(XWDatabaseReturnObjects)completion {
    
    [[XWDatabaseQueue shareInstance] inDatabase:^(FMDatabase * _Nonnull database) {
        @autoreleasepool {
            
            NSString *searchSql = [XWDatabaseSQL searchSql:cls sortColumn:sortColumn isOrderDesc:isOrderDesc condition:condition];
            FMResultSet *resultSet = [XWDatabaseQueue executeQuerySql:searchSql database:database];
            Class modelClass = cls;
            NSMutableArray *models = [[NSMutableArray alloc] init];
            NSDictionary *ivarNameTypeDict = [XWDatabaseModel classIvarNameTypeDict:modelClass];
            while (resultSet.next) {
                id model = [[modelClass alloc] init];
                [ivarNameTypeDict enumerateKeysAndObjectsUsingBlock:^(NSString * ivarName, NSString * ivarType, BOOL * _Nonnull stop) {
                    [self p_setModel:model resultSet:resultSet ivarName:ivarName ivarType:ivarType];
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
+ (void)p_executeUpdate:(NSString *)sql completion:(XWDatabaseCompletion)completion {
    [[XWDatabaseQueue shareInstance] inDatabase:^(FMDatabase * _Nonnull database) {
        BOOL isSuccess = [XWDatabaseQueue executeUpdateSql:sql database:database];
        completion ? completion(isSuccess) : nil;
    }];
}

+ (BOOL)isPrimaryKey:(Class<XWDatabaseModelProtocol>)cls {
    if (![cls respondsToSelector:@selector(xw_primaryKey)]) {
        NSLog(@"倘若希望使用 %@ 模型直接创建数据库,需要实现 +(NSString *)xw_primaryKey; 类方法(准守XWDatabaseModelProtocol 协议)",NSStringFromClass(cls));
        return NO;
    }
    return YES;
}

+ (void)p_setModel:(id)model resultSet:(FMResultSet *)resultSet ivarName:(NSString *)ivarName ivarType:(NSString *)ivarType {
    if ([resultSet columnIsNull:ivarName]) {
        return;
    }
    
    if ([ivarType isEqualToString:@"NSString"]) {
        NSString *string = [resultSet stringForColumn:ivarName];
        [model setValue:string forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSMutableString"]) {
        NSString *string = [resultSet stringForColumn:ivarName];
        NSMutableString *stringM = [NSMutableString stringWithString:string];
        [model setValue:stringM forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSNumber"]) {
        NSString *string = [resultSet stringForColumn:ivarName];
        NSNumber *number = [XWDatabaseModel numberWithString:string];
        [model setValue:number forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSArray"]) {
        NSString *string = [resultSet stringForColumn:ivarName];
        NSArray *array = [XWDatabaseModel arrayWithString:string];
        [model setValue:array forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSMutableArray"]) {
        NSString *string = [resultSet stringForColumn:ivarName];
        NSArray *array = [XWDatabaseModel arrayWithString:string];
        [model setValue:array.mutableCopy forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSDictionary"]) {
        NSString *string = [resultSet stringForColumn:ivarName];
        NSDictionary *dict = [XWDatabaseModel dictWithString:string];
        [model setValue:dict forKey:ivarName];
        
    } else if ( [ivarType isEqualToString:@"NSMutableDictionary"]) {
        NSString *string = [resultSet stringForColumn:ivarName];
        NSDictionary *dict = [XWDatabaseModel dictWithString:string];
        [model setValue:dict.mutableCopy forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"q"] || [ivarType isEqualToString:@"l"]) {
        [model setValue:[resultSet objectForColumn:ivarName] forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"i"]) {
        NSNumber *intNumber = [resultSet objectForColumn:ivarName];
        [model setValue:@(intNumber.intValue) forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"I"]) {
        NSNumber *integerNumber = [resultSet objectForColumn:ivarName];
        [model setValue:@(integerNumber.integerValue) forKey:ivarName];
        
    } else if([ivarType isEqualToString:@"d"]){
        [model setValue:[resultSet objectForColumn:ivarName] forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"f"]) {
        NSNumber *floatNumber = [resultSet objectForColumn:ivarName];
        [model setValue:@(floatNumber.floatValue) forKey:ivarName];
        
    }  else if([ivarType isEqualToString:@"c"] || [ivarType isEqualToString:@"B"]){
        NSNumber *boolNumber = [resultSet objectForColumn:ivarName];
        [model setValue:@(boolNumber.boolValue) forKey:ivarName];
        
    } else if([ivarType isEqualToString:@"s"]){
        NSNumber *shortNumber = [resultSet objectForColumn:ivarName];
        [model setValue:@(shortNumber.shortValue) forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"Q"]) {
        NSNumber *unsiginIntergerNumber = [resultSet objectForColumn:ivarName];
        [model setValue:@(unsiginIntergerNumber.unsignedIntegerValue) forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSData"]) {
        NSString *string = [resultSet stringForColumn:ivarName];
        NSData *data = [XWDatabaseModel dataWithString:string];
        [model setValue:data forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSMutableData"]) {
        NSString *string = [resultSet stringForColumn:ivarName];
        NSData *data = [XWDatabaseModel dataWithString:string];
        [model setValue:data.mutableCopy forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSSet"]) {
        NSString *string = [resultSet stringForColumn:ivarName];
        NSSet *set = [XWDatabaseModel setWithString:string];
        [model setValue:set forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSMutableSet"]) {
        NSString *string = [resultSet stringForColumn:ivarName];
        NSSet *set = [XWDatabaseModel setWithString:string];
        [model setValue:set.mutableCopy forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSDate"]) {
        NSString *string = [resultSet stringForColumn:ivarName];
        NSDate *date = [XWDatabaseModel dateWithString:string];
        [model setValue:date forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSAttributedString"]) {
        NSString *string = [resultSet stringForColumn:ivarName];
        NSAttributedString *attributedString = [XWDatabaseModel attributedStringWithString:string];
        [model setValue:attributedString forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSMutableAttributedString"]) {
        NSString *string = [resultSet stringForColumn:ivarName];
        NSAttributedString *attributedString = [XWDatabaseModel attributedStringWithString:string];
        [model setValue:attributedString.mutableCopy forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"NSIndexPath"]) {
        NSString *string = [resultSet stringForColumn:ivarName];
        NSIndexPath *indexPath = [XWDatabaseModel indexPathWithString:string];
        [model setValue:indexPath forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"{CGPoint=\"x\"d\"y\"d}"]) {
        NSString *string = [resultSet stringForColumn:ivarName];
        CGPoint point = CGPointFromString(string);
        [model setValue:@(point) forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"{CGRect=\"origin\"{CGPoint=\"x\"d\"y\"d}\"size\"{CGSize=\"width\"d\"height\"d}}"]) {
        NSString *string = [resultSet stringForColumn:ivarName];
        CGRect rect = CGRectFromString(string);
        [model setValue:@(rect) forKey:ivarName];
        
    } else if ([ivarType isEqualToString:@"{CGSize=\"width\"d\"height\"d}"]) {
        NSString *string = [resultSet stringForColumn:ivarName];
        CGSize size = CGSizeFromString(string);
        [model setValue:@(size) forKey:ivarName];
        
    } else {
        [model setValue:[resultSet objectForColumn:ivarName] forKey:ivarName];
        
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
