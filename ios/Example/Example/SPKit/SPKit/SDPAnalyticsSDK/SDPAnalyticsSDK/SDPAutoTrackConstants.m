//
//  SDPAutoTrackConstants.m
//  SDPAutoTrack
//
//  Created by 高鹏程 on 2020/5/25.
//  Copyright © 2020 高鹏程. All rights reserved.
//

#import "SDPAutoTrackConstants.h"
#import "SDPAnalyticsSDK.h"
void sdp_dispatch_safe_sync(dispatch_queue_t queue, DISPATCH_NOESCAPE dispatch_block_t block)
{
    if ((dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)) == dispatch_queue_get_label(queue)) {
        block();
    } else {
        dispatch_sync(queue, block);
    }
}

void sdp_dispatch_main_safe_sync(DISPATCH_NOESCAPE dispatch_block_t block)
{
    sdp_dispatch_safe_sync(dispatch_get_main_queue(), block);
}

void sdp_safe_try_catch(DISPATCH_NOESCAPE dispatch_block_t block)
{
    @try {
        block();
    } @catch (NSException *exception) {
        NSArray *arr = [exception callStackSymbols];
        NSString *callStackSymbols = [NSString stringWithFormat:@"%@", arr];
        NSString *file = [NSString stringWithCString:strrchr(__FILE__, '/') encoding:NSUTF8StringEncoding];
        NSString *line = [NSString stringWithFormat:@"%d", __LINE__];
        NSString *function = [NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding];

        [SDPAnalyticsSDK event:@"AutoTrackException"
                    properties:@{ @"name": exception.name ? : @"",
                                  @"reason": exception.reason ? : @"",
                                  @"callStackSymbols": callStackSymbols ? : @"",
                                  @"file": file ? : @"",
                                  @"line": line ? : @"",
                                  @"function": function ? : @"" }
                  reportPolicy:SDPSendRealTime];
    }
}
