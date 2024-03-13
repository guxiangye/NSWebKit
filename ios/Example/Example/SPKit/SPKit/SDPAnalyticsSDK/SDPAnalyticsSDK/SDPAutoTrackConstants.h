//
//  SDPAutoTrackConstants.h
//  SDPAutoTrack
//
//  Created by 高鹏程 on 2020/5/25.
//  Copyright © 2020 高鹏程. All rights reserved.
//

#ifndef SDPAutoTrackConstants_h
#define SDPAutoTrackConstants_h
#import <Foundation/Foundation.h>
#import "SDPAnalyticsSDK.h"
/// 事件类别枚举
typedef NS_OPTIONS (NSUInteger, SDPAutoTrackEventType) {
    //注意:修改这个枚举的值,一定要相应修改下面SDPAutoTrackEventTypeStringMap的值
    ///页面显示
    SDPAutoTrackPageAppear            = 0,
    ///页面消失
    SDPAutoTrackPageDisappear         = 1 << 0,
    ///控件点击
    SDPAutoTrackControlClick          = 1 << 1,
    ///控件显示
    SDPAutoTrackControlShow           = 1 << 2,
    ///控件消失
    SDPAutoTrackControlHide           = 1 << 3,
    ///控件获取焦点
    SDPAutoTrackControlOnFocus        = 1 << 4,
    ///控件失去焦点
    SDPAutoTrackControlOnBlur         = 1 << 5,
    ///内容发生改变
    SDPAutoTrackControlContentChanged = 1 << 6,
    ///所有类型
    SDPAutoTrackEventTypeAll          = SDPAutoTrackPageAppear | SDPAutoTrackPageDisappear | SDPAutoTrackControlClick | SDPAutoTrackControlShow | SDPAutoTrackControlHide | SDPAutoTrackControlOnFocus | SDPAutoTrackControlOnBlur | SDPAutoTrackControlContentChanged,
};
#pragma mark - 事件类别
static NSString *const SDP_AUTOTRACK_EVENT_TYPE_PAGEAPPEAR = @"PageAppear";
static NSString *const SDP_AUTOTRACK_EVENT_TYPE_PAGEDISAPPEAR = @"PageDisappear";
static NSString *const SDP_AUTOTRACK_EVENT_TYPE_CONTROLCLICK = @"ControlClick";
static NSString *const SDP_AUTOTRACK_EVENT_TYPE_CONTROLSHOW = @"ControlShow";
static NSString *const SDP_AUTOTRACK_EVENT_TYPE_CONTROLHIDE = @"ControlHide";
static NSString *const SDP_AUTOTRACK_EVENT_TYPE_CONTROLONFOCUS = @"ControlOnFocus";
static NSString *const SDP_AUTOTRACK_EVENT_TYPE_CONTROLONBLUR = @"ControlOnBlur";
static NSString *const SDP_AUTOTRACK_EVENT_TYPE_ControlContentChanged = @"ControlContentChanged";
static NSString *const SDP_AUTOTRACK_EVENT_TYPE_ALL = @"*";
///根据枚举获取对应字符串
static NSString *const SDPAutoTrackEventTypeStringMap[] = {
    [SDPAutoTrackPageAppear] = SDP_AUTOTRACK_EVENT_TYPE_PAGEAPPEAR,
    [SDPAutoTrackPageDisappear] = SDP_AUTOTRACK_EVENT_TYPE_PAGEDISAPPEAR,
    [SDPAutoTrackControlClick] = SDP_AUTOTRACK_EVENT_TYPE_CONTROLCLICK,
    [SDPAutoTrackControlShow] = SDP_AUTOTRACK_EVENT_TYPE_CONTROLSHOW,
    [SDPAutoTrackControlHide] = SDP_AUTOTRACK_EVENT_TYPE_CONTROLHIDE,
    [SDPAutoTrackControlOnFocus] = SDP_AUTOTRACK_EVENT_TYPE_CONTROLONFOCUS,
    [SDPAutoTrackControlOnBlur] = SDP_AUTOTRACK_EVENT_TYPE_CONTROLONBLUR,
    [SDPAutoTrackControlContentChanged] = SDP_AUTOTRACK_EVENT_TYPE_ControlContentChanged,
    [SDPAutoTrackEventTypeAll] = SDP_AUTOTRACK_EVENT_TYPE_ALL,
};
static SDPAutoTrackEventType SDPAutoTrackEventTypeFromString(NSString *string)
{
    if ([string isEqualToString:SDP_AUTOTRACK_EVENT_TYPE_PAGEAPPEAR]) return SDPAutoTrackPageAppear;
    if ([string isEqualToString:SDP_AUTOTRACK_EVENT_TYPE_PAGEDISAPPEAR]) return SDPAutoTrackPageDisappear;
    if ([string isEqualToString:SDP_AUTOTRACK_EVENT_TYPE_CONTROLCLICK]) return SDPAutoTrackControlClick;
    if ([string isEqualToString:SDP_AUTOTRACK_EVENT_TYPE_CONTROLSHOW]) return SDPAutoTrackControlShow;
    if ([string isEqualToString:SDP_AUTOTRACK_EVENT_TYPE_CONTROLHIDE]) return SDPAutoTrackControlHide;
    if ([string isEqualToString:SDP_AUTOTRACK_EVENT_TYPE_CONTROLONFOCUS]) return SDPAutoTrackControlOnFocus;
    if ([string isEqualToString:SDP_AUTOTRACK_EVENT_TYPE_CONTROLONBLUR]) return SDPAutoTrackControlOnBlur;
    if ([string isEqualToString:SDP_AUTOTRACK_EVENT_TYPE_ALL]) return SDPAutoTrackEventTypeAll;
    return SDPAutoTrackEventTypeAll;
}

