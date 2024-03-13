//
//  SDPDBManager.h
//  gather
//
//  Created by jhon on 2020/5/22.
//  Copyright © 2020 shengpay. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDPDBManager : NSObject

+(instancetype)shareDataManager;

/**
 * 添加信息
*/
-(void)addGatherInfo:(nullable NSDictionary *)info withPriority:(NSUInteger)priority;

/**
 * 删除信息
*/
-(void)deleteGatherInfoWithPriority:(NSUInteger)priority withNum:(NSInteger)num;

/**
 * 查询全部信息条数
*/
- (NSUInteger)queryGatherInfoNumWithPriority:(NSUInteger)priority;

/**
 * 获取指定数量信息
*/
- (NSMutableArray *)getGatherInfoWithPriority:(NSUInteger)priority withNum:(NSInteger)num;

/**
 * 判断表是否存在
*/
-(BOOL)isExistTable:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
