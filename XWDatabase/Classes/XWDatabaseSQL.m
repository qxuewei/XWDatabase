//
//  XWDatabaseSQL.m
//  XWDatabase
//
//  Created by 邱学伟 on 2018/12/1.
//  Copyright © 2018 邱学伟. All rights reserved.
//

#import "XWDatabaseSQL.h"
#import "XWDatabaseModel.h"
#import "NSObject+XWModel.h"

/*
 查询语句：select * from 表名 where 条件子句 group by 分组字句 having ... order by 排序子句
 如：   select * from person
 select * from person order by id desc
 select name from person group by name having count(*)>1
 分页SQL与mysql类似，下面SQL语句获取5条记录，跳过前面3条记录
 select * from Account limit 5 offset 3 或者 select * from Account limit 3,5
 插入语句：insert into 表名(字段列表) values(值列表)。如： insert into person(name, age) values(‘学伟’,3)
 更新语句：update 表名 set 字段名=值 where 条件子句。如：update person set name=‘学伟‘ where id=10
 删除语句：delete from 表名 where 条件子句。如：delete from person  where id=10
 */

@implementation XWDatabaseSQL

#pragma mark - 增

/**
 建表SQL
 
 @param cls 类
 @param isTtemporary 临时表
 
 @return 建表 sql (CREATE TABLE IF NOT EXISTS Person(xw_id INTEGER PRIMARY KEY AUTOINCREMENT,cardID text,gender text,age integer,name text))
 */
+ (NSString *)createTableSql:(Class<XWDatabaseModelProtocol>)cls isTtemporary:(BOOL)isTtemporary {
    NSString *tableName = isTtemporary ? [XWDatabaseModel tempTableName:cls] : [XWDatabaseModel tableName:cls];
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@)",tableName,[XWDatabaseModel sqlWithCreatTable:cls]];
    return sql;
}

/**
 保存单个对象SQL
 
 @param obj 模型
 @param identifier 标示符
 @return 保存单个对象SQL (insert into Person(cardID,age,gender,name) values('1','50','male','极客学伟'))
 */
+ (NSString *)insertOneObjSql:(NSObject <XWDatabaseModelProtocol> *)obj identifier:(NSString * _Nullable)identifier {
    NSString *tableName = [XWDatabaseModel tableName:obj.class];
    NSArray *columnNames = [XWDatabaseModel classColumnIvarNameTypeDict:obj.class].allKeys;
    NSMutableDictionary *insertSqlDict = [NSMutableDictionary dictionary];
    for (NSString *column in columnNames) {
        NSString *ivarName = [XWDatabaseModel ivarNameWithColumn:column cls:obj.class];
        if (!ivarName) {
            continue;
        }
        NSString *valueString = [self stringWithObject:obj ivarName:ivarName];
        if (valueString) {
            [insertSqlDict setObject:valueString forKey:column];
        } else {
            [insertSqlDict setObject:@"''" forKey:column];
        }
    }
    if (insertSqlDict.count == 0) {
        return nil;
    }
    
    NSString *identifierValue = identifier ? [NSString stringWithFormat:@"'%@'",identifier] : [NSString stringWithFormat:@"'%@'",kXWDB_IDENTIFIER_VALUE];
    [insertSqlDict setObject:identifierValue forKey:kXWDB_IDENTIFIER_COLUMNNAME];
    
    NSString *insertOneObjSql = [NSString stringWithFormat:@"INSERT INTO  %@(%@) VALUES(%@)",tableName,[insertSqlDict.allKeys componentsJoinedByString:@","],[insertSqlDict.allValues componentsJoinedByString:@","]];
    return insertOneObjSql;
}

/**
 批量更新主键SQLS  INSERT INTO XWBook_temp(xw_id) SELECT xw_id FROM XWBook
 
 @param cls 模型
 @return 批量更新主键SQLS
 */
+ (NSArray *)insertPrimarys:(Class<XWDatabaseModelProtocol>)cls {
    NSString *tempTableName = [XWDatabaseModel tempTableName:cls];
    NSString *tableName = [XWDatabaseModel tableName:cls];
    return @[[NSString stringWithFormat:@"INSERT INTO %@(%@) SELECT %@ FROM %@",tempTableName,kXWDB_PRIMARYKEY_COLUMNNAME,kXWDB_PRIMARYKEY_COLUMNNAME,tableName]];
}

#pragma mark - 删
/**
 删除表中某条数据
 
 @param obj 模型
 @return 是否删除成功
 */
