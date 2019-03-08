//
//  NSObject+XWModel.m
//  XWDatabase_Example
//
//  Created by 邱学伟 on 2018/12/11.
//  Copyright © 2018 qxuewei@yeah.net. All rights reserved.
//

#import "NSObject+XWModel.h"
#import <objc/runtime.h>
#import "XWDatabaseModel.h"

#pragma mark 常量
NSString * const kXWDB_IDENTIFIER_COLUMNNAME    =   @"xw_identifier";   //唯一标识字段名称
NSString * const kXWDB_PRIMARYKEY_COLUMNNAME    =   @"xw_id";           //默认自增主键字段名称

@interface NSObject ()
@property (nonatomic, copy) NSString *abc;
@end

@implementation NSObject (XWModel)

#pragma mark - Public
/**
 是否具备数据可 更新/查询 条件
 
 @return 是否具备数据可 更新/查询 条件
 */
- (BOOL)xwdb_isUpdateQueryingCondition {
    if (!self.xwdb_primaryKey && !self.xwdb_unionPrimaryKey) {
        NSLog(@"所处理的模型无主键! 也无唯一标识字段");
        return NO;
    }
    return YES;
}

#pragma mark - 分类新增属性
/// 默认自增主键
- (void)setXw_id:(NSNumber *)xw_id {
    objc_setAssociatedObject(self, @selector(xw_id), xw_id, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSNumber *)xw_id {
    return objc_getAssociatedObject(self, _cmd);
}

/// 上次存储的ID
- (void)setXw_lastPrimaryKeyId:(NSNumber *)xw_lastPrimaryKeyId {
    objc_setAssociatedObject(self, @selector(xw_lastPrimaryKeyId), xw_lastPrimaryKeyId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSNumber *)xw_lastPrimaryKeyId {
    return objc_getAssociatedObject(self, _cmd);
}

/// 模型中所有成员变量 (key: 成员变量名称  value: 成员变量类型)
- (void)setXw_classIvarNameTypeDict:(NSDictionary *)xw_classIvarNameTypeDict {
    objc_setAssociatedObject(self, @selector(xw_classIvarNameTypeDict), xw_classIvarNameTypeDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSDictionary *)xw_classIvarNameTypeDict {
    return objc_getAssociatedObject(self, _cmd);
}

/// 模型中真实成员变量类型
- (void)setXw_IvarSet:(NSSet *)xw_IvarSet {
    objc_setAssociatedObject(self, @selector(xw_IvarSet), xw_IvarSet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSSet *)xw_IvarSet {
    return objc_getAssociatedObject(self, _cmd);
}

/// 自定义对象
- (void)setXw_CustomModelSet:(NSSet *)xw_CustomModelSet {
    objc_setAssociatedObject(self, @selector(xw_CustomModelSet), xw_CustomModelSet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSSet *)xw_CustomModelSet {
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - 智能归解档
- (void)xw_decode:(NSCoder*)aDecoder {
    Class cls = [self class];
    while (cls && cls != [NSObject class]) {
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList(cls, &count);
        for (int i = 0; i < count; i++) {
            Ivar ivar = ivars[i];
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            id value = [aDecoder decodeObjectForKey:key];
            if (value) {
                [self setValue:value forKey:key];
            }
        }
        free(ivars);
        cls = [cls superclass];
    }
}

- (void)xw_encode:(NSCoder*)aCoder {
    Class cls = [self class];
    while (cls && cls != [NSObject class]) {
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList(cls, &count);
        for (int i = 0; i < count; i++) {
            Ivar ivar = ivars[i];
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            id value = [self valueForKey:key];
            if (value) {
                [aCoder encodeObject:value forKey:key];
            }
        }
        free(ivars);
        cls = [cls superclass];
    }
}

#pragma mark - 以下方法根据 XWDatabaseModelProtocol 协议中实现获取相应值

/**
 主键 不可更改/唯一性
 
 @return 主键的属性名
 */
- (NSString * _Nullable)xwdb_primaryKey {
    if ([self.class respondsToSelector:@selector(xw_primaryKey)]) {
        NSString *primaryKey = [self.class xw_primaryKey];
        if (primaryKey && primaryKey.length > 0) {
            NSDictionary *columns = [XWDatabaseModel classColumnIvarNameTypeDict:self.class];
            if (![columns.allKeys containsObject:primaryKey]) {
                /// 表字段中无该主键
                return nil;
            }
            return primaryKey;
        }
    }
    return nil;
}

/**
 联合主键成员变量数组 (多个属性共同定义主键) - 优先级大于 'xwdb_primaryKey'
 
 @return 联合主键成员变量数组
 */
- (NSArray < NSString * > * _Nullable)xwdb_unionPrimaryKey {
    if ([self.class respondsToSelector:@selector(xw_unionPrimaryKey)]) {
        NSArray *unionPrimaryKey = [self.class xw_unionPrimaryKey];
        if (unionPrimaryKey && unionPrimaryKey.count > 0) {
            __block BOOL isError = NO;
            [unionPrimaryKey enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *columns = [XWDatabaseModel classColumnIvarNameTypeDict:self.class];
                /// 表字段中无该主键
                isError = ![columns.allKeys containsObject:obj];
                if (isError) {
                    *stop = YES;
                }
            }];
            if (isError) {
                return nil;
            }
            return unionPrimaryKey;
        }
    }
    return nil;
}

/**
 自定义对象映射  (key: 成员变量名称 value: 对象类)
 
 @return 自定义对象映射
 */
- (NSDictionary * _Nullable)xwdb_customModelMapping {
    if ([self.class respondsToSelector:@selector(xw_customModelMapping)]) {
        NSMutableDictionary *customModelMapping = [self.class xw_customModelMapping].mutableCopy;
        [customModelMapping enumerateKeysAndObjectsUsingBlock:^(NSString * key, id  _Nonnull obj, BOOL * _Nonnull stop) {
           NSDictionary *columns = [XWDatabaseModel classColumnIvarNameTypeDict:self.class];
            if (![columns.allKeys containsObject:key]) {
                [customModelMapping removeObjectForKey:key];
            }
        }];
        if (customModelMapping && customModelMapping.count > 0) {
            return customModelMapping.copy;
        }
    }
    return nil;
}

/**
 忽略不保存数据库的属性
 
 @return 忽略的属性名数组
 */
- (NSSet <NSString *>* _Nullable)xwdb_ignoreColumnNames {
    if ([self.class respondsToSelector:@selector(xw_ignoreColumnNames)]) {
        NSSet *ignoreColumnNames = [self.class xw_ignoreColumnNames];
        if (ignoreColumnNames && ignoreColumnNames.count) {
            return ignoreColumnNames;
        }
    }
    return nil;
}

/**
 自定义字段名映射表 (默认成员变量即变量名, 可自定义字段名 key: 成员变量(属性)名称  value: 自定义数据库表字段名)
 
 @return 自定义字段名映射表
 */
- (NSDictionary * _Nullable)xwdb_customColumnMapping {
    if ([self.class respondsToSelector:@selector(xw_customColumnMapping)]) {
        NSMutableDictionary *customColumnMapping = [self.class xw_customColumnMapping].mutableCopy;
        if (customColumnMapping && customColumnMapping.count > 0) {
            [customColumnMapping enumerateKeysAndObjectsUsingBlock:^(NSString * key, NSString * obj, BOOL * _Nonnull stop) {
                obj = [key stringByReplacingOccurrencesOfString:@" " withString:@""];
            }];
            return customColumnMapping.copy;
        }
    }
    return nil;
}

/**
 自定义表名 (默认属性类名)
 
 @return 自定义表名
 */
- (NSString * _Nullable)xwdb_customTableName {
    if ([self.class respondsToSelector:@selector(xw_customTableName)]) {
        NSString *customTableName = [self.class xw_customTableName];
        if (customTableName && customTableName.length > 0) {
            return customTableName;
        }
    }
    return nil;
}

/**
 自定义存储的属性数组, 实现此协议在存储时将自动忽略其他属性( 'xw_ignoreColumnNames' 将无效),
 
 @return 自定义存储的属性数组
 */
- (NSSet < NSString * > * _Nullable)xwdb_specificSaveColumnNames {
    if ([self.class respondsToSelector:@selector(xw_specificSaveColumnNames)]) {
        NSMutableSet *specificSaveColumnNames = [self.class xw_specificSaveColumnNames].mutableCopy;
        [specificSaveColumnNames enumerateObjectsUsingBlock:^(NSString * obj, BOOL * _Nonnull stop) {
            NSDictionary *columns = [XWDatabaseModel classColumnIvarNameTypeDict:self.class];
            if (![columns.allKeys containsObject:obj]) {
                /// 不存在自定义存储的属性
                [specificSaveColumnNames removeObject:obj];
            }
        }];
        if (specificSaveColumnNames && specificSaveColumnNames.count) {
            return specificSaveColumnNames.copy;
        }
    }
    return nil;
}

@end
