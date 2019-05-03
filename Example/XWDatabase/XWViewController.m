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
#import "XWTestModel.h"
#import "XWTestSubModel.h"

#define kUser1ID @"10010a"
#define kUser2ID @"10086"
#define kUser3ID @"jsjhshshkaass"

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
    [self saveOneBook];
//    [self saveBooks];
//    [self addImages];
//    [self addIdentifyBooks];
//    [self testSaveModel];
//    [self testSaveModels];

    /// 删
//    [self deleteModel];
//    [self deleteBook];
//    [self clearModel];
//    [self deleteBooks];
//    [self testDeleteModel];
//    [self testClearModels];
//    [self testClearModels2];

    /// 改
//    [self updateModel];
//    [self updateBook];
//    [self updatePersons];
//    [self updateBooks];
//    [self updateImages];
//    [self testUpdateModel];
//    [self testUpdateCondition];
    
    /// 查
//    [self getOnePerson];
    [self getOneBook];
//    [self getModels];
//    [self getBookModels];
//    [self getImages];
//    [self getModelsCondition];
//    [self getModelsSortAge];
//    [self getModelsConditionSort];
//    [self getImage];
//    [self getIdentifyBook];
//    [self testGetModel];
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
    book.bookId = 1;
    NSString *author = @"Abe's Crazy English \\ ' & $ ^ ' '  * & & | } {' : > ? < ,@ ! ~ ` HAHAHA";
    book.name = [NSString stringWithFormat:@"bookName \\ ' & $ ^ @ ! ~ `"];
    book.author = author;
    book.bookConcern = author;
//    book.array = @[@" ' ' ' ",author];
//    book.dictionary = @{@" ' ' ' ":author};
    
    XWTestSubModel *subModel = [[XWTestSubModel alloc] init];
    subModel.uuid = 110;
    subModel.name = @"XWTestSubModel Name";
    subModel.icon = [UIImage imageNamed:@"icon"];
    book.subModel = subModel;
    [XWDatabase saveModel:book identifier:kUser2ID completion:^(BOOL isSuccess) {
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
    
    NSMutableArray *persons2 = [[NSMutableArray alloc] init];
    for (int i = 0; i < 20; i++) {
        [persons2 addObject:[XWPerson testPerson:i]];
    }
    [XWDatabase saveModels:persons2 identifier:kUser2ID completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> saveModels identifier (%@)",isSuccess?@"成功":@"失败");
    }];
}

/// 保存模型数组 (用户区分)
- (void)saveBooks
{
    NSMutableArray *books = [[NSMutableArray alloc] init];
    NSString *author = @"Abe's Crazy English ";
    for (int i = 0; i < 100; i++) {
        XWBook *book = [XWBook new];
        book.bookId = i;
        book.name = [NSString stringWithFormat:@"bookName_%d",i];
        book.author = author;
        book.bookConcern = @"bookConcern";
        book.array = @[@" ' ' ' ",author];
        book.dictionary = @{@" ' ' ' ":author};
        
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
    
    NSMutableArray *images2 = [NSMutableArray array];
    for (int i = 0; i < 50; i++) {
        XWImage *image = [XWImage new];
        image.name = [NSString stringWithFormat:@"name2 - %d",i];
        image.filePath = [NSString stringWithFormat:@"filePath2 - %d",i];
        [images2 addObject:image];
    }
    [XWDatabase saveModels:images2 identifier:kUser1ID completion:^(BOOL isSuccess) {
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

/// 保存模型
- (void)testSaveModel {
    
    XWTestModel *model = [XWTestModel testModel:1];
    /// 保存有主键模型
    [XWDatabase saveModel:model completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> saveModel  (%@)",isSuccess?@"成功":@"失败");
    }];
    /// 保存有主键模型 (指定用户)
    [XWDatabase saveModel:model identifier:kUser1ID completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> saveModel (%@)",isSuccess?@"成功":@"失败");
    }];
    
    XWTestSubModel *subModel = [XWTestSubModel testTestSubModel];
    /// 保存无主键模型
    [XWDatabase saveModel:subModel completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> saveModel (%@)",isSuccess?@"成功":@"失败");
    }];
    /// 保存无主键模型 (指定用户)
    [XWDatabase saveModel:subModel identifier:kUser1ID completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> saveModel (%@)",isSuccess?@"成功":@"失败");
    }];
}

