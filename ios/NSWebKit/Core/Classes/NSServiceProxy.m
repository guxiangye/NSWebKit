//
//  NSServiceProxy.m
//  NSWebKit
//
//  Created by 相晔谷 on 2023/5/26.
//

#import "NSServiceProxy.h"

@interface NSServiceProxy ()

@property (nonatomic, copy) NSServiceProxyFetchStringCallback fetchAppIdCallback;
@property (nonatomic, copy) NSServiceProxyFetchStringCallback fetchDeviceIdCallback;
@property (nonatomic, copy) NSServiceProxyFetchExtendInfoCallback fetchExtendInfoCallback;

@end

@implementation NSServiceProxy : NSObject

+ (NSServiceProxy *)sharedInstance {
    static id _instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (void)setFetchAppId:(NSServiceProxyFetchStringCallback)fetchAppId fetchDeviceId:(NSServiceProxyFetchStringCallback)fetchDeviceId fetchExtendInfo:(NSServiceProxyFetchExtendInfoCallback)fetchExtendInfo {
    NSServiceProxy *singleton = [NSServiceProxy sharedInstance];

    singleton.fetchAppIdCallback = fetchAppId;
    singleton.fetchDeviceIdCallback = fetchDeviceId;
    singleton.fetchExtendInfoCallback = fetchExtendInfo;
}

+ (NSString *)getAppId {
    NSServiceProxy *singleton = [NSServiceProxy sharedInstance];

    if (singleton.fetchAppIdCallback) {
        return singleton.fetchAppIdCallback();
    }

    return nil;
}

+ (NSString *)getDeviceId {
    NSServiceProxy *singleton = [NSServiceProxy sharedInstance];

    if (singleton.fetchDeviceIdCallback) {
        return singleton.fetchDeviceIdCallback() ? : [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }

    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+ (NSDictionary *)getExtendInfo {
    NSServiceProxy *singleton = [NSServiceProxy sharedInstance];

    if (singleton.fetchExtendInfoCallback) {
        return singleton.fetchExtendInfoCallback();
    }

    return nil;
}

@end
