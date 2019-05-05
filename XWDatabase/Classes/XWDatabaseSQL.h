//
//  XWDatabaseSQL.h
//  XWDatabase
//
//  Created by 邱学伟 on 2018/12/1.
//  Copyright © 2018 邱学伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWDatabaseModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface XWDatabaseSQL : NSObject
#pragma mark - 增

/**
 建表SQL
 
 @param cls 类
 @param isTtemporary 临时表
 
 @return 建表 sql (CREATE TABLE IF NOT EXISTS Person(xw_id INTEGER PRIMARY KEY AUTOINCREMENT,cardID text,gender text,age integer,name text))
 */
+ (NSString *)createTableSql:(Class<XWDatabaseModelProtocol>)cls isTtemporary:(BOOL)isTtemporary;

/**
 保存单个对象SQL
 
 @param obj 模型
 @param identifier 标示符
 @return 保存单个对象SQL (insert into Person(cardID,age,gender,name) values('1','50','male','极客学伟'))
 */
+ (NSString *)insertOneObjSql:(NSObject <XWDatabaseModelProtocol> *)obj identifier:(NSString * _Nullable)identifier;

/**
 批量更新主键SQLS
 
 @param cls 模型
 @return 批量更新主键SQLS
 */
+ (NSArray *)insertPrimarys:(Class<XWDatabaseModelProtocol>)cls;

#pragma mark - 删
/**
 删除表中某条数据
 
 @param obj 模型
 @param identifier 标示符
 @return 是否删除成功
 */
+ (NSString *)deleteColumn:(NSObject <XWDatabaseModelProtocol> *)obj identifier:(NSString * _Nullable)identifier;

/**
 清空表中所有字段
 
 @param cls 模型类
 @param condition 条件
 @return 是否删除成功
 */
+ (NSString *)clearColumn:(Class<XWDatabaseModelProtocol>)cls identifier:(NSString * _Nullable)identifier condition:(NSString *)condition;

/**
 删除表 SQL
 
 @param cls 类
 @return 删除表 SQL
 */
+ (NSString *)dropTable:(Class<XWDatabaseModelProtocol>)cls;

#pragma mark - 改
/**
 更新单个对象SQL
 
 @param obj 模型
 @return 保存单个对象SQL
 */
+ (NSString *)updateOneObjSql:(NSObject <XWDatabaseModelProtocol> *)obj identifier:(NSString * _Nullable)identifier;

/**
 更新单个对象SQL

 @param obj 模型
 @param identifier 唯一标识
 @param condition 自定义更新条件
 @param isCustomCondition 是否自定义更新条件
 @param updatePropertys 所更新的属性 s
 @return 更新单个对象SQL语句
 */
+ (NSString *)updateOneObjSql:(NSObject <XWDatabaseModelProtocol>*)obj identifier:(NSString * _Nullable)identifier condition:(NSString * _Nullable)condition isCustomCondition:(BOOL)isCustomCondition updatePropertys:(NSArray <NSString *> *)updatePropertys;


/**
 更新指定约束对象SQL

 @param obj 对象
 @param identifier 唯一标识
 @param condition 更新条件
 @param customIvarNames 所更新的属性 s
 @return 更新指定约束对象SQL
 */
+ (NSString *)updateConditionObjsSql:(NSObject <XWDatabaseModelProtocol> *)obj identifier:(NSString * _Nullable)identifier condition:(NSString * _Nullable)condition customIvarNames:(NSArray <NSString *> *)customIvarNames;

/**
 更新字段值 SQL
 
 @param cls 类
 @param columName 字段名
 @return 更新字段值 SQL
 */
+ (NSString *)updateColumn:(Class<XWDatabaseModelProtocol>)cls columName:(NSString *)columName;

/**
 表重命名 SQL
 
 @param cls 类
 @return 表重命名 SQL
 */
+ (NSString *)renameTable:(Class<XWDatabaseModelProtocol>)cls;

#pragma mark - 查


/**
 查询当前类对应的表是否存在
 
 @param cls 类
 @return 查询语句
 */
+ (NSString *)isExistTableCls:(Class<XWDatabaseModelProtocol>)cls;

/**
 查找某主键对象
 
 @param obj 模型
 @param identifier 标示符
 @return 查找语句
 */
+ (NSString *)searchSql:(NSObject <XWDatabaseModelProtocol> *)obj identifier:(NSString * _Nullable)identifier;

/**
 查找某条数据是否存在
 
 @param obj 模型
 @return 是否存在 (SELECT COUNT(*) FROM Person WHERE age = '42' AND cardID = '1')
 */
+ (NSString *)isExistSql:(NSObject <XWDatabaseModelProtocol> *)obj identifier:(NSString * _Nullable)identifier;

/**
 查询表内所有数据 (可按照某字段排序)
 
 @param cls 模型
 @param sortColumn 排序字段
 @param isOrderDesc 是否降序
 @param condition 自定义条件
 @param limitCount 限制个数
 @return 符合条件的表内所有数据
 */
+ (NSString *)searchSql:(Class<XWDatabaseModelProtocol>)cls identifier:(NSString * _Nullable)identifier sortColumn:(NSString *)sortColumn isOrderDesc:(BOOL)isOrderDesc condition:(NSString *)condition limitCount:(NSUInteger)limitCount;

/**
 现有表 建表语句
 
 @param cls 类
 @return 表 建表语句   (SELECT sql FROM sqlite_master WHERE type = 'table' AND name = '表名')
 获取当前表的建表SQL -> (CREATE TABLE XWPerson(pRect text,birthday text,pFloat real,pLong integer,sex text,icon blob,floatNumber text,pCGFloat real,pBooll integer,books text,name text,cardID text,pBOOL integer,pUInteger integer,pSize text,number text,pPoint text,pDouble real,pLongLong integer,girls text,age integer,pInt integer,pInteger integer,primary key(cardID)))
 */
+ (NSString *)queryCreateTableSql:(Class<XWDatabaseModelProtocol>)cls;

@end

NS_ASSUME_NONNULL_END
