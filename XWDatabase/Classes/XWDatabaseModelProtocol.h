//
//  XWDatabaseModelProtocol.h
//  XWDatabase
//
//  Created by 邱学伟 on 2018/11/29.
//  Copyright © 2018 邱学伟. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 模型操作数据库所遵循的协议
@protocol XWDatabaseModelProtocol <NSObject>

@required

/**
 主键 不可更改/唯一性
 
 @return 主键的属性名
 */
+ (NSString *)xw_primaryKey;
@optional

/**
 忽略不保存数据库的属性
 
 @return 忽略的属性名数组
 */
+ (NSSet <NSString *>*)xw_ignoreColumnNames;
@end
