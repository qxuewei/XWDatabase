//
//  XWDatabaseModel.h
//  XWDatabase
//
//  Created by 邱学伟 on 2018/11/29.
//  Copyright © 2018 邱学伟. All rights reserved.
//  对于模型的操作

#import <Foundation/Foundation.h>
#import "XWDatabaseModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface XWDatabaseModel : NSObject

/**
 表名

 @param cls 成员变量类
 @return 表名
 */
+ (NSString *)tableName:(Class<XWDatabaseModelProtocol>)cls;

/**
 临时表名

 @param cls 模型类
 @return 临时表名
 */
+ (NSString *)tempTableName:(Class<XWDatabaseModelProtocol>)cls;

/**
 模型中所有成员变量 (key: 成员变量名称  value: 成员变量类型)

 @param cls 模型类
 @return 模型中所有成员变量
 */
+ (NSDictionary *)classIvarNameTypeDict:(Class<XWDatabaseModelProtocol>)cls;

/**
 模型中所有成员变量在Sqlite 数据库中对应的类型 (成员变量:Sqlite Type)
 
 @param cls 模型类
 @return 模型中所有成员变量在Sqlite 数据库中对应的类型
 */
+ (NSDictionary *)classIvarNameSqliteTypeDict:(Class<XWDatabaseModelProtocol>)cls;

/**
 模型建表的Sql语句

 @param cls 模型类
 @return 模型建表的Sql语句
 */
+ (NSString *)sqlWithCreatTable:(Class<XWDatabaseModelProtocol>)cls;

/**
 模型根据字母排序的成员变量数组

 @param cls 模型类
 @return 模型根据字母排序的成员变量数组
 */
+ (NSArray <NSString *>*)sortedIvarNames:(Class<XWDatabaseModelProtocol>)cls;

/// NSAarray -> NSString
+ (NSString *)stringWithArray:(NSArray *)array;
/// NSString -> NSArray
+ (NSArray *)arrayWithString:(NSString *)string;

/// NSDictionary -> NSString
+ (NSString *)stringWithDict:(NSDictionary *)dict;
/// NSDictionary -> NSArray
+ (NSDictionary *)dictWithString:(NSString *)string;

/// NSData -> NSString
+ (NSString *)stringWithData:(NSData *)data;
/// NSString -> NSData
+ (NSData *)dataWithString:(NSString *)string;

/// NSDate -> NSString
+ (NSString *)stringWithDate:(NSDate *)date;
/// NSString -> NSDate
+ (NSDate *)dateWithString:(NSString *)string;

/// NSNumber -> NSString
+ (NSString *)stringWithNumber:(NSNumber *)number;
/// NSString -> NSNumber
+ (NSNumber *)numberWithString:(NSString *)string;
@end

NS_ASSUME_NONNULL_END