/// 保存多个模型
- (void)testSaveModels {
    NSMutableArray *models = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        XWTestModel *model = [XWTestModel testModel:i];
        [models addObject:model];
    }
    /// 保存有主键模型
    [XWDatabase saveModels:models completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> testSaveModels  (%@)",isSuccess?@"成功":@"失败");
    }];
    
    NSMutableArray *models2 = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        XWTestModel *model = [XWTestModel testModel:i];
        [models2 addObject:model];
    }
    /// 保存有主键模型 (指定用户)
    [XWDatabase saveModels:models2 identifier:kUser2ID completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> testSaveModels (%@)",isSuccess?@"成功":@"失败");
    }];
    
    NSMutableArray *subModels = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        XWTestSubModel *subModel = [XWTestSubModel testTestSubModel];
        [subModels addObject:subModel];
    }
    /// 保存无主键模型
    [XWDatabase saveModels:subModels completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> testSaveModels (%@)",isSuccess?@"成功":@"失败");
    }];
    
    NSMutableArray *subModels2 = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        XWTestSubModel *subModel = [XWTestSubModel testTestSubModel];
        [subModels2 addObject:subModel];
    }
    /// 保存无主键模型 (指定用户)
    [XWDatabase saveModels:subModels2 identifier:kUser2ID completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> testSaveModels (%@)",isSuccess?@"成功":@"失败");
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
    [XWDatabase deleteModel:book identifier:kUser2ID completion:^(BOOL isSuccess) {
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

/// 删除指定主键模型
- (void)testDeleteModel {
    XWTestModel *model = [XWTestModel new];
    model.cardID = @"1";
    /// 删除通用模型 , 主键 ID 为 1
    [XWDatabase deleteModel:model completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> deleteModel saveOneBook (%@)",isSuccess?@"成功":@"失败");
    }];
    /// 删除指定用户模型 , 主键 ID 为 1
    [XWDatabase deleteModel:model identifier:kUser1ID completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> deleteModel saveOneBook (%@)",isSuccess?@"成功":@"失败");
    }];
}

/// 删除指定模型
- (void)testClearModels {
    [XWDatabase clearModel:XWTestModel.class completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> clearModel (%@)",isSuccess?@"成功":@"失败");
    }];
    
    [XWDatabase clearModel:XWTestSubModel.class identifier:kUser2ID completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> clearModel (%@)",isSuccess?@"成功":@"失败");
    }];
}

