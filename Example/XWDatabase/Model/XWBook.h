//
//  XWBook.h
//  XWDatabase_Example
//
//  Created by 邱学伟 on 2018/12/11.
//  Copyright © 2018 qxuewei@yeah.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XWDatabaseModelProtocol.h"

@class XWTestSubModel;

NS_ASSUME_NONNULL_BEGIN

@interface XWBook : NSObject <NSCoding, NSSecureCoding, XWDatabaseModelProtocol>

@property (nonatomic, assign) int bookId;
@property (nonatomic, copy) NSMutableString *name;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *bookConcern;

@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, strong) NSMutableDictionary *dictionaryM;

@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSMutableArray *arrayM;


@property (nonatomic, strong) XWTestSubModel *subModel;

//@property (nonatomic, copy) NSString *temp;
//@property (nonatomic, copy) NSString *temp2;


@end

NS_ASSUME_NONNULL_END
