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
#import "XWImage.h"
#import "XWBook.h"

#define kUser1ID @"10010"
#define kUser2ID @"10086"

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
//    [self saveOneBook];
//    [self saveBooks];
//    [self addImages];
//    [self addIdentifyBooks];

    /// 删
//    [self deleteModel];
//    [self deleteBook];
//    [self clearModel];
//    [self deleteBooks];

    /// 改
//    [self updateModel];
//    [self updateBook];
//    [self updatePersons];
//    [self updateBooks];
//    [self updateImages];
    
    /// 查
//    [self getOnePerson];
//    [self getOneBook];
//    [self getModels];
    [self getBookModels];
//    [self getModelsSortAge];
//    [self getModelsCondition];
//    [self getModelsConditionSort];
//    [self getImage];
//    [self getIdentifyBook];
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

/// 保存模型 (用户区分)
- (void)saveOneBook
{
    XWBook *book = [XWBook new];
    book.name = @"iOS 从入门到放弃";
    book.author = @"学伟";
    book.bookId = 2;
    [XWDatabase saveModel:book identifier:kUser1ID completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> saveOneBook identifier (%@)",isSuccess?@"成功":@"失败");
    }];
}

/// 保存模型数组
- (void)saveModels
{
    NSMutableArray *persons = [[NSMutableArray alloc] init];
    for (int i = 0; i < 100; i++) {
        [persons addObject:[XWPerson testPerson:i]];
    }
    [XWDatabase saveModels:persons completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> saveModels (%@)",isSuccess?@"成功":@"失败");
    }];
}

/// 保存模型数组 (用户区分)
- (void)saveBooks
{
    NSMutableArray *books = [[NSMutableArray alloc] init];
    for (int i = 0; i < 100; i++) {
        XWBook *book = [XWBook new];
        book.bookId = i;
        book.name = [NSString stringWithFormat:@"bookName_%d",i];
        book.author = @"极客学伟";
        book.bookConcern = @"bookConcern";
        [books addObject:book];
    }
    [XWDatabase saveModels:books identifier:kUser2ID completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> saveModels identifier (%@)",isSuccess?@"成功":@"失败");
    }];
}

/// 保存无主键模型
- (void)addImages {
    NSMutableArray *images = [NSMutableArray array];
    for (int i = 0; i < 100; i++) {
        XWImage *image = [XWImage new];
        image.name = [NSString stringWithFormat:@"name - %d",i];
        image.filePath = [NSString stringWithFormat:@"filePath - %d",i];
        [images addObject:image];
    }
    [XWDatabase saveModels:images completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> addImages (%@)",isSuccess?@"成功":@"失败");
    }];
    
    [XWDatabase saveModels:images identifier:kUser1ID completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> addImages identifier (%@)",isSuccess?@"成功":@"失败");
    }];
}

/// 新增 "userID" 区分数据
- (void)addIdentifyBooks {
    NSMutableArray *books = [NSMutableArray array];
    for (int i = 0; i < 20; i++) {
        XWBook *book = [XWBook new];
        book.bookId = i;
        book.name = [NSString stringWithFormat:@"bookName_%d",i];
        book.author = @"极客学伟";
        book.bookConcern = @"bookConcern";
        [books addObject:book];
    }
    [XWDatabase saveModels:books identifier:@"101" completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> saveModels identifier (%@)",isSuccess?@"成功":@"失败");
    }];
}

#pragma mark - 删
/// 根据主键删除模型
- (void)deleteModel
{
    XWPerson *person = [XWPerson new];
    person.cardID = @"2";
    [XWDatabase deleteModel:person completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> deleteModel (%@)",isSuccess?@"成功":@"失败");
    }];
}

/// 根据主键删除 指定用户ID 的模型
- (void)deleteBook {
    XWBook *book = [XWBook new];
    book.bookId = 2;
    [XWDatabase deleteModel:book identifier:kUser1ID completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> deleteModel identifier (%@)",isSuccess?@"成功":@"失败");
    }];
}

/// 清空某模型所有数据 (整体删除/条件删除)
- (void)clearModel
{
    [XWDatabase clearModel:XWImage.class completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> deleteModel (%@)",isSuccess?@"成功":@"失败");
    }];
    
    [XWDatabase clearModel:XWPerson.class condition:@"age > '50'" completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> deleteModel (%@)",isSuccess?@"成功":@"失败");
    }];
}

/// 清楚指定标识符数据
- (void)deleteBooks {
    [XWDatabase clearModel:XWBook.class identifier:@"101" completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> deleteModel saveOneBook (%@)",isSuccess?@"成功":@"失败");
    }];

    [XWDatabase clearModel:XWBook.class identifier:kUser2ID condition:@"bookId < 10" completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> deleteModel saveOneBook (%@)",isSuccess?@"成功":@"失败");
    }];
}

#pragma mark - 改
/// 更新某字段! (基本数据类型会根据新传入的值更新)
- (void)updateModel
{
    XWPerson *person = [XWPerson new];
    person.cardID = @"2";
    person.age = 200000;
    person.name = @"新名字";
    person.pDouble = 9.99;
    
    /// 自定义成员变量更新
    [XWDatabase updateModel:person updatePropertys:@[@"name",@"age"] completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> updateModel (%@)",isSuccess?@"成功":@"失败");
    }];
    
    XWPerson *person2 = [XWPerson new];
    person2.cardID = @"3";
    [XWDatabase updateModel:person2 updatePropertys:nil completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> updateModel 全量更新 (%@)",isSuccess?@"成功":@"失败");
    }];
    
