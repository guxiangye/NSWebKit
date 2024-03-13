//
//  NSAnalyticsSDK.h
//  NSAutoTrack
//
//  Created by Neil on 2020/5/27.
//  Copyright © 2020 Neil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSAnalyticsExtraPropsProtocol.h"
NS_ASSUME_NONNULL_BEGIN
/**
 *  采集数据发送策略
 */
typedef enum : NSUInteger {
    /**Current  无条件及时上报*/
    NSSendRealTime = 0,
    /**WifiCurrent  wifi实时上报*/
    NSSendCurrentWifi = 1,
    /**Delay  延迟上报（默认）*/
    NSSendDelay = 2,
    /**Disposable  一次性上报*/
    NSSendDisposable = 3
} NSReportPolicy;

@interface NSAnalyticsSDK : NSObject

/// 设置 appid
/// @param appid appid
+ (void)setAppid:(NSString *)appid;

/// 设置集成测试环境
/// @param value 默认为NO,关闭状态
+ (void)setTestEnv:(BOOL)value;

/// 开启自动打点
+ (void)enableAutoTrack;

/// 禁用自动打点
+ (void)disableAutoTrack;
/// 设置 埋点控制器的基类 如果不设置,默认 采集所有UIViewController的控制器
+ (void)setTrackViewControllerClass:(Class)baseClass;

/// 设置获取通用信息回调
/// @param block 回调 返回的信息里应有如下内容
/// uhid:用户编号
/// dhid:设备编号
/// sdkVersion: SDK版本
/// northLat :纬度(可选)
/// eastLng: 经度(可选)
+ (void)setFetchCommonInfoBlock:(NSDictionary * (^)(void))block;

+ (void)event:(NSString *)eventId properties:(NSDictionary *)properties;
+ (void)event:(NSString *)eventId properties:(NSDictionary *)properties reportPolicy:(NSReportPolicy)rp;

@end



NS_ASSUME_NONNULL_END
