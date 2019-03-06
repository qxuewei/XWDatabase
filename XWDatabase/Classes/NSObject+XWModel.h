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

#pragma mark 常量
UIKIT_EXTERN NSString * const kXWDB_IDENTIFIER_COLUMNNAME;//    =   @"xw_identifier";   //唯一标识字段名称
UIKIT_EXTERN NSString * const kXWDB_PRIMARYKEY_COLUMNNAME;//    =   @"xw_id";           //默认自增主键字段名称


@interface NSObject (XWModel) <XWDatabaseModelProtocol>

/**
 是否具备数据可 更新/查询 条件

 @return 是否具备数据可 更新/查询 条件
 */
- (BOOL)xwdb_isUpdateQueryingCondition;

/**
 默认主键 (自增)
 */
//@property (nonatomic, strong) NSNumber *xw_id;

/**
 上次存储主键值
 */
//@property (nonatomic, strong) NSNumber *xw_lastPrimaryKeyId;

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


#pragma mark - 智能归解档
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
- (NSSet < NSString * > * _Nullable)xwdb_specificSaveColumnNames;

@end

NS_ASSUME_NONNULL_END
