//
//  SDPAnalyticsSDK+AutoTrack.m
//  SDPAutoTrack
//
//  Created by 高鹏程 on 2020/6/1.
//  Copyright © 2020 高鹏程. All rights reserved.
//

#import "SDPAnalyticsSDK+AutoTrack.h"
#import "SDPDBManager.h"

@implementation SDPAnalyticsSDK (AutoTrack)
+ (void)autoTrackWithTrackInfo:(NSDictionary *)trackInfo {
    [SDPAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:SDPSendDelay];
}

+ (void)autoTrackWithTrackInfo:(NSDictionary *)trackInfo reportPolicy:(SDPReportPolicy)rp {
    if (trackInfo == nil) {
        return;
    }
    NSLog(@"SDPAutoTrack:%@",trackInfo);
    [[SDPDBManager shareDataManager] addGatherInfo:trackInfo withPriority:rp];
}

@end
