//
//  XWDatabaseDataModel.h
//  XWDatabase_Example
//
//  Created by 邱学伟 on 2018/12/12.
//  Copyright © 2018 qxuewei@yeah.net. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XWDatabaseDataModel : NSObject

/**
 存储二进制到二进制数据库中

 @param data 二进制文件
 @param completion 回调
 */
+ (void)saveData:(NSData *)data completion:(void(^)(BOOL, NSUInteger))completion;

/**
 获取二进制文件

 @param hashString hash 值
 @param completion 回调
 */
+ (void)dataWithHash:(NSString *)hashString completion:(void(^)(NSData *))completion;

@end

NS_ASSUME_NONNULL_END
