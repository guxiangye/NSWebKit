//
//  NSAnalyticsSDK+AutoTrack.m
//  NSAutoTrack
//
//  Created by Neil on 2020/6/1.
//  Copyright © 2020 Neil. All rights reserved.
//

#import "NSAnalyticsSDK+AutoTrack.h"
#import "NSDBManager.h"

@implementation NSAnalyticsSDK (AutoTrack)
+ (void)autoTrackWithTrackInfo:(NSDictionary *)trackInfo {
    [NSAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:NSSendDelay];
}

+ (void)autoTrackWithTrackInfo:(NSDictionary *)trackInfo reportPolicy:(NSReportPolicy)rp {
    if (trackInfo == nil) {
        return;
    }
    NSLog(@"NSAutoTrack:%@",trackInfo);
    [[NSDBManager shareDataManager] addGatherInfo:trackInfo withPriority:rp];
}

@end
