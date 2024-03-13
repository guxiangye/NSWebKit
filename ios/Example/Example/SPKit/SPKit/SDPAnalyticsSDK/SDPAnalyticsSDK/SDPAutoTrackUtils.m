//
//  SDPAutoTrackUtils.m
//  SDPAutoTrack
//
//  Created by 高鹏程 on 2020/5/22.
//  Copyright © 2020 高鹏程. All rights reserved.
//

#import "SDPAutoTrackUtils.h"
#import "SDPAutoTrackConstants.h"
#import "SDPAnalyticsManager.h"
#import "SDPAnalyticsReachability.h"
#import "SDPAnalyticsExtraPropsProtocol.h"
#import <sys/utsname.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
@implementation SDPAutoTrackUtils
#pragma mark - 判断对象是否为空
+ (BOOL)isNull:(id)obj {
    if ([obj isKindOfClass:NSNull.class] || obj == nil) {
        return YES;
    }
    return NO;
}

#pragma mark - 获取当前控制器
+ (UIViewController<SDPAutoTrackViewControllerProperty> *)currentViewController {
    __block UIViewController<SDPAutoTrackViewControllerProperty> *currentViewController = nil;
    void (^ block)(void) = ^{
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        currentViewController = (UIViewController<SDPAutoTrackViewControllerProperty> *)[SDPAutoTrackUtils getCurrentVCFrom:rootViewController];
    };
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }

    return currentViewController;
}

+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC {
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        if (![rootVC.presentedViewController isKindOfClass:[UIAlertController class]]) {
            // 视图是被presented出来的
            rootVC = [rootVC presentedViewController];
        }
    }
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]) {
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC topViewController]];
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}

#pragma mark 获取当前时间
+ (NSString *)getCurrentTime {
    NSDate *date = [NSDate date];
    return [NSString stringWithFormat:@"%ld", (NSInteger)(date.timeIntervalSince1970 * 1000)];
}

#pragma mark 获取前一个页面
+ (NSString *)getPageRef:(UIViewController<SDPAutoTrackViewControllerProperty> *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = (UIViewController<SDPAutoTrackViewControllerProperty> *)[(UINavigationController *)vc topViewController];
    }
    UINavigationController *nav = vc.navigationController;
    if (nav) {
        NSInteger index = [nav.viewControllers indexOfObject:vc];
        if (index != NSNotFound && index > 0) {
            vc = nav.viewControllers[index - 1];
            return vc.sdp_autotrack_page_sessionId;
        }
    } else {
        UIViewController<SDPAutoTrackViewControllerProperty> *currentVC = [SDPAutoTrackUtils currentViewController];
        return currentVC.sdp_autotrack_page_sessionId;
    }

    return @"";
}

#pragma mark - 获取元素在当前层级 相同类元素里的位置序号
+ (NSInteger)itemIndexForResponder:(UIResponder *)responder {
    NSString *classString = NSStringFromClass(responder.class);
    NSArray *subResponder = nil;
    if ([responder isKindOfClass:UIView.class]) {
        UIResponder *next = [responder nextResponder];
        if ([next isKindOfClass:UISegmentedControl.class]) {
            // UISegmentedControl 点击之后，subviews 顺序会变化，需要根据坐标排序才能匹配正确
            UISegmentedControl *segmentedControl = (UISegmentedControl *)next;
            NSArray <UIView *> *subViews = segmentedControl.subviews;
            subResponder = [subViews sortedArrayUsingComparator:^NSComparisonResult (UIView *obj1, UIView *obj2) {
                if (obj1.frame.origin.x > obj2.frame.origin.x) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
                }
            }];
        } else if ([next isKindOfClass:UIView.class]) {
            subResponder = [(UIView *)next subviews];
        }
    } else if ([responder isKindOfClass:UIViewController.class]) {
        subResponder = [(UIViewController *)responder parentViewController].childViewControllers;
    }

    NSInteger count = 0;
    NSInteger index = -1;
    for (UIResponder *res in subResponder) {
        if ([classString isEqualToString:NSStringFromClass(res.class)]) {
            count++;
        }
        if (res == responder) {
            index = count - 1;
        }
    }
    return index;
}

