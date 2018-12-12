//
//  XWDatabaseDataModel.h
//  XWDatabase_Example
//
//  Created by 邱学伟 on 2018/12/12.
//  Copyright © 2018 qxuewei@yeah.net. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XWDatabaseDataModel : NSObject

/**
 Data Hash
 */
@property (nonatomic, assign) NSUInteger hashID;

/**
 Data
 */
@property (nonatomic, strong) NSData *data;

@end

NS_ASSUME_NONNULL_END
