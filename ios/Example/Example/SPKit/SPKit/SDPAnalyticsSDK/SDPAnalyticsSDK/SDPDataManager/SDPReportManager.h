//
//  SDPReportManager.h
//  MobileProject-OC
//
//  Created by jhon on 2020/5/18.
//  Copyright © 2020 smger. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDPReportManager : NSObject

+ (SDPReportManager * _Nullable)sharedInstance;

/**
 *  发起上报
 *
 *  @param priority 数据优先级
*/
-(void)dispatch:(NSUInteger)priority;

/**
 *  设置集成环境
 *
 *  @param value 默认为NO,关闭状态
*/
- (void)setTestEnv:(BOOL)value;

@end

NS_ASSUME_NONNULL_END