+ (NSString *)deleteColumn:(NSObject <XWDatabaseModelProtocol> *)obj identifier:(NSString * _Nullable)identifier {
    /// DELETE FROM COMPANY WHERE ID = 7
    NSString *tableName = [XWDatabaseModel tableName:obj.class];
    NSString *queryCondition = [self queryCondition:obj identifier:identifier];
    if (!queryCondition) {
        return nil;
    }
    return [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ ",tableName,queryCondition];
}

/**
 清空表中所有字段
 
 @param cls 模型类
 @param condition 条件
 @return 是否删除成功
 */
+ (NSString *)clearColumn:(Class<XWDatabaseModelProtocol>)cls identifier:(NSString * _Nullable)identifier condition:(NSString *)condition {
    /// DELETE FROM COMPANY WHERE ID = 7
    NSString *tableName = [XWDatabaseModel tableName:cls];
    NSString *identifierValue = (identifier ? [NSString stringWithFormat:@"'%@'",identifier] : [NSString stringWithFormat:@"'%@'",kXWDB_IDENTIFIER_VALUE]);
    if (condition && condition.length > 0) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ ",tableName,condition];
        return [sql stringByAppendingString:[NSString stringWithFormat:@" AND %@ = %@", kXWDB_IDENTIFIER_COLUMNNAME, identifierValue]];
        
    } else {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
        return [sql stringByAppendingString:[NSString stringWithFormat:@" WHERE %@ = %@", kXWDB_IDENTIFIER_COLUMNNAME, identifierValue]];
    }
}

/**
 删除表 SQL
 
 @param cls 类
 @return 删除表 SQL
 */
+ (NSString *)dropTable:(Class<XWDatabaseModelProtocol>)cls {
    /// drop table if exists tttt
    NSString *tableName = [XWDatabaseModel tableName:cls];
    return [NSString stringWithFormat:@"drop table if exists %@",tableName];
}

#pragma mark - 改
/**
 更新单个对象SQL
 
 @param obj 模型
 @return 保存单个对象SQL
 */
+ (NSString *)updateOneObjSql:(NSObject <XWDatabaseModelProtocol> *)obj identifier:(NSString * _Nullable)identifier {
    return [self p_updateOneObjSql:obj identifier:identifier condition:nil isCustomCondition:NO customIvarNames:nil];
}

+ (NSString *)updateOneObjSql:(NSObject <XWDatabaseModelProtocol>*)obj identifier:(NSString * _Nullable)identifier condition:(NSString * _Nullable)condition isCustomCondition:(BOOL)isCustomCondition updatePropertys:(NSArray <NSString *> *)updatePropertys {
    return [self p_updateOneObjSql:obj identifier:identifier condition:condition isCustomCondition:isCustomCondition customIvarNames:updatePropertys];
}

+ (NSString *)updateConditionObjsSql:(NSObject <XWDatabaseModelProtocol> *)obj identifier:(NSString * _Nullable)identifier condition:(NSString * _Nullable)condition customIvarNames:(NSArray <NSString *> *)customIvarNames {
    
    NSString *queryCondition; //更新条件
    
    NSString *identifierValue = (identifier ? [NSString stringWithFormat:@"'%@'",identifier] : [NSString stringWithFormat:@"'%@'",kXWDB_IDENTIFIER_VALUE]);
    if (condition && condition.length > 0) {
        NSString *tempSql = [NSString stringWithFormat:@" AND %@ = %@",kXWDB_IDENTIFIER_COLUMNNAME,identifierValue];
        queryCondition = [condition stringByAppendingString:tempSql];
    } else {
        queryCondition = [NSString stringWithFormat:@"%@ = %@",kXWDB_IDENTIFIER_COLUMNNAME,identifierValue];
    }
    
    NSString *tableName = [XWDatabaseModel tableName:obj.class];
    NSArray *columnNames = ( customIvarNames && customIvarNames.count > 0) ? customIvarNames : [XWDatabaseModel classColumnIvarNameTypeDict:obj.class].allKeys;
    NSMutableArray *updateArrM = [[NSMutableArray alloc] init];
    
    NSString *primaryKey = obj.xwdb_primaryKey;
    NSArray *unionPrimaryKey = obj.xwdb_unionPrimaryKey;
    
    for (NSString *column in columnNames) {
        NSString *ivar = [XWDatabaseModel ivarNameWithColumn:column cls:obj.class];
        if (!ivar) {
            continue;
        }
        NSLog(@"%@",ivar);
        if (primaryKey) {
            if ([primaryKey isEqualToString:ivar]) {
                /// 主键不更新
                continue;
            }
        } else if (unionPrimaryKey) {
            if ([unionPrimaryKey containsObject:ivar]) {
                /// 联合主键不更新
                continue;
            }
        }
        NSString *valueString = [self stringWithObject:obj ivarName:ivar];
        NSString *save;
        if (valueString) {
            save = [NSString stringWithFormat:@"%@ = %@",column, valueString];
        } else {
            save = [NSString stringWithFormat:@"%@ = %@",column, @"''"];
        }
        [updateArrM addObject:save];
    }
    
    if (updateArrM.count == 0) {
        return nil;
    }
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ ",tableName,[updateArrM componentsJoinedByString:@","],queryCondition];
    return updateSql;
}

