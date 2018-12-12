//
//  NSObject+XWModel.h
//  XWDatabase_Example
//
//  Created by 邱学伟 on 2018/12/11.
//  Copyright © 2018 qxuewei@yeah.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWDatabaseModelProtocol.h"

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

#pragma mark - 以下方法根据 XWDatabaseModelProtocol 协议中实现获取相应值

/**
 主键 不可更改/唯一性
 
 @return 主键的属性名
 */
- (NSString *)xwdb_primaryKey;

/**
 联合主键成员变量数组 (多个属性共同定义主键) - 优先级大于 'xwdb_primaryKey'
 
 @return 联合主键成员变量数组
 */
- (NSArray < NSString * > *)xwdb_unionPrimaryKey;

/**
 自定义对象映射  (key: 成员变量名称 value: 对象类)
 
 @return 自定义对象映射
 */
- (NSDictionary *)xwdb_customModelMapping;

/**
 忽略不保存数据库的属性
 
 @return 忽略的属性名数组
 */
- (NSSet <NSString *>*)xwdb_ignoreColumnNames;

/**
 自定义字段名映射表 (默认成员变量即变量名, 可自定义字段名 key: 成员变量(属性)名称  value: 自定义数据库表字段名)
 
 @return 自定义字段名映射表
 */
- (NSDictionary *)xwdb_customColumnMapping;

/**
 自定义表名 (默认属性类名)
 
 @return 自定义表名
 */
- (NSString *)xwdb_customTableName;

@end

NS_ASSUME_NONNULL_END
