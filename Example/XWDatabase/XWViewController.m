//
//  XWViewController.m
//  XWDatabase
//
//  Created by qxuewei@yeah.net on 12/06/2018.
//  Copyright (c) 2018 qxuewei@yeah.net. All rights reserved.
//

#import "XWViewController.h"
#import "XWPerson.h"
#import "XWDatabase.h"

@interface XWViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@end

@implementation XWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /// 增
//    [self saveOnePerson];
//    [self saveModels];

    /// 删
//    [self deleteModel];
//    [self clearModel];

    /// 改
//    [self updateModel];

    /// 查
    [self getOnePerson];
//    [self getModels];
//    [self getModelsSortAge];
//    [self getModelsCondition];
//    [self getModelsConditionSort];
    
}

#pragma mark - 增
/// 保存模型
- (void)saveOnePerson
{
    XWPerson *person = [XWPerson testPerson:2];
    [XWDatabase saveModel:person completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> saveOnePerson (%@)",isSuccess?@"成功":@"失败");
    }];
}

/// 保存模型数组
- (void)saveModels
{
    NSMutableArray *persons = [[NSMutableArray alloc] init];
    for (int i = 0; i < 1000; i++) {
        [persons addObject:[XWPerson testPerson:i]];
    }
    [XWDatabase saveModels:persons completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> saveModels (%@)",isSuccess?@"成功":@"失败");
    }];
}

#pragma mark - 删
/// 根据主键删除模型
- (void)deleteModel
{
    XWPerson *person = [XWPerson new];
    person.cardID = @"9998";
    [XWDatabase deleteModel:person completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> deleteModel (%@)",isSuccess?@"成功":@"失败");
    }];
}

/// 清空某模型所有数据 (整体删除/条件删除)
- (void)clearModel
{
//    [XWDatabase clearModel:XWPerson.class completion:^(BOOL isSuccess) {
//        NSLog(@" <XWDatabase> deleteModel (%@)",isSuccess?@"成功":@"失败");
//    }];
    
    [XWDatabase clearModel:XWPerson.class condition:@"age > '50'" completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> deleteModel (%@)",isSuccess?@"成功":@"失败");
    }];
}

#pragma mark - 改
/// 更新某字段! (基本数据类型会根据新传入的值更新)
- (void)updateModel
{
    XWPerson *person = [XWPerson new];
    person.cardID = @"2";
    person.age = 20;
    person.name = @"新名字";
    person.pDouble = 9.99;
    
    /// 自定义成员变量更新
    [XWDatabase updateModel:person updatePropertys:@[@"name"] completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> updateModel (%@)",isSuccess?@"成功":@"失败`");
    }];
    
//    /// 整个模型更新
//    [XWDatabase saveModel:person completion:^(BOOL isSuccess) {
//        NSLog(@" <XWDatabase> updateModel (%@)",isSuccess?@"成功":@"失败");
//    }];
}

#pragma mark - 查
/// 根据主键取数据库中数据
- (void)getOnePerson
{
    XWPerson *person = [XWPerson new];
    person.cardID = @"81";
    [XWDatabase getModel:person completion:^(XWPerson * obj) {
        NSLog(@" <XWDatabase> getOnePerson (%@) name: %@",obj,obj.name);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.iconView.image = obj.image;
        });
    }];
}

/// 获取数据库中所有该模型存储的数据
- (void)getModels
{
    [XWDatabase getModels:XWPerson.class completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels (objs.count: %lu)",objs.count);
        
    }];
}

/// 获取数据库中所有该模型存储的数据 - 按 age 字段降序排列
- (void)getModelsSortAge
{
    [XWDatabase getModels:XWPerson.class sortColumn:@"age" isOrderDesc:YES completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels (objs.count: %lu)",objs.count);
        for (XWPerson *person in objs) {
            NSLog(@"cardID : %@ -- age: %zd",person.cardID,person.age);
        }
    }];
}

/// 获取数据库中所有该模型存储的数据 - 自定义查找条件 (例如模糊查询 name 含 学伟 的数据)
- (void)getModelsCondition
{
    [XWDatabase getModels:XWPerson.class condition:@"name like '%学伟'" completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels (objs.count: %lu)",objs.count);
        for (XWPerson *person in objs) {
            NSLog(@"cardID : %@ name : %@ -- age: %zd",person.cardID,person.name,person.age);
        }
    }];
}

/// 获取数据库中所有该模型存储的数据 - 自定义查找条件可排序 (例如模糊查询 name 含 学伟 的数据, 并且按 age 升序排序)
- (void)getModelsConditionSort
{
    [XWDatabase getModels:XWPerson.class sortColumn:@"age" isOrderDesc:NO condition:@"name like '%学伟'" completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels (objs.count: %lu)",objs.count);
        for (XWPerson *person in objs) {
            NSLog(@"cardID : %@ name : %@ -- age: %zd",person.cardID,person.name,person.age);
        }
    }];
}

@end
