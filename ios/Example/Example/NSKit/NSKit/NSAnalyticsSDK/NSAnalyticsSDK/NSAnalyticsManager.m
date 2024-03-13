//
//  NSAnalyticsManager.m
//  NSAutoTrack
//
//  Created by Neil on 2020/5/25.
//  Copyright © 2020 Neil. All rights reserved.
//

#import "NSAnalyticsManager.h"
#import "NSAnalyticsReachability.h"
#import <UIKit/UIKit.h>
#import "NSAutoTrackUtils.h"
#import "NSReportManager.h"

@interface NSAnalyticsManager ()

@property (nonatomic,strong)NSAnalyticsReachability *reachability;

@end

@implementation NSAnalyticsManager
+ (NSAnalyticsManager *)sharedInstance {
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
    NSAnalyticsManager *manager = [NSAnalyticsManager sharedInstance];
    NSString *sessionStr = [NSString stringWithFormat:@"%@_%ld",[NSAutoTrackUtils getCurrentTime],[NSProcessInfo processInfo].systemUptime];
    manager.sessionId = sessionStr;
}

#pragma mark - 监听网络
- (void)monitorNetwork
{
    NSAnalyticsReachability *reachability = [NSAnalyticsReachability reachability];
    reachability.notifyBlock = ^(NSAnalyticsReachability *reachability){
        [[NSReportManager sharedInstance] dispatch:0];
        [[NSReportManager sharedInstance] dispatch:1];
        [[NSReportManager sharedInstance] dispatch:2];
        [[NSReportManager sharedInstance] dispatch:3];
    };
    self.reachability = reachability;
}
@end
