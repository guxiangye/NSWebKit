//
//  NSLocationPlugin.m
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//

#import "NSLocationPlugin.h"
#import "LBXPermissionLocation.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import "NSObject+YYModel.h"

@interface NSLocationPlugin ()<AMapLocationManagerDelegate>

@property (nonatomic, strong) AMapLocationManager *locationManager;

@end

@implementation NSLocationPlugin

- (id)init
{
    self = [super init];
    if (self) {
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

#pragma mark - 获取定位
- (void)getLocationInfo:(CDVInvokedUrlCommand *)command {
    [LBXPermissionLocation authorizeWithCompletion:^(BOOL granted, BOOL firstTime) {
        if (granted) {
            if (self.locationManager == nil) {
                self.locationManager = [[AMapLocationManager alloc]init];
                self.locationManager.delegate = self;
                self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            }
            [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
                if (regeocode) {
                    NSMutableDictionary *result = @{ @"formattedAddress": regeocode.formattedAddress ? : @"",
                                                     @"country": regeocode.country ? : @"",
                                                     @"province": regeocode.province ? : @"",
                                                     @"city": regeocode.city ? : @"",
                                                     @"district": regeocode.district ? : @"",
                                                     @"street": regeocode.street ? : @"",
                                                     @"number": regeocode.number ? : @"",
                                                     @"latitude": @(location.coordinate.latitude),
                                                     @"longitude": @(location.coordinate.longitude),}.mutableCopy;
                    result[@"errCode"] = @0;
                    CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
                    dispatch_async(dispatch_get_main_queue(), ^() {
                                       [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
                                   });
                } else {
                    CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{ @"errCode": @-2, @"errorMsg": error.description }];
                    dispatch_async(dispatch_get_main_queue(), ^() {
                                       [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
                                   });
                }
            }];
        } else {
            CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{ @"errCode": @-1, @"errorMsg": @"没有定位权限" }];
            dispatch_async(dispatch_get_main_queue(), ^() {
                               [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
                           });
        }
    }];
}

#pragma mark - AMapLocationManager Delegate
- (void)amapLocationManager:(AMapLocationManager *)manager doRequireLocationAuth:(CLLocationManager *)locationManager {
    [locationManager requestAlwaysAuthorization];
}

@end
