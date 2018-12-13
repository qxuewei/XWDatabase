//
//  XWPerson.h
//  XWDatabase_Example
//
//  Created by 邱学伟 on 2018/12/6.
//  Copyright © 2018 qxuewei@yeah.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWDatabaseModelProtocol.h"
@class XWBook;

NS_ASSUME_NONNULL_BEGIN

@interface XWPerson : NSObject <XWDatabaseModelProtocol>

@property (nonatomic, copy)   NSString *cardID;
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSString *sex;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) NSMutableData *icon;
@property (nonatomic, strong) NSMutableArray *girls;
@property (nonatomic, strong) NSMutableDictionary *books;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSNumber *floatNumber;
@property (nonatomic, strong) NSSet *pSet;
@property (nonatomic, strong) NSMutableSet *pSetM;
@property (nonatomic, strong) NSAttributedString *pAttributedString;
@property (nonatomic, strong) NSMutableAttributedString *pMutableAttributedString;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) CGFloat pCGFloat;
@property (nonatomic, assign) float pFloat;
@property (nonatomic, assign) int pInt;
@property (nonatomic, assign) double pDouble;
@property (nonatomic, assign) long pLong;
@property (nonatomic, assign) BOOL pBOOL;
@property (nonatomic, assign) bool pBooll;
@property (nonatomic, assign) long long pLongLong;
@property (nonatomic, assign) NSInteger pInteger;
@property (nonatomic, assign) NSUInteger pUInteger;
@property (nonatomic, assign) CGPoint pPoint;
@property (nonatomic, assign) CGRect pRect;
@property (nonatomic, assign) CGSize pSize;


@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, assign) NSRange pRange;

@property (nonatomic, strong) XWBook *favoriteBook;

+ (XWPerson *)testPerson:(int)index;

@end

NS_ASSUME_NONNULL_END
