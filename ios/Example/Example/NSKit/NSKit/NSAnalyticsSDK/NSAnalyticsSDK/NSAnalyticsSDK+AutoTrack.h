//
//  NSAnalyticsSDK+AutoTrack.h
//  NSAutoTrack
//
//  Created by Neil on 2020/6/1.
//  Copyright © 2020 Neil. All rights reserved.
//


#import "NSAnalyticsSDK.h"
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSAnalyticsSDK (AutoTrack)
+(void)autoTrackWithTrackInfo:(NSDictionary *)trackInfo;
+(void)autoTrackWithTrackInfo:(NSDictionary *)trackInfo reportPolicy:(NSReportPolicy)rp;
@end



NS_ASSUME_NONNULL_END
