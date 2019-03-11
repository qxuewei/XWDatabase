//
//  XWBook.m
//  XWDatabase_Example
//
//  Created by 邱学伟 on 2018/12/11.
//  Copyright © 2018 qxuewei@yeah.net. All rights reserved.
//

#import "XWBook.h"
#import "NSObject+XWModel.h"
#import "XWDatabase.h"


@implementation XWBook

#pragma mark - Life Cycle
+ (void)load {
    /// 数据迁移
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [XWDatabase updateTable:self completion:^(BOOL isSuccess) {
            NSLog(@" <XWDatabase> updateTable (%@)",isSuccess?@"成功":@"失败");
        }];
    });
}

XWCodingImplementation

+ (NSString *)xw_primaryKey {
    return @"bookId";
}

+ (NSSet<NSString *> *)xw_ignoreColumnNames {
    return [NSSet setWithObject:@"author"];
}


+ (NSSet<NSString *> *)xw_specificSaveColumnNames {
    return [NSSet setWithObjects:@"name",@"bookId",@"author", nil];
}


@end
