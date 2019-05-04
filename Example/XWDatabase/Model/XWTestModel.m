//
//  XWTestModel.m
//  XWDatabase_Example
//
//  Created by 邱学伟 on 2019/3/11.
//  Copyright © 2019 qxuewei@yeah.net. All rights reserved.
//

#import "XWTestModel.h"
#import "XWDatabase.h"
#import "XWTestSubModel.h"

@interface XWTestModel ()

@property (nonatomic, assign) NSInteger private;

@end

@implementation XWTestModel

#pragma mark - public
/// 测试数据
+ (XWTestModel *)testModel:(int)index {
    
    XWTestModel *model = [[XWTestModel alloc] init];
    model.cardID = [NSString stringWithFormat:@"%d",index];
    model.age = 18 + arc4random_uniform(100);
    model.name = model.age % 2 == 0 ? @"极客学伟" : @"www.qiuxuewei.com";
    model.sex = arc4random_uniform(2) == 1 ? @"Male" : @"male";
    model.birthday = [NSDate date];
    model.girls = @[@"小妹",@"校花",@"小baby"].mutableCopy;
    model.books = @{@"name":@"iOS 从入门到掉头发"}.mutableCopy;
    model.number = [NSNumber numberWithBool:YES];
    model.floatNumber = [NSNumber numberWithFloat:3.1415926];
    
    /// 存储二进制文件
    UIImage *image = [UIImage imageNamed:@"icon"];
    model.image = image;
    //    person.icon = UIImageJPEGRepresentation(image, 0.5).mutableCopy;
    
    model.pFloat = 1.1111;
    model.pInt = 3;
    model.pDouble = 2.2222;
    model.pLong = 88;
    model.pLongLong = 999999999999;
    model.pBOOL = YES;
    model.pBooll = false;
    model.pInteger = -10086;
    model.pUInteger = 10010;
    model.pCGFloat = 3.33;
    model.pPoint = CGPointMake(10, 10);
    model.pRect = CGRectMake(0, 0, 100, 100);
    model.pSize = CGSizeMake(200, 300);
    model.pSet = [NSSet setWithObjects:@"Set",@(123),nil];
    model.pSetM = [NSMutableSet setWithObjects:@"MutableSet",@(456), nil];
    model.pAttributedString = [[NSAttributedString alloc] initWithString:@"NSAttributedString"];
    model.pMutableAttributedString = [[NSMutableAttributedString alloc] initWithString:@"NSMutableAttributedString"];
    model.URL = [NSURL URLWithString:@"www.qiuxuewei.com"];
    model.pRange = NSMakeRange(0, 99);
    model.indexPath = [NSIndexPath indexPathForItem:1 inSection:2];
    
    model.private = 111;
    
    /// 存储自定义对象
    XWTestSubModel *subM = [XWTestSubModel testTestSubModel];
    model.favoriteBook = subM;
    
    return model;
}


#pragma mark - Life Cycle
+ (void)initialize {
    /// 数据迁移
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [XWDatabase updateTable:self completion:^(BOOL isSuccess) {
            NSLog(@" <XWDatabase> updateTable (%@)",isSuccess?@"成功":@"失败");
        }];
    });
}

#pragma mark - XWDatabaseModelProtocol

/// 主键
+ (NSString *)xw_primaryKey {
    return @"cardID";
}

/// 联合主键成员变量数组
//+ (NSArray<NSString *> *)xw_unionPrimaryKey {
//    return @[@"cardID",@"age"];
//}

/// 自定义对象映射
+ (NSDictionary *)xw_customModelMapping {
    return @{
             @"favoriteBook" : [XWTestSubModel class]
             };
}


/// 自定义字段名映射表 (默认成员变量即变量名, 可自定义字段名 key: 成员变量(属性)名称  value: 自定义数据库表字段名)
+ (NSDictionary *)xw_customColumnMapping {
    return  @{
              @"sex" : @"gender",
              @"girls" : @"sweethearts"
              };
}


@end
