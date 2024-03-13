//
//  NSObject+NSAutoTrackIsIgnored.h
//  NSWalletSDK
//
//  Created by Neil on 2020/6/16.
//

#import <Foundation/Foundation.h>
#import "NSAutoTrackConstants.h"
#import "NSAutoTrackProtocol.h"
#import "NSAnalyticsSDK.h"
NS_ASSUME_NONNULL_BEGIN

/// 是否忽略打点
@protocol NSAutoTrackElementIsIgnoredProtocol <NSAutoTrackIsIgnoredProtocol>
- (BOOL)sdp_autotrack_isIgnored:(NSAutoTrackEventType)eventType reportPolicy:(NSReportPolicy *)reportPolicy;

@end

@interface UIViewController (NSAutoTrack)<NSAutoTrackElementIsIgnoredProtocol>

@end

@interface UIAlertController (NSAutoTrack)<NSAutoTrackElementIsIgnoredProtocol>
@end

@interface UIView (NSAutoTrack) <NSAutoTrackElementIsIgnoredProtocol>
@end

NS_ASSUME_NONNULL_END
