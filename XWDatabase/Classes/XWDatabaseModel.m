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
static NSDateFormatter *_dateFormatter;
static NSNumberFormatter *_numberFormatter;

#pragma mark - Public
/**
 表名
 
 @param cls 属性类
 @return 表名
 */
+ (NSString *)tableName:(Class<XWDatabaseModelProtocol>)cls {
    NSString *tableName = NSStringFromClass(cls);
    if ([cls respondsToSelector:@selector(xw_customTableName)]) {
        NSString *name = [cls xw_customTableName];
        if (name && name.length > 0) {
            tableName = name;
        }
    }
    return tableName;
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
    NSSet *ignoreColumn;    /// 忽略的字段
    if ([cls respondsToSelector:@selector(xw_ignoreColumnNames)]) {
        ignoreColumn = [cls xw_ignoreColumnNames];
    }
    NSDictionary *customColumnMapping;  /// 自定义字段名
    if ([cls respondsToSelector:@selector(xw_customColumnMapping)]) {
        customColumnMapping = [cls xw_customColumnMapping];
    }
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        /// 成员变量名称
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        if ([ivarName hasPrefix:@"_"]) {
            ivarName = [ivarName substringFromIndex:1];
        }
        if (ignoreColumn && [ignoreColumn containsObject:ivarName]) {
            continue;
        }
        /// 成员变量类型
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        ivarType = [ivarType stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
        
        if (customColumnMapping && [customColumnMapping.allKeys containsObject:ivarName]) {
            ivarName = customColumnMapping[ivarName];
        }
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
    [arrayM addObject:@"xw_id INTEGER PRIMARY KEY AUTOINCREMENT"];  /// 自定义主键
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

/// NSData -> NSString
+ (NSString *)stringWithData:(NSData *)data {
    return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}
/// NSString -> NSData
+ (NSData *)dataWithString:(NSString *)string {
    return [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

/// NSDate -> NSString
+ (NSString *)stringWithDate:(NSDate *)date {
    return [[self dateFormatter] stringFromDate:date];
}
/// NSString -> NSDate
+ (NSDate *)dateWithString:(NSString *)string {
    return [[self dateFormatter] dateFromString:string];
}

/// NSNumber -> NSString
+ (NSString *)stringWithNumber:(NSNumber *)number {
    return [number stringValue];
}
/// NSString -> NSNumber
+ (NSNumber *)numberWithString:(NSString *)string {
    return [[self numberFormatter] numberFromString:string];
}

/// NSSet -> NSString
+ (NSString *)stringWithSet:(NSSet *)set {
    NSArray *array = [set allObjects];
    return [self stringWithArray:array];
}
/// NSString -> NSSet
+ (NSSet *)setWithString:(NSString *)string {
    NSArray *array = [self arrayWithString:string];
    return [NSSet setWithArray:array];
}

/// NSAttributedString -> NSString
+ (NSString *)stringWithAttributedString:(NSAttributedString *)attributedString {
    NSData *data = [attributedString dataFromRange:NSMakeRange(0, attributedString.length) documentAttributes:@{NSDocumentTypeDocumentAttribute : NSRTFDTextDocumentType} error:nil];
    return [self stringWithData:data];
}
/// NSString -> NSAttributedString
+ (NSAttributedString *)attributedStringWithString:(NSString *)string {
    NSData *data = [self dataWithString:string];
    return [[NSAttributedString alloc] initWithData:data options:@{NSDocumentTypeDocumentAttribute : NSRTFDTextDocumentType} documentAttributes:nil error:nil];
}

/// NSAttributedString -> NSString
+ (NSString *)stringWithIndexPath:(NSIndexPath *)indexPath {
    if (@available(iOS 11.0, *)) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:indexPath requiringSecureCoding:YES error:nil];
        return [self stringWithData:data];
    } else {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:indexPath];
        return [self stringWithData:data];
    }
}
/// NSString -> NSAttributedString
+ (NSIndexPath *)indexPathWithString:(NSString *)string {
    NSData *data = [self dataWithString:string];
    if (@available(iOS 11.0, *)) {
        NSIndexPath *indexPath = [NSKeyedUnarchiver unarchivedObjectOfClass:NSIndexPath.class fromData:data error:nil];
        return indexPath;
    } else {
        NSIndexPath *indexPath = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return indexPath;
    }
}

#pragma mark - private
+ (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = kDatabaseModelToolDateFormatter;
    }
    return _dateFormatter;
}

+ (NSNumberFormatter *)numberFormatter {
    if (!_numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    }
    return _numberFormatter;
}

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
             @"NSMutableData": @"blob",
             @"NSAttributedString": @"blob",
             @"NSMutableAttributedString": @"blob",
             @"NSIndexPath": @"blob",
             @"NSDate": @"text",
             @"NSDictionary": @"text",
             @"NSMutableDictionary": @"text",
             @"NSArray": @"text",
             @"NSMutableArray": @"text",
             @"NSString": @"text",
             @"NSMutableString": @"text",
             @"NSNumber": @"text",
             @"NSSet": @"text",
             @"NSMutableSet": @"text",
             @"{CGPoint=\"x\"d\"y\"d}": @"text",
             @"{CGRect=\"origin\"{CGPoint=\"x\"d\"y\"d}\"size\"{CGSize=\"width\"d\"height\"d}}": @"text",
             @"{CGSize=\"width\"d\"height\"d}" : @"text"
             };
}
@end
