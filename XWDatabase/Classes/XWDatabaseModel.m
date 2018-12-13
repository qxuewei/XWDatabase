//
//  XWDatabaseModel.m
//  XWDatabase
//
//  Created by 邱学伟 on 2018/11/29.
//  Copyright © 2018 邱学伟. All rights reserved.
//

#import "XWDatabaseModel.h"
#import <objc/runtime.h>
#import "NSObject+XWModel.h"
#import "XWDatabaseDataModel.h"

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

 @param cls 类
 @return 模型中所有成员变量 (key: 成员变量名称  value: 成员变量类型)
 */
+ (NSDictionary *)classColumnIvarNameTypeDict:(Class)cls {
    if (!cls.xw_classIvarNameTypeDict) {
        NSMutableDictionary *dictM = [[NSMutableDictionary alloc] init];
        unsigned int count = 0;
        Ivar *ivarList = class_copyIvarList(cls, &count);
        for (int i = 0; i < count; i++) {
            Ivar ivar = ivarList[i];
            /// 成员变量名称
            NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
            if ([ivarName hasPrefix:@"_"]) {
                ivarName = [ivarName substringFromIndex:1];
            }
            if (cls.xwdb_ignoreColumnNames && [cls.xwdb_ignoreColumnNames containsObject:ivarName]) {
                continue;
            }
            /// 成员变量类型
            NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
            ivarType = [ivarType stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
            if (cls.xwdb_customColumnMapping && [cls.xwdb_customColumnMapping.allKeys containsObject:ivarName]) {
                ivarName = cls.xwdb_customColumnMapping[ivarName];
            }
            [dictM setObject:ivarType forKey:ivarName];
        }
        free(ivarList);
        cls.xw_classIvarNameTypeDict = dictM.copy;
    }
    return cls.xw_classIvarNameTypeDict;
}

/**
 模型中所有成员变量在Sqlite 数据库中对应的类型
 
 @param cls 模型类
 @return 模型中所有成员变量在Sqlite 数据库中对应的类型
 */
+ (NSDictionary *)classIvarNameSqliteTypeDict:(Class<XWDatabaseModelProtocol>)cls {
    NSMutableDictionary *ivarOriginDict = [XWDatabaseModel classColumnIvarNameTypeDict:cls].mutableCopy;
    NSDictionary *dictionaryOcTypeToSqliteType = [self dictionaryOcTypeToSqliteType];
    [ivarOriginDict enumerateKeysAndObjectsUsingBlock:^(NSString * name, NSString * originType, BOOL * _Nonnull stop) {
//        BOOL isKeyExist = [dictionaryOcTypeToSqliteType.allKeys containsObject:originType];
//        if (!isKeyExist) {
//            NSLog(@"%@  isKeyExist: (%d)",originType,isKeyExist);
//        }
        if ([self customModelSet:cls] && [[self customModelSet:cls] containsObject:name]) {
            /// 自定义对象存储为 text 字段
            ivarOriginDict[name] = @"text";
        } else {
            ivarOriginDict[name] = dictionaryOcTypeToSqliteType[originType];
        }
        
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
    NSMutableArray *names = [XWDatabaseModel classColumnIvarNameTypeDict:cls].allKeys.mutableCopy;
    [names sortUsingComparator:^NSComparisonResult(NSString * obj1, NSString * obj2) {
        return [obj1 compare:obj2];
    }];
    return names.copy;
}

/**
 模型中成员变量集合
 
 @return 模型中成员变量集合
 */
+ (NSSet *)classIvarNamesSet:(Class)cls {
    if (!cls.xw_IvarSet) {
        NSMutableSet *sets = [[NSMutableSet alloc] init];
        unsigned int count = 0;
        Ivar *ivarList = class_copyIvarList(cls.class, &count);
        for (int i = 0; i < count; i++) {
            Ivar ivar = ivarList[i];
            NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
            if ([ivarName hasPrefix:@"_"]) {
                ivarName = [ivarName substringFromIndex:1];
            }
            [sets addObject:ivarName];
        }
        cls.xw_IvarSet = sets.copy;
    }
    return cls.xw_IvarSet;
}

/**
 根据字段名获取模型真实成员变量名

 @param column 字段名
 @param cls 类
 @return 模型真实成员变量名
 */
+ (NSString *)ivarNameWithColumn:(NSString *)column cls:(Class)cls {
    NSString *ivarName = column;
    if (cls.xwdb_customColumnMapping && [cls.xwdb_customColumnMapping.allValues containsObject:column]) {
        ivarName = [cls.xwdb_customColumnMapping allKeysForObject:column].firstObject;
    }
    if ([[self classIvarNamesSet:cls] containsObject:ivarName]) {
        return ivarName;
    }
    return nil;
}

/**
 模型中自定义对象

 @param cls 模型类
 @return 模型中自定义对象
 */
+ (NSSet *)customModelSet:(Class)cls {
    if (!cls.xwdb_customModelMapping) {
        return nil;
    }
    if (!cls.xw_CustomModelSet) {
        cls.xw_CustomModelSet = [NSSet setWithArray:cls.xwdb_customModelMapping.allKeys];
    }
    return cls.xw_CustomModelSet;
}

/// NSAarray -> NSString
+ (NSString *)stringWithArray:(NSArray *)array {
    if (!array) {
        return nil;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
/// NSString -> NSArray
+ (NSArray *)arrayWithString:(NSString *)string {
    if (!string || string.length == 0) {
        return nil;
    }
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

/// NSDictionary -> NSString
+ (NSString *)stringWithDict:(NSDictionary *)dict {
    if (!dict) {
        return nil;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
/// NSDictionary -> NSArray
+ (NSDictionary *)dictWithString:(NSString *)string {
    if (!string || string.length == 0) {
        return nil;
    }
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

/// NSData -> NSString
+ (NSString *)stringWithData:(NSData *)data {
    if (!data || data.length == 0) {
        return nil;
    }
    __block NSString *hashStr;
    [XWDatabaseDataModel saveData:data completion:^(BOOL isSuccess, NSUInteger hashID) {
        hashStr = [NSString stringWithFormat:@"%lu",(unsigned long)hashID];
    }];
    return hashStr;
}
/// NSString -> NSData
+ (NSData *)dataWithString:(NSString *)string {
    if (!string || string.length == 0) {
        return nil;
    }
    __block NSData *dataByHash;
    [XWDatabaseDataModel dataWithHash:string completion:^(NSData * data) {
        dataByHash = data;
    }];
    return dataByHash;
}

/// NSDate -> NSString
+ (NSString *)stringWithDate:(NSDate *)date {
    if (!date) {
        return nil;
    }
    return [[self dateFormatter] stringFromDate:date];
}
/// NSString -> NSDate
+ (NSDate *)dateWithString:(NSString *)string {
    if (!string || string.length == 0) {
        return nil;
    }
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
    if (!set) {
        return nil;
    }
    NSArray *array = [set allObjects];
    return [self stringWithArray:array];
}
/// NSString -> NSSet
+ (NSSet *)setWithString:(NSString *)string {
    if (!string || string.length == 0) {
        return nil;
    }
    NSArray *array = [self arrayWithString:string];
    return [NSSet setWithArray:array];
}

/// NSAttributedString -> NSString
+ (NSString *)stringWithAttributedString:(NSAttributedString *)attributedString {
    if (!attributedString) {
        return nil;
    }
    NSData *data = [attributedString dataFromRange:NSMakeRange(0, attributedString.length) documentAttributes:@{NSDocumentTypeDocumentAttribute : NSRTFDTextDocumentType} error:nil];
    NSString *stringBase64 = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return stringBase64;
}
/// NSString -> NSAttributedString
+ (NSAttributedString *)attributedStringWithString:(NSString *)string {
    if (!string || string.length == 0) {
        return nil;
    }
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [[NSAttributedString alloc] initWithData:data options:@{NSDocumentTypeDocumentAttribute : NSRTFDTextDocumentType} documentAttributes:nil error:nil];
}

/// NSIndexPath -> NSString
+ (NSString *)stringWithIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) {
        return nil;
    }
    NSData *data;
    if (@available(iOS 11.0, *)) {
        data = [NSKeyedArchiver archivedDataWithRootObject:indexPath requiringSecureCoding:YES error:nil];
    } else {
        data = [NSKeyedArchiver archivedDataWithRootObject:indexPath];
    }
    return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}
/// NSString -> NSIndexPath
+ (NSIndexPath *)indexPathWithString:(NSString *)string {
    if (!string || string.length == 0) {
        return nil;
    }
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSIndexPath *indexPath;
    if (@available(iOS 11.0, *)) {
        indexPath = [NSKeyedUnarchiver unarchivedObjectOfClass:NSIndexPath.class fromData:data error:nil];
    } else {
        indexPath = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return indexPath;
}

/// UIImage -> NSString
+ (NSString *)stringWithImage:(UIImage *)image {
    if (!image) {
        return nil;
    }
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    if (!data) {
        data = UIImagePNGRepresentation(image);
    }
    return [self stringWithData:data];
}
/// NSString -> UIImage
+ (UIImage *)imageWithString:(NSString *)string {
    if (!string || string.length == 0) {
        return nil;
    }
    return [UIImage imageWithData:[self dataWithString:string]];
}

/// NSURL -> NSString
+ (NSString *)stringWithURL:(NSURL *)URL {
    if (!URL) {
        return nil;
    }
    return [URL absoluteString];
}
/// NSString -> NSURL
+ (NSURL *)URLWithString:(NSString *)string {
    if (!string || string.length == 0) {
        return nil;
    }
    return [NSURL URLWithString:string];
}

/// CustomModel -> NSString
+ (NSString *)stringWithCustomModel:(id)customModel {
    if (!customModel) {
        return nil;
    }
    NSData *data;
    if (@available(iOS 11.0, *)) {
        data = [NSKeyedArchiver archivedDataWithRootObject:customModel requiringSecureCoding:YES error:nil];
    } else {
        data = [NSKeyedArchiver archivedDataWithRootObject:customModel];
    }
    NSString *dataString = [self stringWithData:data];
    NSString *cls = NSStringFromClass([customModel class]);
    NSString *saveString = [NSString stringWithFormat:@"%@<xwdatabase>%@",cls,dataString];
    return saveString; //XWBook<xwdatabase>29026982
}
/// NSString -> CustomModel
+ (id)customModelWithString:(NSString *)string {
    if (!string || string.length == 0) {
        return nil;
    }
    NSRange range = [string rangeOfString:@"<xwdatabase>"];
    NSString *cls = [string substringToIndex:range.location];
    NSString *dataString = [string substringFromIndex:range.location + range.length];
    NSData *data = [self dataWithString:dataString];
    id customModel;
    if (@available(iOS 11.0, *)) {
        customModel = [NSKeyedUnarchiver unarchivedObjectOfClass:NSClassFromString(cls) fromData:data error:nil];
    } else {
        customModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return customModel;
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
             
             @"NSData": @"text",
             @"NSMutableData": @"text",
             @"NSAttributedString": @"text",
             @"NSMutableAttributedString": @"text",
             @"NSIndexPath": @"text",
             @"UIImage": @"text",
             
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
             @"NSURL": @"text",
             
             @"{_NSRange=\"location\"Q\"length\"Q}": @"text",
             @"{_NSRange=\"location\"I\"length\"I}"  : @"text",
             
             @"{CGPoint=\"x\"d\"y\"d}": @"text",
             @"{CGPoint=\"x\"f\"y\"f}" : @"text",
             
             @"{CGRect=\"origin\"{CGPoint=\"x\"d\"y\"d}\"size\"{CGSize=\"width\"d\"height\"d}}": @"text",
             @"{CGRect=\"origin\"{CGPoint=\"x\"f\"y\"f}\"size\"{CGSize=\"width\"f\"height\"f}}" : @"text",
             
             @"{CGSize=\"width\"d\"height\"d}" : @"text",
             @"{CGSize=\"width\"f\"height\"f}" : @"text"
             };
}
@end
