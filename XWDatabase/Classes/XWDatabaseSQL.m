//
//  XWDatabaseSQL.m
//  XWDatabase
//
//  Created by 邱学伟 on 2018/12/1.
//  Copyright © 2018 邱学伟. All rights reserved.
//

#import "XWDatabaseSQL.h"
#import "XWDatabaseModel.h"


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

/**
 建表SQL

 @param cls 类
 @param isTtemporary 临时表
 @return 建表 sql
 */
+ (NSString *)createTableSql:(Class<XWDatabaseModelProtocol>)cls isTtemporary:(BOOL)isTtemporary {
    NSString *tableName = isTtemporary ? [XWDatabaseModel tempTableName:cls] : [XWDatabaseModel tableName:cls];
    NSString *primaryKey = [cls xw_primaryKey];
    return [NSString stringWithFormat:@"create table if not exists %@(%@,primary key(%@))",tableName,[XWDatabaseModel sqlWithCreatTable:cls],primaryKey];
}


/**
 现有表 建表语句

 @param cls 类
 @return 表 建表语句
 */
+ (NSString *)queryCreateTableSql:(Class<XWDatabaseModelProtocol>)cls {
    NSString *tableName = [XWDatabaseModel tableName:cls];
    //SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'XWStuModel'
    return [NSString stringWithFormat:@"SELECT * FROM sqlite_master WHERE type = 'table' AND name = '%@'",tableName];
}

/**
 查找某主键对象

 @param obj 模型
 @return 查找语句
 */
+ (NSString *)searchSql:(NSObject <XWDatabaseModelProtocol> *)obj {
    /// @"SELECT * FROM %@ WHERE %@ = '%@'"
    NSString *tableName = [XWDatabaseModel tableName:obj.class];
    NSString *primaryKey = [obj.class xw_primaryKey];
    NSString *primaryKeyObject = [NSString stringWithFormat:@"%@",[obj valueForKey:primaryKey]];
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",tableName,primaryKey,primaryKeyObject];
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
 查找某条数据是否存在

 @param obj 模型
 @return 是否存在
 */
+ (NSString *)isExistSql:(NSObject <XWDatabaseModelProtocol> *)obj {
    // SELECT COUNT(Name) AS countNum FROM Member WHERE Name = ?
    NSString *tableName = [XWDatabaseModel tableName:obj.class];
    NSString *primaryKey = [obj.class xw_primaryKey];
    NSString *primaryKeyObject = [NSString stringWithFormat:@"%@",[obj valueForKey:primaryKey]];
    return [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@ = '%@'",tableName,primaryKey,primaryKeyObject];
}


/**
 保存单个对象SQL

 @param obj 模型
 @return 保存单个对象SQL
 */
+ (NSString *)saveOneObjSql:(NSObject <XWDatabaseModelProtocol> *)obj {
    NSString *tableName = [XWDatabaseModel tableName:obj.class];
    NSDictionary *classIvarNameTypeDict = [XWDatabaseModel classIvarNameTypeDict:obj.class];
    NSArray *ivarNames = classIvarNameTypeDict.allKeys;
    NSMutableDictionary *insertSqlDict = [NSMutableDictionary dictionary];
    for (NSString *ivarName in ivarNames) {
        id value = [obj valueForKey:ivarName];
        if (!value) {
            continue ;
        }
        NSString *valueString = [self stringWithValue:value];
        if (valueString) {
            [insertSqlDict setObject:valueString forKey:ivarName];
        }
    }
    NSString *saveOneObjSql = [NSString stringWithFormat:@"insert into %@(%@) values(%@)",tableName,[insertSqlDict.allKeys componentsJoinedByString:@","],[insertSqlDict.allValues componentsJoinedByString:@","]];
    return saveOneObjSql;
}

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

+ (NSString *)p_updateOneObjSql:(NSObject <XWDatabaseModelProtocol> *)obj customIvarNames:(NSArray <NSString *> *)customIvarNames {
    
    NSString *tableName = [XWDatabaseModel tableName:obj.class];
    NSDictionary *classIvarNameTypeDict = [XWDatabaseModel classIvarNameTypeDict:obj.class];
    NSArray *ivarNames = ( customIvarNames && customIvarNames.count > 0) ? customIvarNames : classIvarNameTypeDict.allKeys;
    NSMutableArray *updateArrM = [[NSMutableArray alloc] init];
    for (NSString *ivarName in ivarNames) {
        id value = [obj valueForKey:ivarName];
        NSString *valueString = [self stringWithValue:value];
        NSString *save;
        if (valueString) {
            save = [NSString stringWithFormat:@"%@ = %@",ivarName, valueString];
        } else {
            save = [NSString stringWithFormat:@"%@ = %@",ivarName, @"''"];
        }
        [updateArrM addObject:save];
    }
    NSString *primaryKey = [obj.class xw_primaryKey];
    NSString *primaryKeyObject = [NSString stringWithFormat:@"%@",[obj valueForKey:primaryKey]];
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = '%@'",tableName,[updateArrM componentsJoinedByString:@","],primaryKey,primaryKeyObject];
    //    NSLog(@"saveOneObjSql: %@ \n",updateSql);
    return updateSql;
}

/**
 更新主键SQL

 @param cls 类
 @return 更新主键SQL
 */
+ (NSString *)insertPrimary:(Class<XWDatabaseModelProtocol>)cls {
    //insert into tem_table(stuNum) select stuNum from XWStuModel
    NSString *tempTableName = [XWDatabaseModel tempTableName:cls];
    NSString *tableName = [XWDatabaseModel tableName:cls];
    NSString *primaryKey = [cls xw_primaryKey];
    return [NSString stringWithFormat:@"insert into %@(%@) select %@ from %@",tempTableName,primaryKey,primaryKey,tableName];
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
    NSString *primaryKey = [cls xw_primaryKey];
    return [NSString stringWithFormat:@"update %@ set %@ = (select %@ from %@ where %@.%@ = %@.%@)",tempTableName,columName,columName,tableName,tempTableName,primaryKey,tableName,primaryKey];
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

/**
 删除表中某字段

 @param obj 模型
 @return 是否删除成功
 */
+ (NSString *)deleteColumn:(NSObject <XWDatabaseModelProtocol> *)obj {
    /// DELETE FROM COMPANY WHERE ID = 7
    NSString *tableName = [XWDatabaseModel tableName:obj.class];
    NSString *primaryKey = [obj.class xw_primaryKey];
    NSString *primaryKeyObject = [NSString stringWithFormat:@"%@",[obj valueForKey:primaryKey]];
    return [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = '%@'",tableName,primaryKey,primaryKeyObject];
}

/**
 清空表中所有字段
 
 @param cls 模型类
 @return 是否删除成功
 */
+ (NSString *)clearColumn:(Class<XWDatabaseModelProtocol>)cls {
    /// DELETE FROM COMPANY WHERE ID = 7
    NSString *tableName = [XWDatabaseModel tableName:cls];
    return [NSString stringWithFormat:@"DELETE FROM %@",tableName];
}

#pragma mark - private
/**
 对象转字符串(数据库存储)
 
 @param value 对象
 @return 字符串(数据库存储)
 */
+ (NSString *)stringWithValue:(id)value {
    NSString *valueStr;
    NSString *string;
    
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
