//
//  SDPAnalyticsSDK+AutoTrack.h
//  SDPAutoTrack
//
//  Created by 高鹏程 on 2020/6/1.
//  Copyright © 2020 高鹏程. All rights reserved.
//


#import "SDPAnalyticsSDK.h"
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface SDPAnalyticsSDK (AutoTrack)
+(void)autoTrackWithTrackInfo:(NSDictionary *)trackInfo;
+(void)autoTrackWithTrackInfo:(NSDictionary *)trackInfo reportPolicy:(SDPReportPolicy)rp;
@end



NS_ASSUME_NONNULL_END
