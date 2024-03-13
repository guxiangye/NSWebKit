//
//  NSAutoTrackUtils.m
//  NSAutoTrack
//
//  Created by Neil on 2020/5/22.
//  Copyright © 2020 Neil. All rights reserved.
//

#import "NSAutoTrackUtils.h"
#import "NSAutoTrackConstants.h"
#import "NSAnalyticsManager.h"
#import "NSAnalyticsReachability.h"
#import "NSAnalyticsExtraPropsProtocol.h"
#import <sys/utsname.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
@implementation NSAutoTrackUtils
#pragma mark - 判断对象是否为空
+ (BOOL)isNull:(id)obj {
    if ([obj isKindOfClass:NSNull.class] || obj == nil) {
        return YES;
    }
    return NO;
}

#pragma mark - 获取当前控制器
+ (UIViewController<NSAutoTrackViewControllerProperty> *)currentViewController {
    __block UIViewController<NSAutoTrackViewControllerProperty> *currentViewController = nil;
    void (^ block)(void) = ^{
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        currentViewController = (UIViewController<NSAutoTrackViewControllerProperty> *)[NSAutoTrackUtils getCurrentVCFrom:rootViewController];
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
+ (NSString *)getPageRef:(UIViewController<NSAutoTrackViewControllerProperty> *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = (UIViewController<NSAutoTrackViewControllerProperty> *)[(UINavigationController *)vc topViewController];
    }
    UINavigationController *nav = vc.navigationController;
    if (nav) {
        NSInteger index = [nav.viewControllers indexOfObject:vc];
        if (index != NSNotFound && index > 0) {
            vc = nav.viewControllers[index - 1];
            return vc.sdp_autotrack_page_sessionId;
        }
    } else {
        UIViewController<NSAutoTrackViewControllerProperty> *currentVC = [NSAutoTrackUtils currentViewController];
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
+ (nullable NSMutableDictionary<NSString *, NSString *> *)trackInfoWithAutoTrackObject:(id<NSAutoTrackViewProperty>)object eventType:(NSAutoTrackEventType)eventType {
    if (![object conformsToProtocol:@protocol(NSAutoTrackViewProperty)]) {
        return nil;
    }
    UIViewController<NSAutoTrackViewControllerProperty> *viewController =  object.sdp_autotrack_viewController;

    if (viewController.sdp_autotrack_isIgnored) {
        return nil;
    }
    NSAnalyticsManager *manager = [NSAnalyticsManager sharedInstance];

    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    UIView<NSAutoTrackViewProperty> *view = (UIView<NSAutoTrackViewProperty> *)object;
    info[NS_AUTOTRACK_PROPERTY_MESSAGE_TYPE] = NS_AUTOTRACK_MESSAGE_TYPE_EVENTLOG;
    info[NS_AUTOTRACK_PROPERTY_EVENT_TYPE] = NSAutoTrackEventTypeStringMap[eventType];
    info[NS_AUTOTRACK_PROPERTY_SESSION_ID] = manager.sessionId;
    info[NS_AUTOTRACK_PROPERTY_TRACK_TIME] = [NSAutoTrackUtils getCurrentTime];
    info[NS_AUTOTRACK_PROPERTY_PAGE_ID] = viewController.sdp_autotrack_page_id;
    info[NS_AUTOTRACK_PROPERTY_PAGE_SESSION] = viewController.sdp_autotrack_page_sessionId;
    
    
    info[NS_AUTOTRACK_COMMON_PROPERTY_APPID] = manager.appid?:@"null";
    
    NSAnalyticsManager *singleton = [NSAnalyticsManager sharedInstance];
    if (singleton.fetchCommonInfoBlock) {
        NSDictionary *commonInfo = singleton.fetchCommonInfoBlock();
        info[NS_AUTOTRACK_PROPERTY_UHID] = commonInfo[@"uhid"]?:@"null";
        info[NS_AUTOTRACK_PROPERTY_DHID] = commonInfo[@"dhid"]?:@"null";
    }

    
   
    
    //properties 控件信息
    NSMutableDictionary *properties = [[NSMutableDictionary alloc]init];
    info[NS_AUTOTRACK_PROPERTIES] = properties;
    if (view.sdp_autotrack_elementId) {
        properties[NS_AUTOTRACK_PROPERTY_ELEMENT_ID] = view.sdp_autotrack_elementId;
    }
    properties[NS_AUTOTRACK_PROPERTY_ELEMENT_TYPE] = view.sdp_autotrack_elementType;
    properties[NS_AUTOTRACK_PROPERTY_ELEMENT_CONTENT] = view.sdp_autotrack_elementContent;
    if (view.sdp_autotrack_element_position) {
        properties[NS_AUTOTRACK_PROPERTY_ELEMENT_POSITION] = view.sdp_autotrack_element_position;
    }
    properties[NS_AUTOTRACK_PROPERTY_PAGE_REF] = [NSAutoTrackUtils getPageRef:viewController];
    //扩展信息
    if (viewController.extraProps) {
        properties[NS_AUTOTRACK_PROPERTYS_BIZEXTRAPROPS] = viewController.extraProps;
    }

    return info;
}

#pragma mark - 获取弹出框的打点属性
+ (NSDictionary<NSString *, NSString *> *)trackInfoWithAlertController:(UIAlertController <NSAutoTrackViewProperty> *)alertViewController eventType:(NSAutoTrackEventType)eventType {
    if (alertViewController.sdp_autotrack_elementId == nil) {
        return nil;
    }
    UIViewController<NSAutoTrackViewControllerProperty> *viewController = alertViewController.sdp_autotrack_viewController;
    if (![viewController conformsToProtocol:@protocol(NSAutoTrackViewControllerProperty)]) {
        return nil;
    }
    NSAnalyticsManager *manager = [NSAnalyticsManager sharedInstance];

    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    info[NS_AUTOTRACK_PROPERTY_EVENT_TYPE] = NSAutoTrackEventTypeStringMap[eventType];
    info[NS_AUTOTRACK_PROPERTY_SESSION_ID] = manager.sessionId;
    info[NS_AUTOTRACK_PROPERTY_TRACK_TIME] = [NSAutoTrackUtils getCurrentTime];
    info[NS_AUTOTRACK_PROPERTY_PAGE_ID] = viewController.sdp_autotrack_page_id;
    info[NS_AUTOTRACK_PROPERTY_PAGE_SESSION] = viewController.sdp_autotrack_page_sessionId;
    //properties 控件信息
    NSMutableDictionary *properties = [[NSMutableDictionary alloc]init];
    info[NS_AUTOTRACK_PROPERTIES] = properties;

    properties[NS_AUTOTRACK_PROPERTY_ELEMENT_ID] = alertViewController.sdp_autotrack_elementId;
    properties[NS_AUTOTRACK_PROPERTY_ELEMENT_TYPE] = alertViewController.sdp_autotrack_elementType;
    properties[NS_AUTOTRACK_PROPERTY_ELEMENT_CONTENT] = alertViewController.sdp_autotrack_elementContent;

    properties[NS_AUTOTRACK_PROPERTY_MESSAGE_TYPE] = NS_AUTOTRACK_MESSAGE_TYPE_EVENTLOG;
    return info;
}

#pragma mark - 获取弹出框的按钮点击的打点属性
+ (NSDictionary<NSString *, NSString *> *)trackInfoWithAlertController:(UIAlertController <NSAutoTrackViewProperty> *)alertViewController action:(UIAlertAction<NSAutoTrackUIAlertActionProperty> *)action {
    if (alertViewController.sdp_autotrack_elementId == nil) {
        return nil;
    }
    UIViewController<NSAutoTrackViewControllerProperty> *viewController = alertViewController.sdp_autotrack_viewController;
    if (![viewController conformsToProtocol:@protocol(NSAutoTrackViewControllerProperty)]) {
        return nil;
    }
    NSAnalyticsManager *manager = [NSAnalyticsManager sharedInstance];

    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    info[NS_AUTOTRACK_PROPERTY_MESSAGE_TYPE] = NS_AUTOTRACK_MESSAGE_TYPE_EVENTLOG;
    info[NS_AUTOTRACK_PROPERTY_EVENT_TYPE] = NS_AUTOTRACK_EVENT_TYPE_CONTROLCLICK;
    info[NS_AUTOTRACK_PROPERTY_SESSION_ID] = manager.sessionId;
    info[NS_AUTOTRACK_PROPERTY_TRACK_TIME] = [NSAutoTrackUtils getCurrentTime];
    info[NS_AUTOTRACK_PROPERTY_PAGE_ID] = viewController.sdp_autotrack_page_id;
    info[NS_AUTOTRACK_PROPERTY_PAGE_SESSION] = viewController.sdp_autotrack_page_sessionId;
    //properties 控件信息
    NSMutableDictionary *properties = [[NSMutableDictionary alloc]init];
    info[NS_AUTOTRACK_PROPERTIES] = properties;

    properties[NS_AUTOTRACK_PROPERTY_ELEMENT_ID] = alertViewController.sdp_autotrack_elementId;
    properties[NS_AUTOTRACK_PROPERTY_ELEMENT_TYPE] = action.sdp_autotrack_elementType;
    properties[NS_AUTOTRACK_PROPERTY_ELEMENT_CONTENT] = action.sdp_autotrack_elementContent;

    return info;
}

#pragma mark - 获取通用信息
+ (NSDictionary<NSString *, NSString *> *)commonInfoProperties {
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    NSAnalyticsManager *singleton = [NSAnalyticsManager sharedInstance];
    if (singleton.fetchCommonInfoBlock) {
        NSDictionary *commonInfo = singleton.fetchCommonInfoBlock();
        [properties addEntriesFromDictionary:commonInfo];
    }

    NSAnalyticsManager *manager = [NSAnalyticsManager sharedInstance];
    properties[NS_AUTOTRACK_COMMON_PROPERTY_APPID] = manager.appid;

    properties[NS_AUTOTRACK_COMMON_PROPERTY_NET_TYPE] = [UIDevice sdp_analytics_getNetworkType] ? : @"";
    properties[NS_AUTOTRACK_COMMON_PROPERTY_OS] = @"ios";
    properties[NS_AUTOTRACK_COMMON_PROPERTY_PLATFORM] = @"ios";
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    properties[NS_AUTOTRACK_COMMON_PROPERTY_OS_VERSION] = systemVersion;
    properties[NS_AUTOTRACK_COMMON_PROPERTY_DEVICE_BRAND] = @"Apple";
    properties[NS_AUTOTRACK_COMMON_PROPERTY_DEVICE_MODEL] = [UIDevice sdp_analytics_getDeviceModel];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    properties[NS_AUTOTRACK_COMMON_PROPERTY_DEVICE_WIDTH_HEIGHT] = [NSString stringWithFormat:@"%.2f*%.2f", screenSize.width, screenSize.height];
    properties[NS_AUTOTRACK_COMMON_PROPERTY_APP_VERSION_CODE] = [UIDevice sdp_analytics_getAppVersion];
    properties[NS_AUTOTRACK_COMMON_PROPERTY_APP_VERSION_NAME] = [UIDevice sdp_analytics_getAppName];
    properties[NS_AUTOTRACK_COMMON_PROPERTY_OPERATOR] = [UIDevice sdp_analytics_getOperatorInfomation];
    properties[NS_AUTOTRACK_COMMON_PROPERTY_APP_CHANNEL] = @"APPSTORE";
    return properties;
}

#pragma mark - 获取APP的启动上下文
+ (NSDictionary<NSString *, NSString *> *)trackInfoWithAppLaunchContext {
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    NSAnalyticsManager *manager = [NSAnalyticsManager sharedInstance];
    properties[NS_AUTOTRACK_PROPERTY_SESSION_ID] = manager.sessionId;
    properties[NS_AUTOTRACK_PROPERTY_EVENT_TYPE] = NS_AUTOTRACK_PROPERTY_APP_LAUNCH;
    properties[NS_AUTOTRACK_PROPERTY_TRACK_TIME] = [NSAutoTrackUtils getCurrentTime];
    properties[NS_AUTOTRACK_PROPERTY_MESSAGE_TYPE] = NS_AUTOTRACK_MESSAGE_TYPE_CONTEXTLOG;
    //通用信息
    properties[NS_AUTOTRACK_PROPERTYS_COMMON] = [NSAutoTrackUtils commonInfoProperties];
    
    return [properties copy];
}

#pragma mark - 获取控制器的打点属性
+ (NSDictionary<NSString *, NSString *> *)trackInfoWithViewController:(UIViewController<NSAutoTrackViewControllerProperty> *)viewController
                                                            eventType:(NSAutoTrackEventType)eventType {
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    NSAnalyticsManager *manager = [NSAnalyticsManager sharedInstance];
    properties[NS_AUTOTRACK_PROPERTY_EVENT_TYPE] = NSAutoTrackEventTypeStringMap[eventType];
    properties[NS_AUTOTRACK_PROPERTY_PAGE_ID] = viewController.sdp_autotrack_page_id;
    properties[NS_AUTOTRACK_PROPERTY_SESSION_ID] = manager.sessionId;
    properties[NS_AUTOTRACK_PROPERTY_PAGE_SESSION] = viewController.sdp_autotrack_page_sessionId;
    properties[NS_AUTOTRACK_PROPERTY_TRACK_TIME] = [NSAutoTrackUtils getCurrentTime];
    properties[NS_AUTOTRACK_PROPERTY_MESSAGE_TYPE] = NS_AUTOTRACK_MESSAGE_TYPE_EVENTLOG;
    return [properties copy];
}

@end

@implementation UIDevice (NSAnalytics)
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
    NSAnalyticsReachability *reachability = [NSAnalyticsReachability reachability];
    switch (reachability.status) {
        case NSAnalyticsReachabilityStatusNone:
            network = @"none";
            break;
        case NSAnalyticsReachabilityStatusWiFi:
            network = @"wifi";
            break;
        case NSAnalyticsReachabilityStatusWWAN: {
            switch (reachability.wwanStatus) {
                case NSAnalyticsReachabilityWWANStatusNone:
                    network = @"notwwan";
                    break;
                case NSAnalyticsReachabilityWWANStatus2G:
                    network = @"2G";
                    break;
                case NSAnalyticsReachabilityWWANStatus3G:
                    network = @"3G";
                    break;
                case NSAnalyticsReachabilityWWANStatus4G:
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
