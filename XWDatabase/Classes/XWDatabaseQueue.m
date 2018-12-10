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

#pragma mark - Life Cycle
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
