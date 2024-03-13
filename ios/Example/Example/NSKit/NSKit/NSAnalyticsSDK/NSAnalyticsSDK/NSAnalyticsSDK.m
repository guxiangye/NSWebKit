//
//  NSAnalyticsSDK.m
//  NSAutoTrack
//
//  Created by Neil on 2020/5/27.
//  Copyright © 2020 Neil. All rights reserved.
//

#import "NSAnalyticsSDK.h"
#import "NSAutoTrack.h"
#import "NSAnalyticsManager.h"
#import "NSAutoTrackConstants.h"
#import "NSAnalyticsSDK+AutoTrack.h"
#import "NSAutoTrackUtils.h"
#import "NSReportManager.h"

@implementation NSAnalyticsSDK
#pragma mark - 设置appid
+ (void)setAppid:(NSString *)appid {
    NSAnalyticsManager *singleton = [NSAnalyticsManager sharedInstance];
    singleton.appid = appid;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NS_AUTOTRACK_TRY_CATCH_BEGIN
        NSDictionary *trackInfo = [NSAutoTrackUtils trackInfoWithAppLaunchContext];
        [NSAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:NSSendRealTime];
        NS_AUTOTRACK_TRY_CATCH_END
    });
}

+ (void)setTestEnv:(BOOL)value {
    [[NSReportManager sharedInstance] setTestEnv:value];
}

#pragma mark - 开启自动打点
+ (void)enableAutoTrack {
    [NSAutoTrack enableAutoTrack];
}

#pragma mark - 禁用自动打点
+ (void)disableAutoTrack {
    [NSAutoTrack disableAutoTrack];
}

#pragma mark - 设置 埋点控制器的基类 如果不设置,默认 采集所有UIViewController的控制器
+ (void)setTrackViewControllerClass:(Class)baseClass {
    NSAnalyticsManager *singleton = [NSAnalyticsManager sharedInstance];
    singleton.trackViewControlerClass = baseClass;
}


#pragma mark - 设置获取通用信息回调
+ (void)setFetchCommonInfoBlock:(NSDictionary * (^)(void))block {
    NSAnalyticsManager *singleton = [NSAnalyticsManager sharedInstance];
    singleton.fetchCommonInfoBlock = block;
}

+ (void)event:(NSString *)eventId properties:(NSDictionary *)properties {
    [self event:eventId properties:properties reportPolicy:NSSendDelay];
}

+ (void)event:(NSString *)eventId properties:(NSDictionary *)properties reportPolicy:(NSReportPolicy)rp {
    NS_AUTOTRACK_TRY_CATCH_BEGIN

    NS_AUTOTRACK_TRY_CATCH_END
}

@end