#pragma mark - 获取自动埋点 事件的一些属性
+ (nullable NSMutableDictionary<NSString *, NSString *> *)trackInfoWithAutoTrackObject:(id<SDPAutoTrackViewProperty>)object eventType:(SDPAutoTrackEventType)eventType {
    if (![object conformsToProtocol:@protocol(SDPAutoTrackViewProperty)]) {
        return nil;
    }
    UIViewController<SDPAutoTrackViewControllerProperty> *viewController =  object.sdp_autotrack_viewController;

    if (viewController.sdp_autotrack_isIgnored) {
        return nil;
    }
    SDPAnalyticsManager *manager = [SDPAnalyticsManager sharedInstance];

    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    UIView<SDPAutoTrackViewProperty> *view = (UIView<SDPAutoTrackViewProperty> *)object;
    info[SDP_AUTOTRACK_PROPERTY_MESSAGE_TYPE] = SDP_AUTOTRACK_MESSAGE_TYPE_EVENTLOG;
    info[SDP_AUTOTRACK_PROPERTY_EVENT_TYPE] = SDPAutoTrackEventTypeStringMap[eventType];
    info[SDP_AUTOTRACK_PROPERTY_SESSION_ID] = manager.sessionId;
    info[SDP_AUTOTRACK_PROPERTY_TRACK_TIME] = [SDPAutoTrackUtils getCurrentTime];
    info[SDP_AUTOTRACK_PROPERTY_PAGE_ID] = viewController.sdp_autotrack_page_id;
    info[SDP_AUTOTRACK_PROPERTY_PAGE_SESSION] = viewController.sdp_autotrack_page_sessionId;
    
    
    info[SDP_AUTOTRACK_COMMON_PROPERTY_APPID] = manager.appid?:@"null";
    
    SDPAnalyticsManager *singleton = [SDPAnalyticsManager sharedInstance];
    if (singleton.fetchCommonInfoBlock) {
        NSDictionary *commonInfo = singleton.fetchCommonInfoBlock();
        info[SDP_AUTOTRACK_PROPERTY_UHID] = commonInfo[@"uhid"]?:@"null";
        info[SDP_AUTOTRACK_PROPERTY_DHID] = commonInfo[@"dhid"]?:@"null";
    }

    
   
    
    //properties 控件信息
    NSMutableDictionary *properties = [[NSMutableDictionary alloc]init];
    info[SDP_AUTOTRACK_PROPERTIES] = properties;
    if (view.sdp_autotrack_elementId) {
        properties[SDP_AUTOTRACK_PROPERTY_ELEMENT_ID] = view.sdp_autotrack_elementId;
    }
    properties[SDP_AUTOTRACK_PROPERTY_ELEMENT_TYPE] = view.sdp_autotrack_elementType;
    properties[SDP_AUTOTRACK_PROPERTY_ELEMENT_CONTENT] = view.sdp_autotrack_elementContent;
    if (view.sdp_autotrack_element_position) {
        properties[SDP_AUTOTRACK_PROPERTY_ELEMENT_POSITION] = view.sdp_autotrack_element_position;
    }
    properties[SDP_AUTOTRACK_PROPERTY_PAGE_REF] = [SDPAutoTrackUtils getPageRef:viewController];
    //扩展信息
    if (viewController.extraProps) {
        properties[SDP_AUTOTRACK_PROPERTYS_BIZEXTRAPROPS] = viewController.extraProps;
    }

    return info;
}

#pragma mark - 获取弹出框的打点属性
+ (NSDictionary<NSString *, NSString *> *)trackInfoWithAlertController:(UIAlertController <SDPAutoTrackViewProperty> *)alertViewController eventType:(SDPAutoTrackEventType)eventType {
    if (alertViewController.sdp_autotrack_elementId == nil) {
        return nil;
    }
    UIViewController<SDPAutoTrackViewControllerProperty> *viewController = alertViewController.sdp_autotrack_viewController;
    if (![viewController conformsToProtocol:@protocol(SDPAutoTrackViewControllerProperty)]) {
        return nil;
    }
    SDPAnalyticsManager *manager = [SDPAnalyticsManager sharedInstance];

    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    info[SDP_AUTOTRACK_PROPERTY_EVENT_TYPE] = SDPAutoTrackEventTypeStringMap[eventType];
    info[SDP_AUTOTRACK_PROPERTY_SESSION_ID] = manager.sessionId;
    info[SDP_AUTOTRACK_PROPERTY_TRACK_TIME] = [SDPAutoTrackUtils getCurrentTime];
    info[SDP_AUTOTRACK_PROPERTY_PAGE_ID] = viewController.sdp_autotrack_page_id;
    info[SDP_AUTOTRACK_PROPERTY_PAGE_SESSION] = viewController.sdp_autotrack_page_sessionId;
    //properties 控件信息
    NSMutableDictionary *properties = [[NSMutableDictionary alloc]init];
    info[SDP_AUTOTRACK_PROPERTIES] = properties;

    properties[SDP_AUTOTRACK_PROPERTY_ELEMENT_ID] = alertViewController.sdp_autotrack_elementId;
    properties[SDP_AUTOTRACK_PROPERTY_ELEMENT_TYPE] = alertViewController.sdp_autotrack_elementType;
    properties[SDP_AUTOTRACK_PROPERTY_ELEMENT_CONTENT] = alertViewController.sdp_autotrack_elementContent;

    properties[SDP_AUTOTRACK_PROPERTY_MESSAGE_TYPE] = SDP_AUTOTRACK_MESSAGE_TYPE_EVENTLOG;
    return info;
}