/**
 更新字段值 SQL
 
 @param cls 类
 @param columName 字段名
 @return 更新字段值 SQL
 */
+ (NSString *)updateColumn:(Class<XWDatabaseModelProtocol>)cls columName:(NSString *)columName {
    //update tem_table set name = (select name from XWStuModel where tem_table.stuNum = XWStuModel.stuNum)
    NSString *tempTableName = [XWDatabaseModel tempTableName:cls];
    NSString *tableName = [XWDatabaseModel tableName:cls];
    return [NSString stringWithFormat:@"UPDATE %@ SET %@ = (SELECT %@ FROM %@ WHERE %@.%@ = %@.%@)",tempTableName,columName,columName,tableName,tempTableName,kXWDB_PRIMARYKEY_COLUMNNAME,tableName,kXWDB_PRIMARYKEY_COLUMNNAME];
    
//    [NSString stringWithFormat:@"update %@ set %@ = (select %@ from %@ where %@.%@ = %@.%@)",tempTableName,columName,columName,tableName,tempTableName,primaryKey,tableName,primaryKey];
}

/**
 表重命名 SQL
 
 @param cls 类
 @return 表重命名 SQL
 */
+ (NSString *)renameTable:(Class<XWDatabaseModelProtocol>)cls {
    /// drop table if exists tttt
    NSString *tableName = [XWDatabaseModel tableName:cls];
    NSString *tempTableName = [XWDatabaseModel tempTableName:cls];
    return [NSString stringWithFormat:@"alter table %@ rename to %@",tempTableName,tableName];
}


#pragma mark - 查

/**
 查找某主键对象
 
 @param obj 模型
 @return 查找语句
 */
+ (NSString *)searchSql:(NSObject <XWDatabaseModelProtocol> *)obj identifier:(NSString * _Nullable)identifier {
    /// @"SELECT * FROM %@ WHERE %@ = '%@'"
    NSString *tableName = [XWDatabaseModel tableName:obj.class];
    NSString *queryCondition = [self queryCondition:obj identifier:identifier];
    if (!queryCondition) {
        return nil;
    }
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ ",tableName,queryCondition];
}

/**
 查找某条数据是否存在
 
 @param obj 模型
 @param identifier 标示符
 @return 是否存在 (SELECT COUNT(*) FROM Person WHERE age = '42' AND cardID = '1')
 */
