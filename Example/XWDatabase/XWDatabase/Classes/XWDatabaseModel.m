//
//  XWDatabaseModel.m
//  XWDatabase
//
//  Created by 邱学伟 on 2018/11/29.
//  Copyright © 2018 邱学伟. All rights reserved.
//

#import "XWDatabaseModel.h"
#import <objc/runtime.h>

@implementation XWDatabaseModel
static NSString * const kDatabaseModelToolDateFormatter = @"yyyy-MM-dd HH:mm:ss zzz";
static NSDateFormatter *_databaseModelToolDateFormatter;

#pragma mark - Public
/**
 表名
 
 @param cls 属性类
 @return 表名
 */
+ (NSString *)tableName:(Class<XWDatabaseModelProtocol>)cls {
    return NSStringFromClass(cls);
}

/**
 临时表名
 
 @param cls 模型类
 @return 临时表名
 */
+ (NSString *)tempTableName:(Class<XWDatabaseModelProtocol>)cls {
    return [NSStringFromClass(cls) stringByAppendingString:@"_temp"];
}

/**
 模型中所有成员变量 (key: 成员变量名称  value: 成员变量类型)
 
 @param cls 模型类
 @return 模型中所有成员变量
 */
+ (NSDictionary *)classIvarNameTypeDict:(Class<XWDatabaseModelProtocol>)cls {
    NSMutableDictionary *dictM = [[NSMutableDictionary alloc] init];
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList(cls, &count);
    NSSet *ignoreColumn = [[NSSet alloc] init];
    if ([cls respondsToSelector:@selector(xw_ignoreColumnNames)]) {
        ignoreColumn = [cls xw_ignoreColumnNames];
    }
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        /// 成员变量名称
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        if ([ivarName hasPrefix:@"_"]) {
            ivarName = [ivarName substringFromIndex:1];
        }
        if ([ignoreColumn containsObject:ivarName]) {
            continue;
        }
        /// 成员变量类型
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        ivarType = [ivarType stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
        [dictM setObject:ivarType forKey:ivarName];
    }
    free(ivarList);
    return dictM;
}

/**
 模型中所有成员变量在Sqlite 数据库中对应的类型
 
 @param cls 模型类
 @return 模型中所有成员变量在Sqlite 数据库中对应的类型
 */
+ (NSDictionary *)classIvarNameSqliteTypeDict:(Class<XWDatabaseModelProtocol>)cls {
    NSMutableDictionary *ivarOriginDict = [[self classIvarNameTypeDict:cls] mutableCopy];
    NSDictionary *dictionaryOcTypeToSqliteType = [self dictionaryOcTypeToSqliteType];
    [ivarOriginDict enumerateKeysAndObjectsUsingBlock:^(NSString * name, NSString * originType, BOOL * _Nonnull stop) {
//        BOOL isKeyExist = [dictionaryOcTypeToSqliteType.allKeys containsObject:originType];
//        NSLog(@"%@  isKeyExist: (%d)",originType,isKeyExist);
        ivarOriginDict[name] = dictionaryOcTypeToSqliteType[originType];
    }];
    return ivarOriginDict.copy;
}

/**
 模型建表的Sql语句

 @param cls 模型类
 @return 模型建表的Sql语句
 */
+ (NSString *)sqlWithCreatTable:(Class<XWDatabaseModelProtocol>)cls {
    NSMutableArray *arrayM = [[NSMutableArray alloc] init];
    NSDictionary *classIvarNameSqliteTypeDict = [self classIvarNameSqliteTypeDict:cls];
    [classIvarNameSqliteTypeDict enumerateKeysAndObjectsUsingBlock:^(NSString * name, NSString * sqliteType, BOOL * _Nonnull stop) {
        NSMutableString *subSql = [NSMutableString stringWithFormat:@"%@ %@",name,sqliteType];
        [arrayM addObject:subSql];
    }];
    return [arrayM componentsJoinedByString:@","];
}

/**
 模型根据字母排序的属性数组

 @param cls 模型类
 @return 模型根据字母排序的属性数组
 */
+ (NSArray <NSString *>*)sortedIvarNames:(Class<XWDatabaseModelProtocol>)cls {
    NSDictionary *classIvarNameTypeDict = [self classIvarNameTypeDict:cls];
    NSMutableArray *names = classIvarNameTypeDict.allKeys.mutableCopy;
    [names sortUsingComparator:^NSComparisonResult(NSString * obj1, NSString * obj2) {
        return [obj1 compare:obj2];
    }];
    return names.copy;
}

/// NSAarray -> NSString
+ (NSString *)stringWithArray:(NSArray *)array {
    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
/// NSString -> NSArray
+ (NSArray *)arrayWithString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

/// NSDictionary -> NSString
+ (NSString *)stringWithDict:(NSDictionary *)dict {
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
/// NSDictionary -> NSArray
+ (NSDictionary *)dictWithString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

///  NSData -> NSString
+ (NSString *)stringWithData:(NSData *)data {
    return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}
/// NSString -> NSData
+ (NSData *)dataWithString:(NSString *)string {
    return [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

///  NSDate -> NSString
+ (NSString *)stringWithDate:(NSDate *)date {
    return [[self dateFormatter] stringFromDate:date];
}
/// NSString -> NSDate
+ (NSDate *)dateWithString:(NSString *)string {
    return [[self dateFormatter] dateFromString:string];
}


#pragma mark - private
+ (NSDictionary *)dictionaryOcTypeToSqliteType {
    
    return @{
             @"d": @"real",     // double
             @"f": @"real",     // float
             @"s": @"integer",  // short
             @"i": @"integer",  // int
             @"q": @"integer",  // long
             @"l": @"integer",  // long
             @"I": @"integer",  // NSInteger
             @"Q": @"integer",  // long long
             @"B": @"integer",  // bool
             @"c": @"integer",  // bool
             @"NSData": @"blob",
             @"NSDate": @"text",
             @"NSDictionary": @"text",
             @"NSMutableDictionary": @"text",
             @"NSArray": @"text",
             @"NSMutableArray": @"text",
             @"NSString": @"text",
             @"{CGPoint=\"x\"d\"y\"d}": @"text",
             @"{CGRect=\"origin\"{CGPoint=\"x\"d\"y\"d}\"size\"{CGSize=\"width\"d\"height\"d}}": @"text",
             @"{CGSize=\"width\"d\"height\"d}" : @"text"
             };
}

+ (NSDateFormatter *)dateFormatter {
    if (!_databaseModelToolDateFormatter) {
        _databaseModelToolDateFormatter = [[NSDateFormatter alloc] init];
        _databaseModelToolDateFormatter.dateFormat = kDatabaseModelToolDateFormatter;
    }
    return _databaseModelToolDateFormatter;
}
@end