#pragma mark - 获取弹出框的按钮点击的打点属性
+ (NSDictionary<NSString *, NSString *> *)trackInfoWithAlertController:(UIAlertController <SDPAutoTrackViewProperty> *)alertViewController action:(UIAlertAction<SDPAutoTrackUIAlertActionProperty> *)action {
    if (alertViewController.sdp_autotrack_elementId == nil) {
        return nil;
    }
    UIViewController<SDPAutoTrackViewControllerProperty> *viewController = alertViewController.sdp_autotrack_viewController;
    if (![viewController conformsToProtocol:@protocol(SDPAutoTrackViewControllerProperty)]) {
        return nil;
    }
    SDPAnalyticsManager *manager = [SDPAnalyticsManager sharedInstance];

    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    info[SDP_AUTOTRACK_PROPERTY_MESSAGE_TYPE] = SDP_AUTOTRACK_MESSAGE_TYPE_EVENTLOG;
    info[SDP_AUTOTRACK_PROPERTY_EVENT_TYPE] = SDP_AUTOTRACK_EVENT_TYPE_CONTROLCLICK;
    info[SDP_AUTOTRACK_PROPERTY_SESSION_ID] = manager.sessionId;
    info[SDP_AUTOTRACK_PROPERTY_TRACK_TIME] = [SDPAutoTrackUtils getCurrentTime];
    info[SDP_AUTOTRACK_PROPERTY_PAGE_ID] = viewController.sdp_autotrack_page_id;
    info[SDP_AUTOTRACK_PROPERTY_PAGE_SESSION] = viewController.sdp_autotrack_page_sessionId;
    //properties 控件信息
    NSMutableDictionary *properties = [[NSMutableDictionary alloc]init];
    info[SDP_AUTOTRACK_PROPERTIES] = properties;

    properties[SDP_AUTOTRACK_PROPERTY_ELEMENT_ID] = alertViewController.sdp_autotrack_elementId;
    properties[SDP_AUTOTRACK_PROPERTY_ELEMENT_TYPE] = action.sdp_autotrack_elementType;
    properties[SDP_AUTOTRACK_PROPERTY_ELEMENT_CONTENT] = action.sdp_autotrack_elementContent;

    return info;
}

#pragma mark - 获取通用信息
+ (NSDictionary<NSString *, NSString *> *)commonInfoProperties {
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    SDPAnalyticsManager *singleton = [SDPAnalyticsManager sharedInstance];
    if (singleton.fetchCommonInfoBlock) {
        NSDictionary *commonInfo = singleton.fetchCommonInfoBlock();
        [properties addEntriesFromDictionary:commonInfo];
    }

    SDPAnalyticsManager *manager = [SDPAnalyticsManager sharedInstance];
    properties[SDP_AUTOTRACK_COMMON_PROPERTY_APPID] = manager.appid;

    properties[SDP_AUTOTRACK_COMMON_PROPERTY_NET_TYPE] = [UIDevice sdp_analytics_getNetworkType] ? : @"";
    properties[SDP_AUTOTRACK_COMMON_PROPERTY_OS] = @"ios";
    properties[SDP_AUTOTRACK_COMMON_PROPERTY_PLATFORM] = @"ios";
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    properties[SDP_AUTOTRACK_COMMON_PROPERTY_OS_VERSION] = systemVersion;
    properties[SDP_AUTOTRACK_COMMON_PROPERTY_DEVICE_BRAND] = @"Apple";
    properties[SDP_AUTOTRACK_COMMON_PROPERTY_DEVICE_MODEL] = [UIDevice sdp_analytics_getDeviceModel];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    properties[SDP_AUTOTRACK_COMMON_PROPERTY_DEVICE_WIDTH_HEIGHT] = [NSString stringWithFormat:@"%.2f*%.2f", screenSize.width, screenSize.height];
    properties[SDP_AUTOTRACK_COMMON_PROPERTY_APP_VERSION_CODE] = [UIDevice sdp_analytics_getAppVersion];
    properties[SDP_AUTOTRACK_COMMON_PROPERTY_APP_VERSION_NAME] = [UIDevice sdp_analytics_getAppName];
    properties[SDP_AUTOTRACK_COMMON_PROPERTY_OPERATOR] = [UIDevice sdp_analytics_getOperatorInfomation];
    properties[SDP_AUTOTRACK_COMMON_PROPERTY_APP_CHANNEL] = @"APPSTORE";
    return properties;
}