//    /// 整个模型更新
//    [XWDatabase saveModel:person completion:^(BOOL isSuccess) {
//        NSLog(@" <XWDatabase> updateModel (%@)",isSuccess?@"成功":@"失败");
//    }];
}

/// 更新 指定用户 模型数据
- (void)updateBook {
    XWBook *book = [XWBook new];
    book.bookId = 4;
    book.name = @"新书";
    [XWDatabase updateModel:book identifier:kUser2ID updatePropertys:@[@"name"] completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> updateModel book (%@)",isSuccess?@"成功":@"失败");
    }];
    
    XWBook *book2 = [XWBook new];
    book2.bookId = 3;
    book2.author = @"新作者";
    [XWDatabase updateModel:book2 identifier:kUser2ID updatePropertys:nil completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> updateModel book (%@)",isSuccess?@"成功":@"失败");
    }];
}

/// 批量更新无标示符模型
- (void)updatePersons {
    NSMutableArray *persons = [NSMutableArray array];
    for (int i = 0; i < 50; i++) {
        XWPerson *person = [XWPerson new];
        person.cardID = [NSString stringWithFormat:@"%d",i];
        person.age = 100;
        person.name = @"阿里巴巴";
        person.sex = @"Male";
        person.girls = @[@"小可可",@"小慧慧",@"小baby"].mutableCopy;
        [persons addObject:person];
    }
    [XWDatabase updateModels:persons updatePropertys:nil completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> updateModels persons (%@)",isSuccess?@"成功":@"失败");
    }];
}

/// 批量更新有标示符模型
- (void)updateBooks {
    NSMutableArray *books = [NSMutableArray array];
    for (int i = 0; i < 30; i++) {
        XWBook *book = [XWBook new];
        book.bookId = i;
        book.name = [NSString stringWithFormat:@"批量名称(%d)",i];
        book.author = [NSString stringWithFormat:@"作者(%d)",i];
        [books addObject:book];
    }
    [XWDatabase updateModels:books identifier:kUser2ID updatePropertys:nil completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> updateModels books (%@)",isSuccess?@"成功":@"失败");
    }];
}

/// 批量更新无主键模型
- (void)updateImages {
    XWImage *image = [XWImage new];
    image.name = @"XXOO";
    [XWDatabase updateModels:image updatePropertys:nil condition:nil completion:^(BOOL isSuccess) {
       NSLog(@" <XWDatabase> uodateImages (%@)",isSuccess?@"成功":@"失败");
    }];
    
    XWImage *image2 = [XWImage new];
    image2.name = @"批量更新";
    image2.filePath = @"批量";
    [XWDatabase updateModels:image2 identifier:kUser1ID updatePropertys:nil condition:nil completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> uodateImages (%@)",isSuccess?@"成功":@"失败");
    }];
}

#pragma mark - 查
/// 根据主键取数据库中数据
- (void)getOnePerson
{
    XWPerson *person = [XWPerson new];
    person.cardID = @"2";
    [XWDatabase getModel:person completion:^(XWPerson * obj) {
        NSLog(@" <XWDatabase> getOnePerson (%@) name: %@",obj,obj.name);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.iconView.image = obj.image;
        });
    }];
}

/// 根据主键取数据库中数据 - 分用户
- (void)getOneBook {
    XWBook *book = [XWBook new];
    book.bookId = 1;
    [XWDatabase getModel:book identifier:kUser2ID completion:^(XWBook * obj) {
        NSLog(@" <XWDatabase> getOneBook (%@) name: %@",obj,obj.name);
    }];
}

/// 获取数据库中所有该模型存储的数据
- (void)getModels
{
    [XWDatabase getModels:XWPerson.class completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels (objs.count: %lu)",objs.count);
    }];
}

/// 获取数据库中所有该模型存储的数据 - 指定用户 101
- (void)getBookModels
{
    [XWDatabase getModels:XWBook.class identifier:@"101" completion:^(NSArray * _Nullable objs) {
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
//    [XWDatabase getModels:XWPerson.class condition:@"name like '%学伟'" completion:^(NSArray * _Nullable objs) {
//        NSLog(@" <XWDatabase> getModels (objs.count: %lu)",objs.count);
//        for (XWPerson *person in objs) {
//            NSLog(@"cardID : %@ name : %@ -- age: %zd",person.cardID,person.name,person.age);
//        }
//    }];
    
    /// SQLite 模糊查询默认大小写不敏感
    [XWDatabase getModels:XWPerson.class condition:@"gender like '%m%' AND name like '%xue%'" completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels (objs.count: %lu)",objs.count);
        for (XWPerson *person in objs) {
            NSLog(@"cardID : %@ name : %@ -- age: %zd -- sex: %@",person.cardID,person.name,person.age,person.sex);
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

/// 获取无主键模型
- (void)getImage {
    NSString *condition = @"name = 'name - 66'";
    [XWDatabase getModels:XWImage.class condition:condition completion:^(NSArray * _Nullable objs) {
         NSLog(@" <XWDatabase> getModels (objs.count: %lu)",objs.count);
    }];
}

/// 获取唯一标识做区分的数据
- (void)getIdentifyBook {
    XWBook *book = [XWBook new];
    book.bookId = 3;
    [XWDatabase getModel:book identifier:@"101" completion:^(XWBook * obj) {
        NSLog(@"getIdentifyBook  book.name:%@",obj.name);
    }];
}

@end