/// 删除符合条件的模型
- (void)testClearModels2 {
    [XWDatabase clearModel:XWTestModel.class condition:@"name = '极客学伟'" completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> clearModel (%@)",isSuccess?@"成功":@"失败");
    }];
    
    [XWDatabase clearModel:XWTestModel.class identifier:kUser2ID condition:@"age > 30" completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> clearModel (%@)",isSuccess?@"成功":@"失败");
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

/// 更新指定主键模型
- (void)testUpdateModel {
    XWTestModel *model = [XWTestModel new];
    model.cardID = @"1";
    model.name = @"新名字";
    [XWDatabase updateModel:model updatePropertys:@[@"name"] completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> updateModel 指定属性 (%@)",isSuccess?@"成功":@"失败");
    }];
    
    XWTestModel *model2 = [XWTestModel new];
    model2.cardID = @"2";
    model2.name = @"CCTV";
    model2.age = 99;
    [XWDatabase updateModel:model2 updatePropertys:nil completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> updateModel 全部属性 (%@)",isSuccess?@"成功":@"失败");
    }];
    
    XWTestModel *model3 = [XWTestModel new];
    model3.cardID = @"1";
    model3.name = @"新名字-10086";
    [XWDatabase updateModel:model3 identifier:kUser2ID updatePropertys:@[@"name"] completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> updateModel 指定属性 (%@)",isSuccess?@"成功":@"失败");
    }];
    
    XWTestModel *model4 = [XWTestModel new];
    model4.cardID = @"2";
    model4.name = @"白说";
    model4.age = 199;
    [XWDatabase updateModel:model4 identifier:kUser2ID updatePropertys:nil completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> updateModel 全部属性 (%@)",isSuccess?@"成功":@"失败");
    }];
    
    NSMutableArray *models = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        XWTestModel *model = [XWTestModel testModel:i];
        model.name = @"陪我欢乐";
        [models addObject:model];
    }
    [XWDatabase updateModels:models updatePropertys:@[@"name"] completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> updateModels 全部属性 (%@)",isSuccess?@"成功":@"失败");
    }];
    
    NSMutableArray *models2 = [NSMutableArray array];
    for (int i = 5; i < 10; i++) {
        XWTestModel *model = [XWTestModel new];
        model.cardID = [NSString stringWithFormat:@"%d",i];
        model.name = @"波场";
        [models2 addObject:model];
    }
    [XWDatabase updateModels:models2 updatePropertys: nil completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> updateModels 部分属性 (%@)",isSuccess?@"成功":@"失败");
    }];
    
    NSMutableArray *models3 = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        XWTestModel *model = [XWTestModel testModel:i];
        model.name = @"兰雄传媒";
        [models3 addObject:model];
    }
    [XWDatabase updateModels:models3 identifier:kUser2ID updatePropertys:@[@"name"] completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> updateModels 全部属性 (%@)",isSuccess?@"成功":@"失败");
    }];
    
    NSMutableArray *models4 = [NSMutableArray array];
    for (int i = 5; i < 10; i++) {
        XWTestModel *model = [XWTestModel new];
        model.cardID = [NSString stringWithFormat:@"%d",i];
        model.name = @"疯火科技";
        [models4 addObject:model];
    }
    [XWDatabase updateModels:models4 identifier:kUser2ID updatePropertys: nil completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> updateModels 全部属性 (%@)",isSuccess?@"成功":@"失败");
    }];
}

/// 指定条件更新
- (void)testUpdateCondition {
    XWTestModel *model5 = [XWTestModel new];
    model5.name = @"腾讯";
    [XWDatabase updateModels:model5 updatePropertys:@[@"name"] condition:@"age < 40" completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> updateModels 部分属性 (%@)",isSuccess?@"成功":@"失败");
    }];
    
    XWTestModel *model6 = [XWTestModel new];
    model6.name = @"百度";
    [XWDatabase updateModels:model6 updatePropertys:nil condition:@"age > 40" completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> updateModels 部分属性 (%@)",isSuccess?@"成功":@"失败");
    }];
    
    XWTestModel *model7 = [XWTestModel new];
    model7.name = @"阿里巴巴";
    [XWDatabase updateModels:model7 identifier:kUser2ID updatePropertys:@[@"name"] condition:@"age < 40" completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> updateModels 部分属性 (%@)",isSuccess?@"成功":@"失败");
    }];
    
    XWTestModel *model8 = [XWTestModel new];
    model8.name = @"美团";
    [XWDatabase updateModels:model8 identifier:kUser2ID updatePropertys:nil condition:@"age > 40" completion:^(BOOL isSuccess) {
        NSLog(@" <XWDatabase> updateModels 部分属性 (%@)",isSuccess?@"成功":@"失败");
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
        NSLog(@" <XWDatabase> getModels XWPerson (objs.count: %lu)",objs.count);
    }];
    
    [XWDatabase getModels:XWImage.class completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels XWImage (objs.count: %lu)",objs.count);
    }];
}

/// 获取数据库中所有该模型存储的数据 - 指定用户 101
- (void)getBookModels
{
    [XWDatabase getModels:XWBook.class identifier:@"101" completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels XWBook (objs.count: %lu)",objs.count);
    }];
    
}

/// 获取数据库中所有该模型存储的数据(无主键) - 指定用户
- (void)getImages {
    [XWDatabase getModels:XWImage.class completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels XWImage (objs.count: %lu)",objs.count);
    }];
    
    [XWDatabase getModels:XWImage.class identifier:kUser1ID completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels XWImage identifier (objs.count: %lu)",objs.count);
    }];
}

