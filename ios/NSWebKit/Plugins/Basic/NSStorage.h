//
//  NSStorage.h
//  NSKit
//
//  Created by Neil on 2022/3/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSStorage : NSObject

/// 保存
/// @param key  键名
/// @param value 键值
+ (void)set:(NSString *)key value:(id<NSCopying>)value;

/// 保存
/// @param key  键名
/// @param value 键值
/// @param groupName 组名
+ (void)set:(NSString *)key value:(id<NSCopying>)value groupName:(nullable NSString *)groupName;

/// 保存
/// @param key  键名
/// @param value 键值
/// @param groupName 组名
/// @param validSecond 缓存有效时间 为0时,表示永久 单位秒

+ (void)set:(NSString *)key value:(id<NSCopying>)value groupName:(nullable NSString *)groupName validSecond:(NSUInteger)validSecond;

/// 取值
/// @param key 键名
+ (id)get:(NSString *)key;

/// 取值
/// @param key 键名
/// @param groupName 组名
+ (id)get:(NSString *)key groupName:(nullable NSString *)groupName;

/// 删除指定键
/// @param key 键名
+ (void)remove:(NSString *)key;

/// 删除指定键
/// @param key 键名
/// @param groupName 组名
+ (void)remove:(NSString *)key groupName:(nullable NSString *)groupName;


/// 清除所有数据
+ (void)clear;

/// 清除指定组名下的数据
/// @param groupName 组名
+ (void)clearWithGroupName:(nullable NSString *)groupName;


@end

NS_ASSUME_NONNULL_END
