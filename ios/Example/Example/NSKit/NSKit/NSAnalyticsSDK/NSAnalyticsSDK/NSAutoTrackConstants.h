//
//  NSAutoTrackConstants.h
//  NSAutoTrack
//
//  Created by Neil on 2020/5/25.
//  Copyright © 2020 Neil. All rights reserved.
//

#ifndef NSAutoTrackConstants_h
#define NSAutoTrackConstants_h
#import <Foundation/Foundation.h>
#import "NSAnalyticsSDK.h"
/// 事件类别枚举
typedef NS_OPTIONS (NSUInteger, NSAutoTrackEventType) {
    //注意:修改这个枚举的值,一定要相应修改下面NSAutoTrackEventTypeStringMap的值
    ///页面显示
    NSAutoTrackPageAppear            = 0,
    ///页面消失
    NSAutoTrackPageDisappear         = 1 << 0,
    ///控件点击
    NSAutoTrackControlClick          = 1 << 1,
    ///控件显示
    NSAutoTrackControlShow           = 1 << 2,
    ///控件消失
    NSAutoTrackControlHide           = 1 << 3,
    ///控件获取焦点
    NSAutoTrackControlOnFocus        = 1 << 4,
    ///控件失去焦点
    NSAutoTrackControlOnBlur         = 1 << 5,
    ///内容发生改变
    NSAutoTrackControlContentChanged = 1 << 6,
    ///所有类型
    NSAutoTrackEventTypeAll          = NSAutoTrackPageAppear | NSAutoTrackPageDisappear | NSAutoTrackControlClick | NSAutoTrackControlShow | NSAutoTrackControlHide | NSAutoTrackControlOnFocus | NSAutoTrackControlOnBlur | NSAutoTrackControlContentChanged,
};
#pragma mark - 事件类别
static NSString *const NS_AUTOTRACK_EVENT_TYPE_PAGEAPPEAR = @"PageAppear";
static NSString *const NS_AUTOTRACK_EVENT_TYPE_PAGEDISAPPEAR = @"PageDisappear";
static NSString *const NS_AUTOTRACK_EVENT_TYPE_CONTROLCLICK = @"ControlClick";
static NSString *const NS_AUTOTRACK_EVENT_TYPE_CONTROLSHOW = @"ControlShow";
static NSString *const NS_AUTOTRACK_EVENT_TYPE_CONTROLHIDE = @"ControlHide";
static NSString *const NS_AUTOTRACK_EVENT_TYPE_CONTROLONFOCUS = @"ControlOnFocus";
static NSString *const NS_AUTOTRACK_EVENT_TYPE_CONTROLONBLUR = @"ControlOnBlur";
static NSString *const NS_AUTOTRACK_EVENT_TYPE_ControlContentChanged = @"ControlContentChanged";
static NSString *const NS_AUTOTRACK_EVENT_TYPE_ALL = @"*";
///根据枚举获取对应字符串
static NSString *const NSAutoTrackEventTypeStringMap[] = {
    [NSAutoTrackPageAppear] = NS_AUTOTRACK_EVENT_TYPE_PAGEAPPEAR,
    [NSAutoTrackPageDisappear] = NS_AUTOTRACK_EVENT_TYPE_PAGEDISAPPEAR,
    [NSAutoTrackControlClick] = NS_AUTOTRACK_EVENT_TYPE_CONTROLCLICK,
    [NSAutoTrackControlShow] = NS_AUTOTRACK_EVENT_TYPE_CONTROLSHOW,
    [NSAutoTrackControlHide] = NS_AUTOTRACK_EVENT_TYPE_CONTROLHIDE,
    [NSAutoTrackControlOnFocus] = NS_AUTOTRACK_EVENT_TYPE_CONTROLONFOCUS,
    [NSAutoTrackControlOnBlur] = NS_AUTOTRACK_EVENT_TYPE_CONTROLONBLUR,
    [NSAutoTrackControlContentChanged] = NS_AUTOTRACK_EVENT_TYPE_ControlContentChanged,
    [NSAutoTrackEventTypeAll] = NS_AUTOTRACK_EVENT_TYPE_ALL,
};
static NSAutoTrackEventType NSAutoTrackEventTypeFromString(NSString *string)
{
    if ([string isEqualToString:NS_AUTOTRACK_EVENT_TYPE_PAGEAPPEAR]) return NSAutoTrackPageAppear;
    if ([string isEqualToString:NS_AUTOTRACK_EVENT_TYPE_PAGEDISAPPEAR]) return NSAutoTrackPageDisappear;
    if ([string isEqualToString:NS_AUTOTRACK_EVENT_TYPE_CONTROLCLICK]) return NSAutoTrackControlClick;
    if ([string isEqualToString:NS_AUTOTRACK_EVENT_TYPE_CONTROLSHOW]) return NSAutoTrackControlShow;
    if ([string isEqualToString:NS_AUTOTRACK_EVENT_TYPE_CONTROLHIDE]) return NSAutoTrackControlHide;
    if ([string isEqualToString:NS_AUTOTRACK_EVENT_TYPE_CONTROLONFOCUS]) return NSAutoTrackControlOnFocus;
    if ([string isEqualToString:NS_AUTOTRACK_EVENT_TYPE_CONTROLONBLUR]) return NSAutoTrackControlOnBlur;
    if ([string isEqualToString:NS_AUTOTRACK_EVENT_TYPE_ALL]) return NSAutoTrackEventTypeAll;
    return NSAutoTrackEventTypeAll;
}

