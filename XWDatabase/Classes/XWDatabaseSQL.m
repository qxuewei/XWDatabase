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
    return [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@)",tableName,[XWDatabaseModel sqlWithCreatTable:cls]];
}

/**
 保存单个对象SQL
 
 @param obj 模型
 @return 保存单个对象SQL (insert into Person(cardID,age,gender,name) values('1','50','male','极客学伟'))
 */
+ (NSString *)saveOneObjSql:(NSObject <XWDatabaseModelProtocol> *)obj {
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
    NSString *saveOneObjSql = [NSString stringWithFormat:@"INSERT INTO  %@(%@) VALUES(%@)",tableName,[insertSqlDict.allKeys componentsJoinedByString:@","],[insertSqlDict.allValues componentsJoinedByString:@","]];
    return saveOneObjSql;
}

/**
 批量更新主键SQLS
 
 @param cls 模型
 @return 批量更新主键SQLS
 */
+ (NSArray *)insertPrimarys:(Class<XWDatabaseModelProtocol>)cls {
    NSString *tempTableName = [XWDatabaseModel tempTableName:cls];
    NSString *tableName = [XWDatabaseModel tableName:cls];
    return @[[NSString stringWithFormat:@"INSERT INTO %@(xw_id) SELECT xw_id FROM %@",tempTableName,tableName]];
}

#pragma mark - 删
/**
 删除表中某条数据
 
 @param obj 模型
 @return 是否删除成功
 */
+ (NSString *)deleteColumn:(NSObject <XWDatabaseModelProtocol> *)obj {
    /// DELETE FROM COMPANY WHERE ID = 7
    NSString *tableName = [XWDatabaseModel tableName:obj.class];
    NSString *queryCondition = [self queryCondition:obj];
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
+ (NSString *)clearColumn:(Class<XWDatabaseModelProtocol>)cls condition:(NSString *)condition {
    /// DELETE FROM COMPANY WHERE ID = 7
    NSString *tableName = [XWDatabaseModel tableName:cls];
    if (condition && condition.length > 0) {
        return [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ ",tableName,condition];
    } else {
        return [NSMutableString stringWithFormat:@"DELETE FROM %@",tableName];
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
+ (NSString *)updateOneObjSql:(NSObject <XWDatabaseModelProtocol> *)obj {
    return [self p_updateOneObjSql:obj customIvarNames:nil];
}

+ (NSString *)updateOneObjSql:(NSObject <XWDatabaseModelProtocol>*)obj updatePropertys:(NSArray <NSString *> *)updatePropertys {
    return [self p_updateOneObjSql:obj customIvarNames:updatePropertys];
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
    return [NSString stringWithFormat:@"UPDATE %@ SET %@ = (SELECT %@ FROM %@ WHERE %@.xw_id = %@.xw_id)",tempTableName,columName,columName,tableName,tempTableName,tableName];
    
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
+ (NSString *)searchSql:(NSObject <XWDatabaseModelProtocol> *)obj {
    /// @"SELECT * FROM %@ WHERE %@ = '%@'"
    NSString *tableName = [XWDatabaseModel tableName:obj.class];
    NSString *queryCondition = [self queryCondition:obj];
    if (!queryCondition) {
        return nil;
    }
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ ",tableName,queryCondition];
}

/**
 查找某条数据是否存在
 
 @param obj 模型
 @return 是否存在 (SELECT COUNT(*) FROM Person WHERE age = '42' AND cardID = '1')
 */
+ (NSString *)isExistSql:(NSObject <XWDatabaseModelProtocol> *)obj {
    NSString *tableName = [XWDatabaseModel tableName:obj.class];
    NSString *queryCondition = [self queryCondition:obj];
    if (queryCondition) {
        return [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@",tableName,queryCondition];
    }
    return nil;
}

/**
 查询表内所有数据 (可按照某字段排序)
 
 @param cls 模型
 @param sortColumn 排序字段
 @param isOrderDesc 是否降序
 @param condition 自定义条件
 @return 符合条件的表内所有数据
 */
+ (NSString *)searchSql:(Class<XWDatabaseModelProtocol>)cls sortColumn:(NSString *)sortColumn isOrderDesc:(BOOL)isOrderDesc condition:(NSString *)condition {
    /// 查询语句：select * from 表名 where 条件子句 group by 分组字句 having ... order by 排序子句
    /// select * from person order by id desc
    NSString *tableName = [XWDatabaseModel tableName:cls];
    NSMutableString *searchSql = [NSMutableString stringWithFormat:@"SELECT * FROM %@",tableName];
    
    if (condition && condition.length > 0) {
        [searchSql appendString:[NSString stringWithFormat:@" WHERE %@",condition]];
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
    return [NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE type = 'table' AND name = '%@'",tableName];
}

#pragma mark - private
+ (NSString *)p_updateOneObjSql:(NSObject <XWDatabaseModelProtocol> *)obj customIvarNames:(NSArray <NSString *> *)customIvarNames {
    if (!obj.xwdb_primaryKey && !obj.xwdb_unionPrimaryKey) {
        return nil;
    }
    NSString *queryCondition = [self queryCondition:obj];
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
+ (NSString *)queryCondition:(NSObject <XWDatabaseModelProtocol> *)obj {
    if (obj.xwdb_unionPrimaryKey) {
        NSMutableArray *unionArrayM = [[NSMutableArray alloc] init];
        for (NSString *subPrimaryKey in obj.xwdb_unionPrimaryKey) {
            NSString * ivar = [XWDatabaseModel ivarNameWithColumn:subPrimaryKey cls:obj.class];
            if (!ivar) {
                return nil;
            }
            NSString *valueString = [self stringWithObject:obj ivarName:ivar];
            if (!valueString) {
                /// 联合主键任意对象为空均不做操作!
                return nil;
            }
            [unionArrayM addObject:[NSString stringWithFormat:@"%@ = %@",subPrimaryKey,valueString]];
        }
        if (unionArrayM.count > 0) {
            NSString *searchSql = [unionArrayM componentsJoinedByString:@" AND "];
            return searchSql;
        }
        
    } else if (obj.xwdb_primaryKey) {
        NSString *primaryKey = [obj.class xwdb_primaryKey];
        NSString *ivar = [XWDatabaseModel ivarNameWithColumn:primaryKey cls:obj.class];
        if (!ivar) {
            return nil;
        }
        NSString *valueString = [self stringWithObject:obj ivarName:ivar];
        if (valueString) {
            return [NSString stringWithFormat:@"%@ = %@",primaryKey,valueString];
        }
        
    }
    return nil;
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
    
    if (obj.xwdb_customModelMapping && [obj.xwdb_customModelMapping.allKeys containsObject:ivarName]) {
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
