//
//  NSObject+SDPAutoTrackIsIgnored.h
//  SDPWalletSDK
//
//  Created by 高鹏程 on 2020/6/16.
//

#import <Foundation/Foundation.h>
#import "SDPAutoTrackConstants.h"
#import "SDPAutoTrackProtocol.h"
#import "SDPAnalyticsSDK.h"
NS_ASSUME_NONNULL_BEGIN

/// 是否忽略打点
@protocol SDPAutoTrackElementIsIgnoredProtocol <SDPAutoTrackIsIgnoredProtocol>
- (BOOL)sdp_autotrack_isIgnored:(SDPAutoTrackEventType)eventType reportPolicy:(SDPReportPolicy *)reportPolicy;

@end

@interface UIViewController (SDPAutoTrack)<SDPAutoTrackElementIsIgnoredProtocol>

@end

@interface UIAlertController (SDPAutoTrack)<SDPAutoTrackElementIsIgnoredProtocol>
@end

@interface UIView (SDPAutoTrack) <SDPAutoTrackElementIsIgnoredProtocol>
@end

NS_ASSUME_NONNULL_END
