//
//  XWDatabaseDataModel.m
//  XWDatabase_Example
//
//  Created by 邱学伟 on 2018/12/12.
//  Copyright © 2018 qxuewei@yeah.net. All rights reserved.
//

#import "XWDatabaseDataModel.h"
#import "XWDatabaseQueue.h"
#import "FMDB.h"

@interface XWDatabaseDataModel ()
@end

@implementation XWDatabaseDataModel
static NSString * const cTableName = @"XWDatabaseDataModelTable";

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[XWDatabaseQueue shareInstance] inDataDatabase:^(FMDatabase * _Nonnull database) {
            /// hashID : 二进制唯一标识   data : 二进制文件(bas64字符串形式存储)   referenceCount : 引用计数 (每次insert + 1  delete - 1)
            NSString *creatTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(hashID INTEGER PRIMARY KEY ,data BLOB, referenceCount INTEGER)",cTableName];
            [database executeUpdate:creatTableSql];
        }];
    });
}

+ (void)saveData:(NSData *)data completion:(void(^)(BOOL, NSUInteger))completion {
    [[XWDatabaseQueue shareInstance] inDataDatabase:^(FMDatabase * _Nonnull database) {
        NSUInteger hash = data.hash;
        NSString *searchDataSql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE hashID = '%lu'",cTableName,(unsigned long)hash];
        BOOL searchSucess = [database executeStatements:searchDataSql withResultBlock:^int(NSDictionary * _Nonnull resultsDictionary) {
            int count = [[resultsDictionary.allValues lastObject] intValue];
            if (count == 0) {
                NSString *base64 = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                NSString *save = [NSString stringWithFormat:@"INSERT INTO %@(hashID, data) VALUES('%lu', '%@')",cTableName,(unsigned long)hash,base64];
                BOOL isSuccess = [database executeUpdate:save];
                completion ? completion(isSuccess, hash) : nil;
            } else {
                completion ? completion(YES, hash) : nil;
            }
            return 0;
        }];
        if (!searchSucess) {
            completion ? completion(NO, 0) : nil;
        }
    }];
}

+ (void)dataWithHash:(NSString *)hashString completion:(void(^)(NSData *))completion  {
    [[XWDatabaseQueue shareInstance] inDataDatabase:^(FMDatabase * _Nonnull database) {
        NSUInteger hash = hashString.integerValue;
        NSString *searchDataSql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE hashID = '%lu'",cTableName,(unsigned long)hash];
        BOOL searchSucess = [database executeStatements:searchDataSql withResultBlock:^int(NSDictionary * _Nonnull resultsDictionary) {
            int count = [[resultsDictionary.allValues lastObject] intValue];
            if (count == 0) {
                completion ? completion(nil) : nil;
            } else {
                // select name from XWStuModel where
                NSString *querySql = [NSString stringWithFormat:@"SELECT data FROM %@ WHERE hashID = '%lu'",cTableName,(unsigned long)hash];
                FMResultSet *set = [database executeQuery:querySql];
                while (set.next) {
                    NSString *base64 = [set objectForColumn:@"data"];
                    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    completion ? completion(data) : nil;
                }
            }
            return 0;
        }];
        if (!searchSucess) {
            completion ? completion(nil) : nil;
        }
    }];
}

@end
