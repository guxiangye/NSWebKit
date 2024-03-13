//
//  SDPAnalyticsManager.m
//  SDPAutoTrack
//
//  Created by 高鹏程 on 2020/5/25.
//  Copyright © 2020 高鹏程. All rights reserved.
//

#import "SDPAnalyticsManager.h"
#import "SDPAnalyticsReachability.h"
#import <UIKit/UIKit.h>
#import "SDPAutoTrackUtils.h"
#import "SDPReportManager.h"

@interface SDPAnalyticsManager ()

@property (nonatomic,strong)SDPAnalyticsReachability *reachability;

@end

@implementation SDPAnalyticsManager
+ (SDPAnalyticsManager *)sharedInstance {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        //注册监听通知
        [_instance monitorNetwork];
    });
    return _instance;
}

- (Class)trackViewControlerClass {
    return _trackViewControlerClass ? : [UIViewController class];
}



+ (void)generateSessionId {
    SDPAnalyticsManager *manager = [SDPAnalyticsManager sharedInstance];
    NSString *sessionStr = [NSString stringWithFormat:@"%@_%ld",[SDPAutoTrackUtils getCurrentTime],[NSProcessInfo processInfo].systemUptime];
    manager.sessionId = sessionStr;
}

#pragma mark - 监听网络
- (void)monitorNetwork
{
    SDPAnalyticsReachability *reachability = [SDPAnalyticsReachability reachability];
    reachability.notifyBlock = ^(SDPAnalyticsReachability *reachability){
        [[SDPReportManager sharedInstance] dispatch:0];
        [[SDPReportManager sharedInstance] dispatch:1];
        [[SDPReportManager sharedInstance] dispatch:2];
        [[SDPReportManager sharedInstance] dispatch:3];
    };
    self.reachability = reachability;
}
@end