+ (NSString *)isExistSql:(NSObject <XWDatabaseModelProtocol> *)obj identifier:(NSString * _Nullable)identifier {
    if (!obj.xwdb_isUpdateQueryingCondition) {
        /// 只要无主键都视为不存在
        return nil;
    }
    NSString *tableName = [XWDatabaseModel tableName:obj.class];
    NSString *queryCondition = [self queryCondition:obj identifier:identifier];
    if (!queryCondition) {
        return nil;
    }
    return [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@",tableName,queryCondition];
}

/**
 查询表内所有数据 (可按照某字段排序)
 
 @param cls 模型
 @param sortColumn 排序字段
 @param isOrderDesc 是否降序
 @param condition 自定义条件
 @return 符合条件的表内所有数据
 */
+ (NSString *)searchSql:(Class<XWDatabaseModelProtocol>)cls identifier:(NSString * _Nullable)identifier sortColumn:(NSString *)sortColumn isOrderDesc:(BOOL)isOrderDesc condition:(NSString *)condition {
    /// 查询语句：select * from 表名 where 条件子句 group by 分组字句 having ... order by 排序子句
    /// select * from person order by id desc
    NSString *tableName = [XWDatabaseModel tableName:cls];
    NSMutableString *searchSql = [NSMutableString stringWithFormat:@"SELECT * FROM %@",tableName];
    
    if (condition && condition.length > 0) {
        [searchSql appendFormat:@" WHERE %@",condition];
    }

    NSString *identifierValue = (identifier ? [NSString stringWithFormat:@"'%@'",identifier] : [NSString stringWithFormat:@"'%@'",kXWDB_IDENTIFIER_VALUE]);
    if ([searchSql containsString:@" WHERE "]) {
        [searchSql appendFormat:@" AND %@ = %@",kXWDB_IDENTIFIER_COLUMNNAME,identifierValue];
    } else {
        [searchSql appendFormat:@" WHERE %@ = %@",kXWDB_IDENTIFIER_COLUMNNAME,identifierValue];
    }
    
    if (sortColumn && sortColumn.length > 0) {
        [searchSql appendString:[NSString stringWithFormat:@" ORDER BY %@",sortColumn]];
        if (isOrderDesc) {
            [searchSql appendString:@" DESC"];
        }
    }
    return searchSql;
}

/**
 现有表 建表语句
 
 @param cls 类
 @return 表 建表语句   (SELECT sql FROM sqlite_master WHERE type = 'table' AND name = '表名')
 获取当前表的建表SQL -> (CREATE TABLE XWPerson(pRect text,birthday text,pFloat real,pLong integer,sex text,icon blob,floatNumber text,pCGFloat real,pBooll integer,books text,name text,cardID text,pBOOL integer,pUInteger integer,pSize text,number text,pPoint text,pDouble real,pLongLong integer,girls text,age integer,pInt integer,pInteger integer,primary key(cardID)))
 */
+ (NSString *)queryCreateTableSql:(Class<XWDatabaseModelProtocol>)cls {
    NSString *tableName = [XWDatabaseModel tableName:cls];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE type = 'table' AND name = '%@'",tableName];
    return sql;
}

#pragma mark - private
+ (NSString *)p_updateOneObjSql:(NSObject <XWDatabaseModelProtocol> *)obj identifier:(NSString * _Nullable)identifier condition:(NSString * _Nullable)condition isCustomCondition:(BOOL)isCustomCondition customIvarNames:(NSArray <NSString *> *)customIvarNames {
    
    NSString *queryCondition; //更新条件
    
    if (isCustomCondition) {
        NSString *identifierValue = (identifier ? [NSString stringWithFormat:@"'%@'",identifier] : [NSString stringWithFormat:@"'%@'",kXWDB_IDENTIFIER_VALUE]);
        if (condition && condition.length > 0) {
            NSString *tempSql = [NSString stringWithFormat:@" AND %@ = %@",kXWDB_IDENTIFIER_COLUMNNAME,identifierValue];
            queryCondition = [condition stringByAppendingString:tempSql];
        } else {
            queryCondition = [NSString stringWithFormat:@"%@ = %@",kXWDB_IDENTIFIER_COLUMNNAME,identifierValue];
        }
        
    } else {
        if (!obj.xwdb_isUpdateQueryingCondition) {
            return nil;
        }
        queryCondition = [self queryCondition:obj identifier:identifier];
    }
    
    if (!queryCondition) {
        return nil;
    }
    NSString *tableName = [XWDatabaseModel tableName:obj.class];
    NSArray *columnNames = ( customIvarNames && customIvarNames.count > 0) ? customIvarNames : [XWDatabaseModel classColumnIvarNameTypeDict:obj.class].allKeys;
    NSMutableArray *updateArrM = [[NSMutableArray alloc] init];
    for (NSString *column in columnNames) {
        NSString *ivar = [XWDatabaseModel ivarNameWithColumn:column cls:obj.class];
        if (!ivar) {
            continue;
        }
        NSString *valueString = [self stringWithObject:obj ivarName:ivar];
        NSString *save;
        if (valueString) {
            save = [NSString stringWithFormat:@"%@ = %@",column, valueString];
        } else {
            save = [NSString stringWithFormat:@"%@ = %@",column, @"''"];
        }
        [updateArrM addObject:save];
    }
    
    if (updateArrM.count == 0) {
        return nil;
    }
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ ",tableName,[updateArrM componentsJoinedByString:@","],queryCondition];
    return updateSql;
}

/// 根据主键查询条件
+ (NSString *)queryCondition:(NSObject <XWDatabaseModelProtocol> *)obj identifier:(NSString * _Nullable)identifier {
    NSString *sql;
    if (obj.xwdb_unionPrimaryKey) {
        NSMutableArray *unionArrayM = [[NSMutableArray alloc] init];
        for (NSString *subPrimaryKey in obj.xwdb_unionPrimaryKey) {
            NSString * ivar = [XWDatabaseModel ivarNameWithColumn:subPrimaryKey cls:obj.class];
            if (!ivar) {
                break;
            }
            NSString *valueString = [self stringWithObject:obj ivarName:ivar];
            if (!valueString) {
                /// 主键值为空不提供查询
                return nil;
            }
            [unionArrayM addObject:[NSString stringWithFormat:@"%@ = %@",subPrimaryKey,valueString]];
        }
        if (unionArrayM.count > 0) {
            sql = [unionArrayM componentsJoinedByString:@" AND "];
        }
        
    } else if (obj.xwdb_primaryKey) {
        NSString *primaryKey = [obj.class xwdb_primaryKey];
        NSString *ivar = [XWDatabaseModel ivarNameWithColumn:primaryKey cls:obj.class];
        if (ivar) {
            NSString *valueString = [self stringWithObject:obj ivarName:ivar];
            if (!valueString) {
                /// 主键值为空不提供查询
                return nil;
            }
            sql = [NSString stringWithFormat:@"%@ = %@",primaryKey,valueString];
        }
    }
    
    NSString *identifierValue = (identifier ? [NSString stringWithFormat:@"'%@'",identifier] : [NSString stringWithFormat:@"'%@'",kXWDB_IDENTIFIER_VALUE]);
    if (sql) {
        NSString *tempSql = [NSString stringWithFormat:@" AND %@ = %@",kXWDB_IDENTIFIER_COLUMNNAME,identifierValue];
        sql = [sql stringByAppendingString:tempSql];
    } else {
        sql = [NSString stringWithFormat:@"%@ = %@",kXWDB_IDENTIFIER_COLUMNNAME,identifierValue];
    }
    return sql;
}

/**
 对象转字符串(数据库存储)
 
 @param obj 对象
 @param ivarName 成员变量名称
 @return 字符串(数据库存储)
 */
+ (NSString *)stringWithObject:(NSObject <XWDatabaseModelProtocol> *)obj ivarName:(NSString *)ivarName {
    NSString *valueStr;
    NSString *string;
    id value = [obj valueForKey:ivarName];
    
    if ([XWDatabaseModel xwdb_customModelMappingCls:obj.class] && [[XWDatabaseModel xwdb_customModelMappingCls:obj.class].allKeys containsObject:ivarName]) {
        /// 自定义模型
        string = [XWDatabaseModel stringWithCustomModel:value];
        if (string) {
            return [NSString stringWithFormat:@"'%@'",string];
        } else {
            return nil;
        }
    }
    
    if ([value isKindOfClass:[NSNumber class]]) {
        string = [XWDatabaseModel stringWithNumber:value];
        
    } else if ([value isKindOfClass:[NSArray class]]) {
        string = [XWDatabaseModel stringWithArray:value];
        
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        string = [XWDatabaseModel stringWithDict:value];
        
    } else if ([value isKindOfClass:[NSData class]]) {
        string = [XWDatabaseModel stringWithData:value];
        
    } else if ([value isKindOfClass:[NSDate class]]) {
        string = [XWDatabaseModel stringWithDate:value];
        
    } else if ([value isKindOfClass:[NSSet class]]) {
        string = [XWDatabaseModel stringWithSet:value];
        
    } else if ([value isKindOfClass:[NSAttributedString class]]) {
        string = [XWDatabaseModel stringWithAttributedString:value];
        
    } else if ([value isKindOfClass:[NSIndexPath class]]) {
        string = [XWDatabaseModel stringWithIndexPath:value];
        
    } else if ([value isKindOfClass:[UIImage class]]) {
        string = [XWDatabaseModel stringWithImage:value];
        
    } else if ([value isKindOfClass:[NSURL class]]) {
        string = [XWDatabaseModel stringWithURL:value];
        
    } else {
        string = [NSString stringWithFormat:@"%@",value];
        
    }
    
    valueStr = [NSString stringWithFormat:@"'%@'",string];
    
    if ([valueStr isEqualToString:@"'(null)'"] || [valueStr isEqualToString:@"'null'"]) {
        return nil;
        
    } else {
        return valueStr;
        
    }
}

@end
