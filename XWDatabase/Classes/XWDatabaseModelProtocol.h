//
//  XWDatabaseModelProtocol.h
//  XWDatabase
//
//  Created by 邱学伟 on 2018/11/29.
//  Copyright © 2018 邱学伟. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 模型操作数据库所遵循的协议
@protocol XWDatabaseModelProtocol <NSObject>

@optional

/**
 主键 不可更改/唯一性
 
 @return 主键的属性名
 */
+ (NSString *)xw_primaryKey;

/**
 联合主键成员变量数组 (多个属性共同定义主键) - 优先级大于 'xw_primaryKey'

 @return 联合主键成员变量数组
 */
+ (NSArray < NSString * > *)xw_unionPrimaryKey;

/**
 自定义对象映射  (key: 成员变量名称 value: 对象类)

 @return 自定义对象映射
 */
+ (NSDictionary *)xw_customModelMapping;

/**
 忽略不保存数据库的属性
 
 @return 忽略的属性名数组
 */
+ (NSSet <NSString *>*)xw_ignoreColumnNames;

/**
 自定义字段名映射表 (默认成员变量即变量名, 可自定义字段名 key: 成员变量(属性)名称  value: 自定义数据库表字段名)

 @return 自定义字段名映射表
 */
+ (NSDictionary *)xw_customColumnMapping;

/**
 自定义表名 (默认属性类名)

 @return 自定义表名
 */
+ (NSString *)xw_customTableName;

/**
 自定义存储的属性数组, 实现此协议在存储时将自动忽略其他属性
 
 @return 自定义存储的属性数组
 */
+ (NSSet < NSString * > *)xw_specificSaveColumnNames;

/**
 是否通过唯一标识将数据存储于不同数据库, 若为YES必须实现 "xw_databaseIdentifierColumnName" 协议, YES: 模型根据指定标识字段区分存储的数据库  NO(或不实现): 模型存储在通用数据库内

 @return 是否通过唯一标识将数据存储于不同数据库
 */
+ (BOOL)xw_isDatabaseIdentifier;

/**
 数据库唯一标识属性名, 区分数据存储于不同数据库  ('xw_isDatabaseIdentifier' 返回 YES 时生效)

 @return 数据库唯一标识
 */
+ (NSString *)xw_databaseIdentifierColumnName;

@end
