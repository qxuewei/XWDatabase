//
//  XWDatabaseDataModel.m
//  XWDatabase_Example
//
//  Created by 邱学伟 on 2018/12/12.
//  Copyright © 2018 qxuewei@yeah.net. All rights reserved.
//

#import "XWDatabaseDataModel.h"
#import "XWDatabaseQueue.h"


@implementation XWDatabaseDataModel
+ (void)initialize {
    
    NSString *creatTableSql = @"CREAT";
    [[XWDatabaseQueue shareInstance] inDatabase:^(FMDatabase * _Nonnull database) {
        
    }];
}
@end
