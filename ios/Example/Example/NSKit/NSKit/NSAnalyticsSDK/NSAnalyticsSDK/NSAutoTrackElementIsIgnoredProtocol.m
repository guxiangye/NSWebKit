//
//  NSObject+NSAutoTrackIsIgnored.m
//  NSWalletSDK
//
//  Created by Neil on 2020/6/16.
//

#import "NSAutoTrackElementIsIgnoredProtocol.h"
#import "UIViewController+NSAutoTrack.h"
#import "NSAnalyticsManager.h"
#import "NSAutoTrackUtils.h"
#import <objc/runtime.h>
#import "UIView+NSAutoTrack.h"
static const int sdp_autotrack_islgnored_key;

@interface NSAutoTrackConfig : NSObject
+ (BOOL)sdp_autotrack_isIgnored:(NSAutoTrackEventType)eventType pageid:(NSString *)pageId elementId:(NSString *)element reportPolicy:(nonnull NSReportPolicy *)reportPolicy;
@end
@implementation NSAutoTrackConfig
+ (BOOL)sdp_autotrack_isIgnored:(NSAutoTrackEventType)eventType pageid:(NSString *)pageId elementId:(NSString *)elementId reportPolicy:(nonnull NSReportPolicy *)reportPolicy {
    if ([elementId containsString:@"NSSafeKeyBoard"]) {
        //如果是密码键盘的点击 忽略
        return YES;
    }

    NSArray *config = @[@{ @"eventtype": @"*",
                           @"pageid": @"*",
                           @"elementid": @"*",
                           @"uploadlevel": @"0" }];

    for (NSDictionary *subConfig in config) {
        NSString *_eventtypestr = subConfig[@"eventtype"];
        NSString *_pageid = subConfig[@"pageid"];
        NSString *_elementid = subConfig[@"elementid"];
        NSReportPolicy _uploadlevel = [subConfig[@"uploadlevel"]integerValue];
        if (![_pageid isEqualToString:@"*"] && ![_pageid isEqualToString:pageId]) {
            continue;
        }
        if (![_elementid isEqualToString:@"*"] &&  ![elementId isEqualToString:_elementid]) {
            continue;
        }

        NSAutoTrackEventType _eventType = NSAutoTrackEventTypeFromString(_eventtypestr);
        if (!(_eventType & eventType)) {
            continue;
        }
        *reportPolicy = _uploadlevel;
        return NO;
    }
    return YES;
}

@end

@implementation UIViewController (NSAutoTrackElementIsIgnoredProtocol)

- (BOOL)sdp_autotrack_isIgnored {
    UIViewController *currentVC = self;
    if ([self isKindOfClass:UINavigationController.class]) {
        UINavigationController *nav = (id)self;
        currentVC = nav.topViewController;
    }
    BOOL isKindTrackViewControlerClass = [currentVC isKindOfClass:[NSAnalyticsManager sharedInstance].trackViewControlerClass];
    return !isKindTrackViewControlerClass || [objc_getAssociatedObject(self, &sdp_autotrack_islgnored_key) boolValue];
}

- (void)setSdp_autotrack_isIgnored:(BOOL)sdp_autotrack_isIgnored {
    objc_setAssociatedObject(self, &sdp_autotrack_islgnored_key, [NSNumber numberWithBool:sdp_autotrack_isIgnored], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)sdp_autotrack_isIgnored:(NSAutoTrackEventType)controlType reportPolicy:(nonnull NSReportPolicy *)reportPolicy {
    if (self.sdp_autotrack_isIgnored) {
        return YES;
    }
    /*
     根据配置 决定是否打点
     VC 使用全打点,所以不需要过滤

     */
    *reportPolicy = NSSendRealTime;
    return NO;
}

@end

@implementation UIAlertController (NSAutoTrackElementIsIgnoredProtocol)
- (BOOL)sdp_autotrack_isIgnored {
    UIViewController<NSAutoTrackIsIgnoredProtocol> *currentVC = [NSAutoTrackUtils currentViewController];
    if (currentVC.sdp_autotrack_isIgnored) {
        return YES;
    }
    return NO;
}

- (BOOL)sdp_autotrack_isIgnored:(NSAutoTrackEventType)eventType reportPolicy:(nonnull NSReportPolicy *)reportPolicy {
    if (self.sdp_autotrack_isIgnored) {
        return YES;
    }
    UIViewController<NSAutoTrackIsIgnoredProtocol> *currentVC = [NSAutoTrackUtils currentViewController];
    //根据配置 决定是否打点
    return [NSAutoTrackConfig sdp_autotrack_isIgnored:eventType pageid:currentVC.sdp_autotrack_page_id elementId:self.sdp_autotrack_elementId reportPolicy:reportPolicy];
}

@end
@implementation UIView (NSAutoTrackElementIsIgnoredProtocol)

- (BOOL)sdp_autotrack_isIgnored {
    UIViewController *currentVC = self.sdp_autotrack_viewController;

    BOOL isKindTrackViewControlerClass = [currentVC isKindOfClass:[NSAnalyticsManager sharedInstance].trackViewControlerClass];
    return !isKindTrackViewControlerClass || [objc_getAssociatedObject(self, &sdp_autotrack_islgnored_key) boolValue];
}

- (void)setSdp_autotrack_isIgnored:(BOOL)sdp_autotrack_isIgnored {
    objc_setAssociatedObject(self, &sdp_autotrack_islgnored_key, [NSNumber numberWithBool:sdp_autotrack_isIgnored], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)sdp_autotrack_isIgnored:(NSAutoTrackEventType)eventType reportPolicy:(nonnull NSReportPolicy *)reportPolicy {
    if (self.sdp_autotrack_isIgnored) {
        return YES;
    }
    //根据配置 决定是否打点
    return [NSAutoTrackConfig sdp_autotrack_isIgnored:eventType pageid:self.sdp_autotrack_viewController.sdp_autotrack_page_id elementId:self.sdp_autotrack_elementId reportPolicy:reportPolicy];
}

@end
