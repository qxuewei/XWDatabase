//
//  XWPerson.m
//  XWDatabase_Example
//
//  Created by 邱学伟 on 2018/12/6.
//  Copyright © 2018 qxuewei@yeah.net. All rights reserved.
//

#import "XWPerson.h"
#import "XWDatabase.h"
#import "XWBook.h"

@implementation XWPerson

#pragma mark - public
/// 测试数据
+ (XWPerson *)testPerson:(int)index {
    XWPerson *person = [[XWPerson alloc] init];
    person.cardID = [NSString stringWithFormat:@"%d",index];
    person.age = 18 + arc4random_uniform(100);
    person.name = person.age % 2 == 0 ? @"极客学伟" : @"www.qiuxuewei.com";
    person.sex = @"male";
    person.birthday = [NSDate date];
    person.girls = @[@"小妹",@"校花",@"小baby"].mutableCopy;
    person.books = @{@"name":@"iOS 从入门到掉头发"}.mutableCopy;
    person.number = [NSNumber numberWithBool:YES];
    person.floatNumber = [NSNumber numberWithFloat:3.1415926];
    UIImage *image = [UIImage imageNamed:@"icon"];
    person.icon = UIImageJPEGRepresentation(image, 0.5).mutableCopy;
    person.image = image;
    person.pFloat = 1.1111;
    person.pInt = 3;
    person.pDouble = 2.2222;
    person.pLong = 88;
    person.pLongLong = 999999999999;
    person.pBOOL = YES;
    person.pBooll = false;
    person.pInteger = -10086;
    person.pUInteger = 10010;
    person.pCGFloat = 3.33;
    person.pPoint = CGPointMake(10, 10);
    person.pRect = CGRectMake(0, 0, 100, 100);
    person.pSize = CGSizeMake(200, 300);
    person.pSet = [NSSet setWithObjects:@"Set",@(123),nil];
    person.pSetM = [NSMutableSet setWithObjects:@"MutableSet",@(456), nil];
    person.pAttributedString = [[NSAttributedString alloc] initWithString:@"NSAttributedString"];
    person.pMutableAttributedString = [[NSMutableAttributedString alloc] initWithString:@"NSMutableAttributedString"];
    person.URL = [NSURL URLWithString:@"www.qiuxuewei.com"];
    person.pRange = NSMakeRange(0, 99);
    person.indexPath = [NSIndexPath indexPathForItem:1 inSection:2];
    
    XWBook *book = [XWBook new];
    book.name = @"name";
    book.author = @"JK";
    person.favoriteBook = book;
    
    return person;
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

/// 自定义对象映射`
+ (NSDictionary *)xw_customModelMapping {
    return @{
             @"favoriteBook" : [XWBook class]
             };
}

/// 自定义表名
+ (NSString *)xw_customTableName {
    return @"Person";
}

/// 忽略的成员变量
+ (NSSet<NSString *> *)xw_ignoreColumnNames {
    return [NSSet setWithObject:@"floatNumber"];
}

/// 自定义字段名映射表 (默认成员变量即变量名, 可自定义字段名 key: 成员变量(属性)名称  value: 自定义数据库表字段名)
+ (NSDictionary *)xw_customColumnMapping {
    return  @{
              @"sex" : @"gender",
              @"girls" : @"sweethearts"
              };
}

@end
