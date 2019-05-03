//
//  XWDatabaseModel.h
//  XWDatabase
//
//  Created by 邱学伟 on 2018/11/29.
//  Copyright © 2018 邱学伟. All rights reserved.
//  对于模型的操作

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
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
 模型中所有成员变量 (key: 成员变量名称(映射后字段名)  value: 成员变量类型)
 
 @param cls 类
 @return 模型中所有成员变量 (key: 成员变量名称(映射后字段名)  value: 成员变量类型)
 */
+ (NSDictionary *)classColumnIvarNameTypeDict:(Class)cls;

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

/**
 根据字段名获取模型真实成员变量名
 
 @param column 字段名
 @param cls 类
 @return 模型真实成员变量名
 */
+ (NSString *)ivarNameWithColumn:(NSString *)column cls:(Class)cls;

/**
 模型中成员变量集合
 
 @return 模型中成员变量集合
 */
+ (NSSet *)classIvarNamesSet:(Class)cls;

/**
 模型中自定义对象
 
 @param cls 模型类
 @return 模型中自定义对象
 */
+ (NSSet *)customModelSet:(Class)cls;

/**
 自定义对象映射  (key: 成员变量名称 value: 对象类)
 
 @return 自定义对象映射
 */
+ (NSDictionary * _Nullable)xwdb_customModelMappingCls:(Class)cls;

#pragma mark - 模型转换
/// NSString -> Base64 String
+ (NSString *)base64WithString:(NSString *)string;
/// Base64 String -> NSString
+ (NSString *)stringWithBase64:(NSString *)base64;

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

/// NSSet -> NSString
+ (NSString *)stringWithSet:(NSSet *)set;
/// NSString -> NSSet
+ (NSSet *)setWithString:(NSString *)string;

/// NSAttributedString -> NSString
+ (NSString *)stringWithAttributedString:(NSAttributedString *)attributedString;
/// NSString -> NSAttributedString
+ (NSAttributedString *)attributedStringWithString:(NSString *)string;

/// NSIndexPath -> NSString
+ (NSString *)stringWithIndexPath:(NSIndexPath *)indexPath;
/// NSString -> NSIndexPath
+ (NSIndexPath *)indexPathWithString:(NSString *)string;

/// UIImage -> NSString
+ (NSString *)stringWithImage:(UIImage *)image;
/// NSString -> UIImage
+ (UIImage *)imageWithString:(NSString *)string;

/// NSURL -> NSString
+ (NSString *)stringWithURL:(NSURL *)URL;
/// NSString -> NSURL
+ (NSURL *)URLWithString:(NSString *)string;

/// CustomModel -> NSString
+ (NSString *)stringWithCustomModel:(id)customModel;
/// NSString -> CustomModel
+ (id)customModelWithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
