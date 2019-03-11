//
//  XWTestSubModel.m
//  XWDatabase_Example
//
//  Created by 邱学伟 on 2019/3/11.
//  Copyright © 2019 qxuewei@yeah.net. All rights reserved.
//

#import "XWTestSubModel.h"
#import "NSObject+XWModel.h"

@implementation XWTestSubModel

XWCodingImplementation

+ (instancetype)testTestSubModel {
    XWTestSubModel *model = [XWTestSubModel new];
    model.uuid = 123;
    model.name = @"name";
    model.icon = [UIImage imageNamed:@"icon"];
    return model;
}

@end
