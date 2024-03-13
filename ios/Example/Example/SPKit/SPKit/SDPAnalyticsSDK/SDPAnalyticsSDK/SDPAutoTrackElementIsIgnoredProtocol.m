//
//  NSObject+SDPAutoTrackIsIgnored.m
//  SDPWalletSDK
//
//  Created by 高鹏程 on 2020/6/16.
//

#import "SDPAutoTrackElementIsIgnoredProtocol.h"
#import "UIViewController+SDPAutoTrack.h"
#import "SDPAnalyticsManager.h"
#import "SDPAutoTrackUtils.h"
#import <objc/runtime.h>
#import "UIView+SDPAutoTrack.h"
static const int sdp_autotrack_islgnored_key;

@interface SDPAutoTrackConfig : NSObject
+ (BOOL)sdp_autotrack_isIgnored:(SDPAutoTrackEventType)eventType pageid:(NSString *)pageId elementId:(NSString *)element reportPolicy:(nonnull SDPReportPolicy *)reportPolicy;
@end
@implementation SDPAutoTrackConfig
+ (BOOL)sdp_autotrack_isIgnored:(SDPAutoTrackEventType)eventType pageid:(NSString *)pageId elementId:(NSString *)elementId reportPolicy:(nonnull SDPReportPolicy *)reportPolicy {
    if ([elementId containsString:@"SDPSafeKeyBoard"]) {
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
        SDPReportPolicy _uploadlevel = [subConfig[@"uploadlevel"]integerValue];
        if (![_pageid isEqualToString:@"*"] && ![_pageid isEqualToString:pageId]) {
            continue;
        }
        if (![_elementid isEqualToString:@"*"] &&  ![elementId isEqualToString:_elementid]) {
            continue;
        }

        SDPAutoTrackEventType _eventType = SDPAutoTrackEventTypeFromString(_eventtypestr);
        if (!(_eventType & eventType)) {
            continue;
        }
        *reportPolicy = _uploadlevel;
        return NO;
    }
    return YES;
}

@end

@implementation UIViewController (SDPAutoTrackElementIsIgnoredProtocol)

- (BOOL)sdp_autotrack_isIgnored {
    UIViewController *currentVC = self;
    if ([self isKindOfClass:UINavigationController.class]) {
        UINavigationController *nav = (id)self;
        currentVC = nav.topViewController;
    }
    BOOL isKindTrackViewControlerClass = [currentVC isKindOfClass:[SDPAnalyticsManager sharedInstance].trackViewControlerClass];
    return !isKindTrackViewControlerClass || [objc_getAssociatedObject(self, &sdp_autotrack_islgnored_key) boolValue];
}

- (void)setSdp_autotrack_isIgnored:(BOOL)sdp_autotrack_isIgnored {
    objc_setAssociatedObject(self, &sdp_autotrack_islgnored_key, [NSNumber numberWithBool:sdp_autotrack_isIgnored], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)sdp_autotrack_isIgnored:(SDPAutoTrackEventType)controlType reportPolicy:(nonnull SDPReportPolicy *)reportPolicy {
    if (self.sdp_autotrack_isIgnored) {
        return YES;
    }
    /*
     根据配置 决定是否打点
     VC 使用全打点,所以不需要过滤

     */
    *reportPolicy = SDPSendRealTime;
    return NO;
}

@end

@implementation UIAlertController (SDPAutoTrackElementIsIgnoredProtocol)
- (BOOL)sdp_autotrack_isIgnored {
    UIViewController<SDPAutoTrackIsIgnoredProtocol> *currentVC = [SDPAutoTrackUtils currentViewController];
    if (currentVC.sdp_autotrack_isIgnored) {
        return YES;
    }
    return NO;
}

- (BOOL)sdp_autotrack_isIgnored:(SDPAutoTrackEventType)eventType reportPolicy:(nonnull SDPReportPolicy *)reportPolicy {
    if (self.sdp_autotrack_isIgnored) {
        return YES;
    }
    UIViewController<SDPAutoTrackIsIgnoredProtocol> *currentVC = [SDPAutoTrackUtils currentViewController];
    //根据配置 决定是否打点
    return [SDPAutoTrackConfig sdp_autotrack_isIgnored:eventType pageid:currentVC.sdp_autotrack_page_id elementId:self.sdp_autotrack_elementId reportPolicy:reportPolicy];
}

@end
@implementation UIView (SDPAutoTrackElementIsIgnoredProtocol)

- (BOOL)sdp_autotrack_isIgnored {
    UIViewController *currentVC = self.sdp_autotrack_viewController;

    BOOL isKindTrackViewControlerClass = [currentVC isKindOfClass:[SDPAnalyticsManager sharedInstance].trackViewControlerClass];
    return !isKindTrackViewControlerClass || [objc_getAssociatedObject(self, &sdp_autotrack_islgnored_key) boolValue];
}

- (void)setSdp_autotrack_isIgnored:(BOOL)sdp_autotrack_isIgnored {
    objc_setAssociatedObject(self, &sdp_autotrack_islgnored_key, [NSNumber numberWithBool:sdp_autotrack_isIgnored], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)sdp_autotrack_isIgnored:(SDPAutoTrackEventType)eventType reportPolicy:(nonnull SDPReportPolicy *)reportPolicy {
    if (self.sdp_autotrack_isIgnored) {
        return YES;
    }
    //根据配置 决定是否打点
    return [SDPAutoTrackConfig sdp_autotrack_isIgnored:eventType pageid:self.sdp_autotrack_viewController.sdp_autotrack_page_id elementId:self.sdp_autotrack_elementId reportPolicy:reportPolicy];
}

@end