static NSString *const SDP_AUTOTRACK_REPORTPOLICY_RealTime = @"realtime";
static NSString *const SDP_AUTOTRACK_REPORTPOLICY_WIFI = @"wifi";
static NSString *const SDP_AUTOTRACK_REPORTPOLICY_DELAY = @"delay";
static NSString *const SDP_AUTOTRACK_REPORTPOLICY_DISPOSABLE = @"disposable";

static SDPReportPolicy SDPReportPolicyFromString(NSString *string)
{
    if ([string isEqualToString:SDP_AUTOTRACK_REPORTPOLICY_RealTime]) return SDPSendRealTime;
    if ([string isEqualToString:SDP_AUTOTRACK_REPORTPOLICY_WIFI]) return SDPSendCurrentWifi;
    if ([string isEqualToString:SDP_AUTOTRACK_REPORTPOLICY_DELAY]) return SDPSendDelay;
    if ([string isEqualToString:SDP_AUTOTRACK_REPORTPOLICY_DISPOSABLE]) return SDPSendDisposable;
    return SDPSendDisposable;
}

static NSString *const SDP_AUTOTRACK_PROPERTY_EVENT_TYPE = @"eventType";

#pragma mark - 消息类别
static NSString *const SDP_AUTOTRACK_MESSAGE_TYPE_CONTEXTLOG = @"contextLog";
static NSString *const SDP_AUTOTRACK_MESSAGE_TYPE_EVENTLOG = @"eventLog";

static NSString *const SDP_AUTOTRACK_PROPERTY_EXCEPTION = @"Exception";

static NSString *const SDP_AUTOTRACK_PROPERTY_SESSION_ID = @"sessionId";
static NSString *const SDP_AUTOTRACK_PROPERTY_PAGE_ID = @"pageId";

static NSString *const SDP_AUTOTRACK_PROPERTY_PAGE_SESSION = @"pageSession";

//页面来源
static NSString *const SDP_AUTOTRACK_PROPERTY_PAGEDESSION = @"pageDession";

static NSString *const SDP_AUTOTRACK_PROPERTY_TRACK_TIME = @"track_time";
static NSString *const SDP_AUTOTRACK_PROPERTY_MESSAGE_TYPE = @"messageType";
#pragma mark - user
static NSString *const SDP_AUTOTRACK_PROPERTY_USER = @"user";
static NSString *const SDP_AUTOTRACK_PROPERTY_UHID = @"uhid";
static NSString *const SDP_AUTOTRACK_PROPERTY_DHID = @"dhid";