/// 获取模型
- (void)testGetModel {
    XWTestModel *model = [XWTestModel new];
    model.cardID = @"1";
    [XWDatabase getModel:model completion:^(XWTestModel * obj) {
        NSLog(@" <XWDatabase> getModel name:%@",obj.name);
    }];
    
    [XWDatabase getModel:model identifier:kUser2ID completion:^(XWTestModel * obj) {
        NSLog(@" <XWDatabase> getModel identifier name:%@",obj.name);
    }];
    
    [XWDatabase getModels:XWTestModel.class completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels (objs.count: %lu)",objs.count);
    }];
    
    [XWDatabase getModels:XWTestModel.class identifier:kUser2ID completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels (objs.count: %lu)",objs.count);
    }];
    
    [XWDatabase getModels:XWTestModel.class condition:@"age > 40" completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels (objs.count: %lu)",objs.count);
        for (XWTestModel *model in objs) {
            NSLog(@"model.age: %ld",(long)model.age);
        }
    }];
    
    [XWDatabase getModels:XWTestModel.class identifier:kUser2ID condition:@"age < 40" completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels (objs.count: %lu)",objs.count);
        for (XWTestModel *model in objs) {
            NSLog(@"model.age: %ld",(long)model.age);
        }
    }];
    
    [XWDatabase getModels:XWTestModel.class sortColumn:@"age" isOrderDesc:YES completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels sortColumn (objs.count: %lu)",objs.count);
        for (XWTestModel *model in objs) {
            NSLog(@"model.age: %ld",(long)model.age);
        }
    }];
    
    [XWDatabase getModels:XWTestModel.class identifier:kUser2ID sortColumn:@"age" isOrderDesc:NO completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels sortColumn (objs.count: %lu)",objs.count);
        for (XWTestModel *model in objs) {
            NSLog(@"model.age: %ld",(long)model.age);
        }
    }];
    
    [XWDatabase getModels:XWTestModel.class sortColumn:@"age" isOrderDesc:YES condition:@"age > 40" completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels sortColumn condition (objs.count: %lu)",objs.count);
        for (XWTestModel *model in objs) {
            NSLog(@"model.age: %ld",(long)model.age);
        }
    }];
    
    [XWDatabase getModels:XWTestModel.class identifier:kUser2ID sortColumn:@"age" isOrderDesc:NO condition:@"age < 40" completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels sortColumn condition (objs.count: %lu)",objs.count);
        for (XWTestModel *model in objs) {
            NSLog(@"model.age: %ld",(long)model.age);
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
//    
//    /// SQLite 模糊查询默认大小写不敏感
//    [XWDatabase getModels:XWPerson.class condition:@"gender like '%m%' AND name like '%xue%'" completion:^(NSArray * _Nullable objs) {
//        NSLog(@" <XWDatabase> getModels (objs.count: %lu)",objs.count);
//        for (XWPerson *person in objs) {
//            NSLog(@"cardID : %@ name : %@ -- age: %zd -- sex: %@",person.cardID,person.name,person.age,person.sex);
//        }
//    }];
    
    [XWDatabase getModels:XWPerson.class identifier:kUser2ID condition:@"age < 30" completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels (objs.count: %lu)",objs.count);
        for (XWPerson *person in objs) {
            NSLog(@"cardID : %@ name : %@ -- age: %zd -- sex: %@",person.cardID,person.name,person.age,person.sex);
        }
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
    
    [XWDatabase getModels:XWPerson.class identifier:kUser2ID sortColumn:@"age" isOrderDesc:NO completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels (objs.count: %lu)",objs.count);
        for (XWPerson *person in objs) {
            NSLog(@"cardID : %@ -- age: %zd",person.cardID,person.age);
        }
    }];
    
    [XWDatabase getModels:XWPerson.class identifier:kUser2ID sortColumn:@"age" isOrderDesc:YES completion:^(NSArray * _Nullable objs) {
        NSLog(@" <XWDatabase> getModels (objs.count: %lu)",objs.count);
        for (XWPerson *person in objs) {
            NSLog(@"cardID : %@ -- age: %zd",person.cardID,person.age);
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
    
    [XWDatabase getModels:XWPerson.class identifier:kUser2ID sortColumn:@"age" isOrderDesc:NO condition:@"name like '%学伟'" completion:^(NSArray * _Nullable objs) {
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
