//
//  XWTestSubModel.h
//  XWDatabase_Example
//
//  Created by 邱学伟 on 2019/3/11.
//  Copyright © 2019 qxuewei@yeah.net. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XWTestSubModel : NSObject <NSCoding, NSSecureCoding>

@property (nonatomic, assign) NSInteger uuid;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) UIImage *icon;

+ (instancetype)testTestSubModel;
@end

NS_ASSUME_NONNULL_END
