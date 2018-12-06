//
//  XWPerson.m
//  XWDatabase_Example
//
//  Created by 邱学伟 on 2018/12/6.
//  Copyright © 2018 qxuewei@yeah.net. All rights reserved.
//

#import "XWPerson.h"
#import "XWDatabase.h"

@implementation XWPerson

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [XWDatabase updateTable:self completion:^(BOOL isSuccess) {
            NSLog(@"updateTable (%d)",isSuccess);
        }];
    });
}

+ (NSString *)xw_primaryKey {
    return @"cardID";
}

+ (XWPerson *)testPerson:(int)index {
    XWPerson *person = [[XWPerson alloc] init];
    person.cardID = [NSString stringWithFormat:@"%d",index];
//    person.age = 18 + arc4random_uniform(100);
//    person.name = person.age % 2 == 0 ? @"极客学伟" : @"www.qiuxuewei.com";
//    person.sex = @"male";
//    person.birthday = [NSDate date];
//    person.girls = @[@"小妹",@"校花",@"小baby"];
//    person.books = @{@"name":@"iOS 从入门到掉头发"};
//
//    UIImage *image = [UIImage imageNamed:@"icon"];
//    person.icon = UIImageJPEGRepresentation(image, 0.5);
//
//
//    person.pFloat = 1.1111;
//    person.pInt = 3;
//    person.pDouble = 2.2222;
//    person.pLong = 88888888888888;
//    person.pLongLong = 999999999999;
//    person.pBOOL = YES;
//    person.pBooll = false;
//    person.pInteger = -10086;
//    person.pUInteger = 10010;
    
//    person.pCGFloat = 3.33;
    
    person.pPoint = CGPointMake(10, 10);
    person.pRect = CGRectMake(0, 0, 100, 100);
    person.pSize = CGSizeMake(200, 300);
    
    return person;
}
@end