#pragma mark - 通用属性
static NSString *const SDP_AUTOTRACK_PROPERTYS_COMMON = @"commonInfo";
static NSString *const SDP_AUTOTRACK_COMMON_PROPERTY_PAGE_TITLE = @"pageTitle";
static NSString *const SDP_AUTOTRACK_COMMON_PROPERTY_APPLET_ID = @"appletId";
static NSString *const SDP_AUTOTRACK_COMMON_PROPERTY_NET_TYPE = @"netType";
static NSString *const SDP_AUTOTRACK_COMMON_PROPERTY_OS = @"os";
static NSString *const SDP_AUTOTRACK_COMMON_PROPERTY_PLATFORM = @"platform";
static NSString *const SDP_AUTOTRACK_COMMON_PROPERTY_APP_CHANNEL = @"appChannel";
static NSString *const SDP_AUTOTRACK_COMMON_PROPERTY_APP_VERSION_NAME = @"appVersionName";
static NSString *const SDP_AUTOTRACK_COMMON_PROPERTY_APP_VERSION_CODE = @"appVersionCode";
static NSString *const SDP_AUTOTRACK_COMMON_PROPERTY_OS_VERSION = @"osVersion";
static NSString *const SDP_AUTOTRACK_COMMON_PROPERTY_NORTH_LAT = @"northLat";
static NSString *const SDP_AUTOTRACK_COMMON_PROPERTY_EAST_LNG = @"eastLng";
static NSString *const SDP_AUTOTRACK_COMMON_PROPERTY_DEVICE_BRAND = @"deviceBrand";
static NSString *const SDP_AUTOTRACK_COMMON_PROPERTY_DEVICE_MODEL = @"deviceModel";
static NSString *const SDP_AUTOTRACK_COMMON_PROPERTY_DEVICE_WIDTH_HEIGHT = @"deviceWidthHeight";
static NSString *const SDP_AUTOTRACK_COMMON_PROPERTY_OPERATOR = @"operator";
static NSString *const SDP_AUTOTRACK_COMMON_PROPERTY_APPID = @"appId";
static NSString *const SDP_AUTOTRACK_COMMON_PROPERTY_APPCHANNEL = @"appChannel";

#pragma mark - 常规事件属性
static NSString *const SDP_AUTOTRACK_PROPERTIES = @"properties";
static NSString *const SDP_AUTOTRACK_PROPERTY_ELEMENT_ID = @"elementId";
static NSString *const SDP_AUTOTRACK_PROPERTY_ELEMENT_TYPE = @"elementType";
static NSString *const SDP_AUTOTRACK_PROPERTY_ELEMENT_CONTENT = @"elementContent";
static NSString *const SDP_AUTOTRACK_PROPERTY_ELEMENT_POSITION = @"elementPosition";
static NSString *const SDP_AUTOTRACK_PROPERTY_PAGE_REF = @"pageRef";
static NSString *const SDP_AUTOTRACK_MESSAGE_CONTENT = @"msgContent";

static NSString *const SDP_AUTOTRACK_PROPERTY_APP_LAUNCH = @"AppLaunch";

#pragma mark 扩展字段
static NSString *const SDP_AUTOTRACK_PROPERTYS_BIZEXTRAPROPS = @"bizExtraProps";

void sdp_dispatch_safe_sync(dispatch_queue_t queue, DISPATCH_NOESCAPE dispatch_block_t block);

void sdp_dispatch_main_safe_sync(DISPATCH_NOESCAPE dispatch_block_t block);

void sdp_safe_try_catch(DISPATCH_NOESCAPE dispatch_block_t block);

#define SDP_AUTOTRACK_TRY_CATCH_BEGIN @try {
#define SDP_AUTOTRACK_TRY_CATCH_END   } @catch (NSException *exception) { \
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
UIViewController<SDPAutoTrackViewControllerProperty> *viewController =  [SDPAutoTrackUtils currentViewController];\
SDPAnalyticsManager *manager = [SDPAnalyticsManager sharedInstance];\
NSMutableDictionary *info = [[NSMutableDictionary alloc] init];\
info[SDP_AUTOTRACK_PROPERTY_MESSAGE_TYPE] = SDP_AUTOTRACK_MESSAGE_TYPE_EVENTLOG;\
info[SDP_AUTOTRACK_PROPERTY_EVENT_TYPE] = SDP_AUTOTRACK_PROPERTY_EXCEPTION;\
info[SDP_AUTOTRACK_PROPERTY_SESSION_ID] = manager.sessionId;\
info[SDP_AUTOTRACK_PROPERTY_TRACK_TIME] = [SDPAutoTrackUtils getCurrentTime];\
info[SDP_AUTOTRACK_PROPERTY_PAGE_ID] = viewController.sdp_autotrack_page_id;\
info[SDP_AUTOTRACK_PROPERTY_PAGE_SESSION] = viewController.sdp_autotrack_page_sessionId;\
NSMutableDictionary *properties = [[NSMutableDictionary alloc]init];\
info[SDP_AUTOTRACK_PROPERTIES] = properties;\
properties[SDP_AUTOTRACK_PROPERTY_ELEMENT_CONTENT] = exceptionInfo;\
[SDPAnalyticsSDK autoTrackWithTrackInfo:info reportPolicy:SDPSendRealTime];\
} \

#endif /* SDPAutoTrackConstants_h */
