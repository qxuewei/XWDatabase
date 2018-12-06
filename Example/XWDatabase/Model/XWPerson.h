//
//  XWPerson.h
//  XWDatabase_Example
//
//  Created by 邱学伟 on 2018/12/6.
//  Copyright © 2018 qxuewei@yeah.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWDatabaseModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface XWPerson : NSObject <XWDatabaseModelProtocol>

@property (nonatomic, copy)   NSString *cardID;
//@property (nonatomic, copy)   NSString *name;
//@property (nonatomic, copy)   NSString *sex;
//@property (nonatomic, assign) NSInteger age;
//@property (nonatomic, strong) NSDate *birthday;
//@property (nonatomic, strong) NSData *icon;
//@property (nonatomic, strong) NSArray *girls;
//@property (nonatomic, strong) NSDictionary *books;
//@property (nonatomic, assign) CGFloat pCGFloat;
//@property (nonatomic, assign) float pFloat;
//@property (nonatomic, assign) int pInt;
//@property (nonatomic, assign) double pDouble;
//@property (nonatomic, assign) long pLong;
//@property (nonatomic, assign) BOOL pBOOL;
//@property (nonatomic, assign) bool pBooll;
//@property (nonatomic, assign) long long pLongLong;
//@property (nonatomic, assign) NSInteger pInteger;
//@property (nonatomic, assign) NSUInteger pUInteger;
@property (nonatomic, assign) CGPoint pPoint;
@property (nonatomic, assign) CGRect pRect;
@property (nonatomic, assign) CGSize pSize;

+ (XWPerson *)testPerson:(int)index;
@end

NS_ASSUME_NONNULL_END
