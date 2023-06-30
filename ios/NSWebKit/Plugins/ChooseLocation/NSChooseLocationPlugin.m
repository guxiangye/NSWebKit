//
//  NSChooseLocationPlugin.m
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//

#import "NSChooseLocationPlugin.h"
#import "LBXPermissionLocation.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import "NSObject+YYModel.h"
#import "NSChooseLocationPlugin.h"
#import "NSPickLocationViewController.h"

@interface NSChooseLocationPlugin ()<AMapLocationManagerDelegate>

@property (nonatomic, strong) AMapLocationManager *locationManager;

@end

@implementation NSChooseLocationPlugin

#pragma mark - 获取定位
- (void)getLocationInfo:(CDVInvokedUrlCommand *)command {
    [LBXPermissionLocation authorizeWithCompletion:^(BOOL granted, BOOL firstTime) {
        if (granted) {
            if (self.locationManager == nil) {
                self.locationManager = [[AMapLocationManager alloc]init];
                self.locationManager.delegate = self;
                self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            }

            [self.locationManager requestLocationWithReGeocode:YES
                                               completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
                if (regeocode) {
                    NSMutableDictionary *result = @{ @"formattedAddress": regeocode.formattedAddress ? : @"",
                                                     @"country": regeocode.country ? : @"",
                                                     @"province": regeocode.province ? : @"",
                                                     @"city": regeocode.city ? : @"",
                                                     @"district": regeocode.district ? : @"",
                                                     @"street": regeocode.street ? : @"",
                                                     @"number": regeocode.number ? : @"",
                                                     @"latitude": @(location.coordinate.latitude),
                                                     @"longitude": @(location.coordinate.longitude), }.mutableCopy;
                    result[@"errCode"] = @0;
                    CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsDictionary:result];
                    dispatch_async(dispatch_get_main_queue(), ^() {
                                       [self.commandDelegate sendPluginResult:plugResult
                                                                   callbackId:command.callbackId];
                                   });
                } else {
                    CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsDictionary:@{ @"errCode": @-2, @"errorMsg": error.description }];
                    dispatch_async(dispatch_get_main_queue(), ^() {
                                       [self.commandDelegate sendPluginResult:plugResult
                                                                   callbackId:command.callbackId];
                                   });
                }
            }];
        } else {
            CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                        messageAsDictionary:@{ @"errCode": @-1, @"errorMsg": @"没有定位权限" }];
            dispatch_async(dispatch_get_main_queue(), ^() {
                               [self.commandDelegate sendPluginResult:plugResult
                                                           callbackId:command.callbackId];
                           });
        }
    }];
}

#pragma mark - 获取定位
- (void)chooseLocation:(CDVInvokedUrlCommand *)command {
    NSString *types = nil;
    if([command.arguments.firstObject isKindOfClass:[NSDictionary class]]){
        types = command.arguments.firstObject[@"types"];
    }
    
    
    [LBXPermissionLocation authorizeWithCompletion:^(BOOL granted, BOOL firstTime) {
        if (granted) {
            NSPickLocationViewController *pickVC = [NSPickLocationViewController new];
            pickVC.searchTypes = types;
            pickVC.completionBlock = ^(NSDictionary *_Nonnull info) {
                CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                            messageAsDictionary:info];
                dispatch_async(dispatch_get_main_queue(), ^() {
                                   [self.commandDelegate sendPluginResult:plugResult
                                                               callbackId:command.callbackId];
                               });
            };

            pickVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self.viewController presentViewController:pickVC
                                              animated:YES
                                            completion:nil];
        } else {
            CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                        messageAsDictionary:@{ @"errCode": @-1, @"errorMsg": @"没有定位权限" }];
            dispatch_async(dispatch_get_main_queue(), ^() {
                               [self.commandDelegate sendPluginResult:plugResult
                                                           callbackId:command.callbackId];
                           });
        }
    }];
}

#pragma mark - AMapLocationManager Delegate

- (void)amapLocationManager:(AMapLocationManager *)manager doRequireLocationAuth:(CLLocationManager *)locationManager {
    [locationManager requestAlwaysAuthorization];
}

@end
