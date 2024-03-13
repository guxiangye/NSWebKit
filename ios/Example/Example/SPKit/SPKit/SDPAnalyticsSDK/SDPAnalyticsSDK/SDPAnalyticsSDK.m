//
//  SDPAnalyticsSDK.m
//  SDPAutoTrack
//
//  Created by 高鹏程 on 2020/5/27.
//  Copyright © 2020 高鹏程. All rights reserved.
//

#import "SDPAnalyticsSDK.h"
#import "SDPAutoTrack.h"
#import "SDPAnalyticsManager.h"
#import "SDPAutoTrackConstants.h"
#import "SDPAnalyticsSDK+AutoTrack.h"
#import "SDPAutoTrackUtils.h"
#import "SDPReportManager.h"

@implementation SDPAnalyticsSDK
#pragma mark - 设置appid
+ (void)setAppid:(NSString *)appid {
    SDPAnalyticsManager *singleton = [SDPAnalyticsManager sharedInstance];
    singleton.appid = appid;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SDP_AUTOTRACK_TRY_CATCH_BEGIN
        NSDictionary *trackInfo = [SDPAutoTrackUtils trackInfoWithAppLaunchContext];
        [SDPAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:SDPSendRealTime];
        SDP_AUTOTRACK_TRY_CATCH_END
    });
}

+ (void)setTestEnv:(BOOL)value {
    [[SDPReportManager sharedInstance] setTestEnv:value];
}

#pragma mark - 开启自动打点
+ (void)enableAutoTrack {
    [SDPAutoTrack enableAutoTrack];
}

#pragma mark - 禁用自动打点
+ (void)disableAutoTrack {
    [SDPAutoTrack disableAutoTrack];
}

#pragma mark - 设置 埋点控制器的基类 如果不设置,默认 采集所有UIViewController的控制器
+ (void)setTrackViewControllerClass:(Class)baseClass {
    SDPAnalyticsManager *singleton = [SDPAnalyticsManager sharedInstance];
    singleton.trackViewControlerClass = baseClass;
}


#pragma mark - 设置获取通用信息回调
+ (void)setFetchCommonInfoBlock:(NSDictionary * (^)(void))block {
    SDPAnalyticsManager *singleton = [SDPAnalyticsManager sharedInstance];
    singleton.fetchCommonInfoBlock = block;
}

+ (void)event:(NSString *)eventId properties:(NSDictionary *)properties {
    [self event:eventId properties:properties reportPolicy:SDPSendDelay];
}

+ (void)event:(NSString *)eventId properties:(NSDictionary *)properties reportPolicy:(SDPReportPolicy)rp {
    SDP_AUTOTRACK_TRY_CATCH_BEGIN

    SDP_AUTOTRACK_TRY_CATCH_END
}

@end