#pragma mark - 获取APP的启动上下文
+ (NSDictionary<NSString *, NSString *> *)trackInfoWithAppLaunchContext {
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    SDPAnalyticsManager *manager = [SDPAnalyticsManager sharedInstance];
    properties[SDP_AUTOTRACK_PROPERTY_SESSION_ID] = manager.sessionId;
    properties[SDP_AUTOTRACK_PROPERTY_EVENT_TYPE] = SDP_AUTOTRACK_PROPERTY_APP_LAUNCH;
    properties[SDP_AUTOTRACK_PROPERTY_TRACK_TIME] = [SDPAutoTrackUtils getCurrentTime];
    properties[SDP_AUTOTRACK_PROPERTY_MESSAGE_TYPE] = SDP_AUTOTRACK_MESSAGE_TYPE_CONTEXTLOG;
    //通用信息
    properties[SDP_AUTOTRACK_PROPERTYS_COMMON] = [SDPAutoTrackUtils commonInfoProperties];
    
    return [properties copy];
}

#pragma mark - 获取控制器的打点属性
+ (NSDictionary<NSString *, NSString *> *)trackInfoWithViewController:(UIViewController<SDPAutoTrackViewControllerProperty> *)viewController
                                                            eventType:(SDPAutoTrackEventType)eventType {
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    SDPAnalyticsManager *manager = [SDPAnalyticsManager sharedInstance];
    properties[SDP_AUTOTRACK_PROPERTY_EVENT_TYPE] = SDPAutoTrackEventTypeStringMap[eventType];
    properties[SDP_AUTOTRACK_PROPERTY_PAGE_ID] = viewController.sdp_autotrack_page_id;
    properties[SDP_AUTOTRACK_PROPERTY_SESSION_ID] = manager.sessionId;
    properties[SDP_AUTOTRACK_PROPERTY_PAGE_SESSION] = viewController.sdp_autotrack_page_sessionId;
    properties[SDP_AUTOTRACK_PROPERTY_TRACK_TIME] = [SDPAutoTrackUtils getCurrentTime];
    properties[SDP_AUTOTRACK_PROPERTY_MESSAGE_TYPE] = SDP_AUTOTRACK_MESSAGE_TYPE_EVENTLOG;
    return [properties copy];
}

@end

@implementation UIDevice (SDPAnalytics)
+ (NSString *)sdp_analytics_getAppVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)sdp_analytics_getAppName {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"CFBundleDisplayName"];
}

+ (NSString *)sdp_analytics_getNetworkType {
    //网络信息
    NSString *network = nil;
    SDPAnalyticsReachability *reachability = [SDPAnalyticsReachability reachability];
    switch (reachability.status) {
        case SDPAnalyticsReachabilityStatusNone:
            network = @"none";
            break;
        case SDPAnalyticsReachabilityStatusWiFi:
            network = @"wifi";
            break;
        case SDPAnalyticsReachabilityStatusWWAN: {
            switch (reachability.wwanStatus) {
                case SDPAnalyticsReachabilityWWANStatusNone:
                    network = @"notwwan";
                    break;
                case SDPAnalyticsReachabilityWWANStatus2G:
                    network = @"2G";
                    break;
                case SDPAnalyticsReachabilityWWANStatus3G:
                    network = @"3G";
                    break;
                case SDPAnalyticsReachabilityWWANStatus4G:
                    network = @"4G";
                    break;

                default:
                    network = @"defaultnone";
                    break;
            }
        }
        break;
        default:
            network = @"defaultnone";
            break;
    }
    return network;
}

+ (NSString *)sdp_analytics_getDeviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return deviceString;
}

// 获取运营商信息
+ (NSString *)sdp_analytics_getOperatorInfomation {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    //NSLog(@"info = %@", info);
    CTCarrier *carrier = [info subscriberCellularProvider];
    //NSLog(@"carrier = %@", carrier);
    if (carrier == nil) {
        return @"0";
    }
    NSString *code = [carrier mobileNetworkCode];
    if (code == nil) {
        return @"0";
    }
    if ([code isEqualToString:@"00"] || [code isEqualToString:@"02"] || [code isEqualToString:@"07"]) {
//        移动运营商
        return @"1";
    } else if ([code isEqualToString:@"01"] || [code isEqualToString:@"06"]) {
//        联通运营商
        return @"3";
    } else if ([code isEqualToString:@"03"] || [code isEqualToString:@"05"]) {
//        电信运营商
        return @"2";
    } else if ([code isEqualToString:@"20"]) {
//        铁通运营商
        return @"0";
    }
    return @"0";
}

@end
