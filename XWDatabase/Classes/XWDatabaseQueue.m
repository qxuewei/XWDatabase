//
//  XWDatabaseQueue.m
//  XWDatabase
//
//  Created by 邱学伟 on 2018/12/1.
//  Copyright © 2018 邱学伟. All rights reserved.
//

#import "XWDatabaseQueue.h"
#import "FMDB.h"

#define WS(weakSelf)  __weak __typeof(self) weakSelf = self;
#define TS(strongSelf)  __strong __typeof(weakSelf) strongSelf = weakSelf;

@interface XWDatabaseQueue () {
    FMDatabase *_db;
    FMDatabaseQueue *_queue;
    FMDatabaseQueue *_updateSqlsQueue;
    FMDatabaseQueue *_querySqlsQueue;
}
@property (nonatomic, copy) NSString *databasePath;
@property (nonatomic, strong) FMDatabase *dataBase;
@end

@implementation XWDatabaseQueue

#pragma mark - Public
static XWDatabaseQueue *_defaultManager;

/**
 单例
 
 @return 单例对象
 */
+ (instancetype)shareInstance {
    if (!_defaultManager) {
        _defaultManager = [[self alloc] init];
    }
    return _defaultManager;
}

/**
 数据库操作队列
 
 @param block 队列内操作
 */
- (void)inDatabase:(XWDatabaseQueueDatabaseHandle)block {
    if (!block) {
        return;
    }
    if (self.dataBase) {
        block(self.dataBase);
        return;
    }
    WS(weakSelf);
    [_queue inDatabase:^(FMDatabase *db){
        TS(strongSelf);
        strongSelf.dataBase = db;
        block(db);
        strongSelf.dataBase = nil;
    }];
}

/**
 数据库事务操作队列
 
 @param block 队列内操作
 */
- (void)inTransaction:(XWDatabaseQueueTransactionHandle)block {
    if (!block) {
        return;
    }
    [_queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        block(db,rollback);
    }];
}

/**
 执行更新操作 (单语句)
 
 @param sql 所执行的 SQL
 @param database 数据库
 */
+ (BOOL)executeUpdateSql:(NSString *)sql database:(FMDatabase *)database {
    if (!sql || !database) {
        return NO;
    }
    return [database executeUpdate:sql];
}

/**
 执行查询操作 (单语句)
 
 @param sql 所执行的 SQL
 @param database 数据库
 */
+ (FMResultSet *)executeQuerySql:(NSString *)sql database:(FMDatabase *)database {
    if (!sql || !database) {
        return nil;
    }
    FMResultSet *set = [database executeQuery:sql];
    return set;
}

/**
 执行查询操作 (单语句)
 
 @param sql 所执行的 SQL
 @param database 数据库
 */
+ (void)executeStatementQuerySql:(NSString *)sql database:(FMDatabase *)database completion:(XWDatabaseQueueQueryCountResult)completion {
    if (!completion) {
        return;
    }
    if (!sql || !database) {
        completion(-1);
        return;
    }
    [database executeStatements:sql withResultBlock:^int(NSDictionary * _Nonnull resultsDictionary) {
        int count = [[resultsDictionary.allValues lastObject] intValue];
        completion(count);
        return 0;
    }];
}

/**
 执行更新操作 (多语句)
 
 @param sqls 所执行的 SQLs
 @param completion 完成回调
 */
- (void)executeUpdateSqlSqls:(NSArray < NSString *> *)sqls completion:(XWDatabaseQueueUpdateResult)completion {
    if (!sqls || sqls.count == 0 || !completion) {
        return;
    }
    if (!_updateSqlsQueue) {
        completion(NO);
        return;
    }
    [_updateSqlsQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        [sqls enumerateObjectsUsingBlock:^(NSString * _Nonnull sql, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![db executeUpdate:sql]) {
                NSLog(@"+++ 事务 %@ 执行失败!!",sql);
                completion(NO);
                *rollback = YES;
                return ;
            }
            if (idx == sqls.count - 1) {
                completion(YES);
                return;
            }
        }];
    }];
}

/**
 执行查询操作 (多语句)
 
 @param sqls 所执行的 SQLs
 @param completion 完成回调
 */
- (void)executeQuerySqlSqls:(NSArray < NSString *> *)sqls completion:(XWDatabaseQueueQueryResults)completion {
    if (!sqls || sqls.count == 0 || !completion) {
        return;
    }
    if (!_querySqlsQueue) {
        completion(nil);
        return;
    }
    [_querySqlsQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        __block NSMutableArray <FMResultSet *> *resultSets = [[NSMutableArray alloc] init];
        [sqls enumerateObjectsUsingBlock:^(NSString * _Nonnull sql, NSUInteger idx, BOOL * _Nonnull stop) {
            FMResultSet *set = [db executeQuery:sql];
            if (set) {
                [resultSets addObject:set];
            }
        }];
        completion(resultSets);
    }];
}

#pragma mark - Life
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!_defaultManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _defaultManager = [super allocWithZone:zone];
        });
    }
    return _defaultManager;
}

- (id)copyWithZone:(NSZone *)zone{
    return _defaultManager;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    return _defaultManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _db                 = [FMDatabase databaseWithPath:self.databasePath];
        _queue              = [FMDatabaseQueue databaseQueueWithPath:self.databasePath];
        _updateSqlsQueue    = [FMDatabaseQueue databaseQueueWithPath:self.databasePath flags:1];
        _querySqlsQueue     = [FMDatabaseQueue databaseQueueWithPath:self.databasePath flags:2];
    }
    return self;
}
#pragma mark - Private

#pragma mark - Getter
- (NSString *)databasePath {
    if (!_databasePath) {
        NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        _databasePath = [document stringByAppendingPathComponent:@"XWCommonDatabase.sqlite"];
    }
    return _databasePath;
}
@end
