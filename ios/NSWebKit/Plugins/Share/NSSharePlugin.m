//
//  NSSharePlugin.h
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//

#import "NSSharePlugin.h"
#import "NSObject+YYModel.h"
#import "NSWXManager.h"

@interface NSSharePlugin ()
@end

@implementation NSSharePlugin

#pragma mark - 授权
- (void)sendWXAuthRequest:(CDVInvokedUrlCommand *)command {
    [NSWXManager sendWXAuthRequest:^(int errCode, NSString *_Nonnull code) {
        NSDictionary *result = @{ @"errCode": @(errCode), @"code": code ? : @"" };

        CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
        dispatch_async(dispatch_get_main_queue(), ^() {
                           [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
                       });
    }];
}

#pragma mark - 分享到微信
- (void)shareToWX:(CDVInvokedUrlCommand *)command {
}

#pragma mark - 打开小程序
- (void)launchWXMiniProgram:(CDVInvokedUrlCommand *)command {
    NSLaunchMiniprogramParam *param = [NSLaunchMiniprogramParam modelWithJSON:command.arguments.firstObject];

    [NSWXManager launchWXMiniprogram:param completion:^(int errCode, NSString *_Nonnull extMsg) {
        NSDictionary *result = @{ @"errCode": @(errCode), @"extMsg": extMsg ? : @"" };

        CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
        dispatch_async(dispatch_get_main_queue(), ^() {
                           [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
                       });
    }];
}

#pragma mark - 分享到小程序
- (void)shareToWXMiniProgram:(CDVInvokedUrlCommand *)command {
    NSShareToWXMiniprogramParam *param = [NSShareToWXMiniprogramParam modelWithJSON:command.arguments.firstObject];
    [NSWXManager shareToWXMiniprogram:param completion:^(int errCode) {
        NSDictionary *result = @{ @"errCode": @(errCode)};

        CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
        dispatch_async(dispatch_get_main_queue(), ^() {
                           [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
                       });
    }];
}

@end
