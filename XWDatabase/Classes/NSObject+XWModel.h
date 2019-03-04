//
//  NSObject+XWModel.h
//  XWDatabase_Example
//
//  Created by 邱学伟 on 2018/12/11.
//  Copyright © 2018 qxuewei@yeah.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWDatabaseModelProtocol.h"

#pragma mark - 智能归解档
#define XWCodingImplementation \
- (instancetype)initWithCoder:(NSCoder *)aDecoder{\
if(self == [super init]){\
[self xw_decode:aDecoder];\
}\
return self;\
}\
\
- (void)encodeWithCoder:(NSCoder *)aCoder{\
[self xw_encode:aCoder];\
}\
+ (BOOL)supportsSecureCoding {\
return YES;\
}

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (XWModel) <XWDatabaseModelProtocol>

/**
 默认主键 (自增)
 */
@property (nonatomic, strong) NSNumber *xw_id;

/**
 上次存储主键值
 */
@property (nonatomic, strong) NSNumber *xw_lastPrimaryKeyId;

/**
  模型中所有成员变量 (key: 成员变量名称  value: 成员变量类型)
 */
@property (nonatomic, strong) NSDictionary *xw_classIvarNameTypeDict;

/**
 模型中成员变量集合
 */
@property (nonatomic, strong) NSSet *xw_IvarSet;

/**
 模型中自定义对象
 */
@property (nonatomic, strong) NSSet *xw_CustomModelSet;

/// 归档
- (void)xw_decode:(NSCoder*)aDecoder;

/// 解档
- (void)xw_encode:(NSCoder*)aCoder;

#pragma mark - 以下方法根据 XWDatabaseModelProtocol 协议中实现获取相应值

/**
 主键 不可更改/唯一性
 
 @return 主键的属性名
 */
- (NSString * _Nullable)xwdb_primaryKey;

/**
 联合主键成员变量数组 (多个属性共同定义主键) - 优先级大于 'xwdb_primaryKey'
 
 @return 联合主键成员变量数组
 */
- (NSArray < NSString * > * _Nullable)xwdb_unionPrimaryKey;

/**
 自定义对象映射  (key: 成员变量名称 value: 对象类)
 
 @return 自定义对象映射
 */
- (NSDictionary * _Nullable)xwdb_customModelMapping;

/**
 忽略不保存数据库的属性
 
 @return 忽略的属性名数组
 */
- (NSSet <NSString *>* _Nullable)xwdb_ignoreColumnNames;

/**
 自定义字段名映射表 (默认成员变量即变量名, 可自定义字段名 key: 成员变量(属性)名称  value: 自定义数据库表字段名)
 
 @return 自定义字段名映射表
 */
- (NSDictionary * _Nullable)xwdb_customColumnMapping;

/**
 自定义表名 (默认属性类名)
 
 @return 自定义表名
 */
- (NSString * _Nullable)xwdb_customTableName;

/**
 自定义存储的属性数组, 实现此协议在存储时将自动忽略其他属性( 'xw_ignoreColumnNames' 将无效),
 
 @return 自定义存储的属性数组
 */
- (NSSet < NSString * > * _Nullable)xw_specificSaveColumnNames;

/**
 是否通过唯一标识将数据存储于不同数据库, 若为YES必须实现 "xw_databaseIdentifierColumnName" 协议, YES: 模型根据指定标识字段区分存储的数据库  NO(或不实现): 模型存储在通用数据库内
 
 @return 是否通过唯一标识将数据存储于不同数据库
 */
- (BOOL)xw_isDatabaseIdentifier;

/**
 数据库唯一标识属性名, 区分数据存储于不同数据库  ('xw_isDatabaseIdentifier' 返回 YES 时生效)
 
 @return 数据库唯一标识
 */
- (NSString * _Nullable)xw_databaseIdentifierColumnName;

@end

NS_ASSUME_NONNULL_END