static NSString *const NS_AUTOTRACK_REPORTPOLICY_RealTime = @"realtime";
static NSString *const NS_AUTOTRACK_REPORTPOLICY_WIFI = @"wifi";
static NSString *const NS_AUTOTRACK_REPORTPOLICY_DELAY = @"delay";
static NSString *const NS_AUTOTRACK_REPORTPOLICY_DISPOSABLE = @"disposable";

static NSReportPolicy NSReportPolicyFromString(NSString *string)
{
    if ([string isEqualToString:NS_AUTOTRACK_REPORTPOLICY_RealTime]) return NSSendRealTime;
    if ([string isEqualToString:NS_AUTOTRACK_REPORTPOLICY_WIFI]) return NSSendCurrentWifi;
    if ([string isEqualToString:NS_AUTOTRACK_REPORTPOLICY_DELAY]) return NSSendDelay;
    if ([string isEqualToString:NS_AUTOTRACK_REPORTPOLICY_DISPOSABLE]) return NSSendDisposable;
    return NSSendDisposable;
}

static NSString *const NS_AUTOTRACK_PROPERTY_EVENT_TYPE = @"eventType";

#pragma mark - 消息类别
static NSString *const NS_AUTOTRACK_MESSAGE_TYPE_CONTEXTLOG = @"contextLog";
static NSString *const NS_AUTOTRACK_MESSAGE_TYPE_EVENTLOG = @"eventLog";

static NSString *const NS_AUTOTRACK_PROPERTY_EXCEPTION = @"Exception";

static NSString *const NS_AUTOTRACK_PROPERTY_SESSION_ID = @"sessionId";
static NSString *const NS_AUTOTRACK_PROPERTY_PAGE_ID = @"pageId";

static NSString *const NS_AUTOTRACK_PROPERTY_PAGE_SESSION = @"pageSession";

//页面来源
static NSString *const NS_AUTOTRACK_PROPERTY_PAGEDESSION = @"pageDession";

static NSString *const NS_AUTOTRACK_PROPERTY_TRACK_TIME = @"track_time";
static NSString *const NS_AUTOTRACK_PROPERTY_MESSAGE_TYPE = @"messageType";
#pragma mark - user
static NSString *const NS_AUTOTRACK_PROPERTY_USER = @"user";
static NSString *const NS_AUTOTRACK_PROPERTY_UHID = @"uhid";
static NSString *const NS_AUTOTRACK_PROPERTY_DHID = @"dhid";

#pragma mark - 通用属性
static NSString *const NS_AUTOTRACK_PROPERTYS_COMMON = @"commonInfo";
static NSString *const NS_AUTOTRACK_COMMON_PROPERTY_PAGE_TITLE = @"pageTitle";
static NSString *const NS_AUTOTRACK_COMMON_PROPERTY_APPLET_ID = @"appletId";
static NSString *const NS_AUTOTRACK_COMMON_PROPERTY_NET_TYPE = @"netType";
static NSString *const NS_AUTOTRACK_COMMON_PROPERTY_OS = @"os";
static NSString *const NS_AUTOTRACK_COMMON_PROPERTY_PLATFORM = @"platform";
static NSString *const NS_AUTOTRACK_COMMON_PROPERTY_APP_CHANNEL = @"appChannel";
static NSString *const NS_AUTOTRACK_COMMON_PROPERTY_APP_VERSION_NAME = @"appVersionName";
static NSString *const NS_AUTOTRACK_COMMON_PROPERTY_APP_VERSION_CODE = @"appVersionCode";
static NSString *const NS_AUTOTRACK_COMMON_PROPERTY_OS_VERSION = @"osVersion";
static NSString *const NS_AUTOTRACK_COMMON_PROPERTY_NORTH_LAT = @"northLat";
static NSString *const NS_AUTOTRACK_COMMON_PROPERTY_EAST_LNG = @"eastLng";
static NSString *const NS_AUTOTRACK_COMMON_PROPERTY_DEVICE_BRAND = @"deviceBrand";
static NSString *const NS_AUTOTRACK_COMMON_PROPERTY_DEVICE_MODEL = @"deviceModel";
static NSString *const NS_AUTOTRACK_COMMON_PROPERTY_DEVICE_WIDTH_HEIGHT = @"deviceWidthHeight";
static NSString *const NS_AUTOTRACK_COMMON_PROPERTY_OPERATOR = @"operator";
static NSString *const NS_AUTOTRACK_COMMON_PROPERTY_APPID = @"appId";
static NSString *const NS_AUTOTRACK_COMMON_PROPERTY_APPCHANNEL = @"appChannel";

