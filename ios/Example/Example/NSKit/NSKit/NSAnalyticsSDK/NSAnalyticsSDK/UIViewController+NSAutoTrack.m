//
//  UIViewController+NSAutoTrack.m
//  NSAutoTrack
//
//  Created by Neil on 2020/5/25.
//  Copyright © 2020 Neil. All rights reserved.
//

#import "UIViewController+NSAutoTrack.h"
#import "NSAnalyticsManager.h"
#import "NSAutoTrackConstants.h"
#import "NSAutoTrackUtils.h"

#import <objc/runtime.h>



static const int sdp_autotrack_alertview_elementid_key;

@implementation UIViewController (NSAutoTrack)
- (NSString *)sdp_autotrack_page_id {
    return NSStringFromClass([self class]);
}

- (NSString *)sdp_autotrack_page_title {
    __block NSString *controllerTitle = nil;
    sdp_dispatch_main_safe_sync(^{
        controllerTitle = self.navigationItem.title;
    });
    return controllerTitle ? : @"";
}

- (NSString *)sdp_autotrack_page_sessionId {
    return [NSString stringWithFormat:@"%@_%ld",NSStringFromClass([self class]), self.hash];
}


@end

@implementation UIAlertController (NSAutoTrack)


- (NSString *)sdp_autotrack_elementId {
    NSString *elementId = objc_getAssociatedObject(self, &sdp_autotrack_alertview_elementid_key);
    if (elementId == nil) {
        elementId = @"AlertView";
    }
    return elementId;
}
- (void)setSdp_autotrack_elementId:(NSString *)sdp_autotrack_elementId {
    objc_setAssociatedObject(self, &sdp_autotrack_alertview_elementid_key, sdp_autotrack_elementId, OBJC_ASSOCIATION_COPY);
}

- (UIViewController<NSAutoTrackViewControllerProperty> *)sdp_autotrack_viewController {
    return [NSAutoTrackUtils currentViewController];
}

- (NSString *)sdp_autotrack_elementType {
    return NSStringFromClass([self class]);
}

- (NSString *)sdp_autotrack_elementContent {
    NSString *actionContent = @"";
    for (UIAlertAction<NSAutoTrackUIAlertActionProperty> *action in self.actions) {
        actionContent = [actionContent stringByAppendingFormat:@",%@", action.sdp_autotrack_elementContent];
    }
    NSString *content =  [NSString stringWithFormat:@"[%@<%@,%@%@>]", NSStringFromClass([self class]), self.title, self.message, actionContent];
    return content;
}

@end

@implementation UIAlertAction (NSAutoTrack)

- (NSString *)sdp_autotrack_elementType {
    return NSStringFromClass([self class]);
}

- (NSString *)sdp_autotrack_elementContent {
    return [NSString stringWithFormat:@"[%@<%@>]", NSStringFromClass([self class]), self.title];
}

@end
