//
//  XWLivingThread.h
//  XWDatabase
//
//  Created by 邱学伟 on 2018/12/5.
//  Copyright © 2018 邱学伟. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^XWLivingThreadTask)(void);

@interface XWLivingThread : NSObject
/**
 主线程触发某操作
 
 @param task 任务
 */
+ (void)executeTaskInMain:(XWLivingThreadTask)task;

/**
 在默认全局常驻线程中执行操作 (只要调用,默认线程即创建且不会销毁)
 
 @param task 操作
 */
+ (void)executeTask:(XWLivingThreadTask)task;

/**
 在自定义全局常驻线程中执行操作 (根据 identity 创建自定义线程,且创建后不会销毁)
 
 @param task 操作
 @param identity 自定义线程唯一标识
 */
+ (void)executeTask:(XWLivingThreadTask)task identity:(NSString *)identity;

/**
 在默认常驻线程中执行操作 (线程需随当前对象创建或销魂)
 
 @param task 操作
 */
- (void)executeTask:(XWLivingThreadTask)task;

@end

NS_ASSUME_NONNULL_END