#pragma mark - 常规事件属性
static NSString *const NS_AUTOTRACK_PROPERTIES = @"properties";
static NSString *const NS_AUTOTRACK_PROPERTY_ELEMENT_ID = @"elementId";
static NSString *const NS_AUTOTRACK_PROPERTY_ELEMENT_TYPE = @"elementType";
static NSString *const NS_AUTOTRACK_PROPERTY_ELEMENT_CONTENT = @"elementContent";
static NSString *const NS_AUTOTRACK_PROPERTY_ELEMENT_POSITION = @"elementPosition";
static NSString *const NS_AUTOTRACK_PROPERTY_PAGE_REF = @"pageRef";
static NSString *const NS_AUTOTRACK_MESSAGE_CONTENT = @"msgContent";

static NSString *const NS_AUTOTRACK_PROPERTY_APP_LAUNCH = @"AppLaunch";

#pragma mark 扩展字段
static NSString *const NS_AUTOTRACK_PROPERTYS_BIZEXTRAPROPS = @"bizExtraProps";

void sdp_dispatch_safe_sync(dispatch_queue_t queue, DISPATCH_NOESCAPE dispatch_block_t block);

void sdp_dispatch_main_safe_sync(DISPATCH_NOESCAPE dispatch_block_t block);

void sdp_safe_try_catch(DISPATCH_NOESCAPE dispatch_block_t block);

#define NS_AUTOTRACK_TRY_CATCH_BEGIN @try {
#define NS_AUTOTRACK_TRY_CATCH_END   } @catch (NSException *exception) { \
NSArray *arr = [exception callStackSymbols]; \
NSString *callStackSymbols = [NSString stringWithFormat:@"%@", arr]; \
NSString *file = [NSString stringWithCString:strrchr(__FILE__, '/') encoding:NSUTF8StringEncoding]; \
NSString *line = [NSString stringWithFormat:@"%d", __LINE__]; \
NSString *function = [NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]; \
NSDictionary *exceptionInfo = @{ @"name": exception.name ? : @"", \
                                 @"reason": exception.reason ? : @"", \
                                 @"callStackSymbols": callStackSymbols ? : @"", \
                                 @"file": file ? : @"", \
                                 @"line": line ? : @"", \
                                 @"function": function ? : @"" }; \
UIViewController<NSAutoTrackViewControllerProperty> *viewController =  [NSAutoTrackUtils currentViewController];\
NSAnalyticsManager *manager = [NSAnalyticsManager sharedInstance];\
NSMutableDictionary *info = [[NSMutableDictionary alloc] init];\
info[NS_AUTOTRACK_PROPERTY_MESSAGE_TYPE] = NS_AUTOTRACK_MESSAGE_TYPE_EVENTLOG;\
info[NS_AUTOTRACK_PROPERTY_EVENT_TYPE] = NS_AUTOTRACK_PROPERTY_EXCEPTION;\
info[NS_AUTOTRACK_PROPERTY_SESSION_ID] = manager.sessionId;\
info[NS_AUTOTRACK_PROPERTY_TRACK_TIME] = [NSAutoTrackUtils getCurrentTime];\
info[NS_AUTOTRACK_PROPERTY_PAGE_ID] = viewController.sdp_autotrack_page_id;\
info[NS_AUTOTRACK_PROPERTY_PAGE_SESSION] = viewController.sdp_autotrack_page_sessionId;\
NSMutableDictionary *properties = [[NSMutableDictionary alloc]init];\
info[NS_AUTOTRACK_PROPERTIES] = properties;\
properties[NS_AUTOTRACK_PROPERTY_ELEMENT_CONTENT] = exceptionInfo;\
[NSAnalyticsSDK autoTrackWithTrackInfo:info reportPolicy:NSSendRealTime];\
} \

#endif /* NSAutoTrackConstants_h */
