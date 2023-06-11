//
//  NSBasicPlugin.m
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//

#import "NSBasicPlugin.h"
#import <UserNotifications/UserNotifications.h>
#import <WebKit/WebKit.h>
#import "LBXPermission.h"
#import "NSDictionary+YYAdd.h"
#import "NSString+YYAdd.h"
#import "NSWebViewController.h"
#import "UIDevice+YYAdd.h"
#import "UIView+Toast.h"
#import "NSServiceProxy.h"

@interface NSBasicPlugin ()

@end

@implementation NSBasicPlugin

#pragma mark - Toast
- (void)toast:(CDVInvokedUrlCommand *)command {
    NSString *msg = command.arguments.firstObject[@"msg"];

    [self.viewController.view makeToast:msg duration:2 position:[CSToastManager defaultPosition]];

    CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{ @"errCode": @0 }];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
    });
}

#pragma mark - 跳转当前App的系统授权管理⻚
- (void)openAppAuthorizeSetting:(CDVInvokedUrlCommand *)command {
    NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

    [[UIApplication sharedApplication] openURL:appSettings];
    CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{ @"errCode": @0 }];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
    });
}

#pragma mark - 获取当前App相关信息
- (id)getAppInfoSync:(CDVInvokedUrlCommand *)command {
    NSString *appId = [NSServiceProxy getAppId] ?: @"";
    NSString *appVersionName = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ? : @"null";
    NSString *appVersionCode = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    

    NSMutableDictionary *appInfo = @{
        @"errCode": @0, @"appId": appId, @"appVersionName": appVersionName, @"appVersionCode": appVersionCode
    }.mutableCopy;
    NSDictionary *extendInfo = [NSServiceProxy getExtendInfo];
    if (extendInfo) {
        appInfo[@"extendInfo"] = extendInfo;
    }

    return appInfo.copy;
}

#pragma mark - 设置角标
- (void)setBadgeCount:(CDVInvokedUrlCommand *)command {
    int badge = [command.arguments.firstObject[@"count"] intValue];

    [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
    CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{ @"errCode": @0 }];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
    });
}

#pragma mark - 打开新页面
- (void)navigateTo:(CDVInvokedUrlCommand *)command {
    NSDictionary *config = command.arguments.firstObject;

    NSWebViewController *webViewVC = (NSWebViewController *)self.viewController;
    NSWebViewController *newWebViewVC = [NSWebViewController getWebviewControllerWithConfig:config
                                                                    fetchInitialUrlCallBack:webViewVC.fetchInitialUrlCallBack
                                                                     fetchUserAgentCallback:webViewVC.fetchUserAgentCallback
                                                                            startedCallback:webViewVC.startedCallback
                                                                           finishedCallback:webViewVC.finishedCallback
                                                                       receiveTitleCallback:webViewVC.receiveTitleCallback
                                                                   webResourceErrorCallback:webViewVC.webResourceErrorCallback];

    newWebViewVC.injectionJSFiles = webViewVC.injectionJSFiles;

    [webViewVC.navigationController pushViewController:newWebViewVC animated:YES];

    CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{ @"errCode": @0 }];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
    });
}

#pragma mark - 返回上一页
- (void)navigateBack:(CDVInvokedUrlCommand *)command {
    [self.viewController.navigationController popViewControllerAnimated:YES];
    CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{ @"errCode": @0 }];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
    });
}

#pragma mark - 打开系统浏览器
- (void)openExternalBrowser:(CDVInvokedUrlCommand *)command {
    NSString *url = command.arguments.firstObject[@"url"];

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{ @"errCode": @0 }];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
    });
}

#pragma mark - 设置WebView容器⻚面的导航栏主题
- (void)setNavigationBarTheme:(CDVInvokedUrlCommand *)command {
    NSWebViewController *webviewController = (NSWebViewController *)self.viewController;
    NSDictionary *config = command.arguments.firstObject;

    if ([config isKindOfClass:[NSDictionary class]]) {
        [webviewController loadConfig:config];
    }

    CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{ @"errCode": @0 }];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
    });
}

#pragma mark - 获取设备相关信息
- (id)getDeviceInfoSync:(CDVInvokedUrlCommand *)command {
    NSNumber *osType = @2;
    NSString *osVersion = [NSString stringWithFormat:@"%f", [UIDevice systemVersion]];
    NSString *model = [[UIDevice currentDevice]machineModel];
    NSString *brand = @"Apple";
    NSString *deviceId = [NSServiceProxy getDeviceId]?:@"null";
    NSString *imei = @"null";

    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;

    if (@available(iOS 13.0, *)) {
        statusBarHeight = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager.statusBarFrame.size.height;
    }

    return @{
        @"errCode": @0,
        @"osType": osType,
        @"osVersion": osVersion,
        @"model": model,
        @"brand": brand,
        @"deviceId": deviceId,
        @"imei": imei,
        @"statusBarHeight": @(statusBarHeight)
    };
}

#pragma mark - 获取系统剪贴板的内容
- (id)getClipboardDataSync:(CDVInvokedUrlCommand *)command {
    NSDictionary *result = @{
            @"errCode": @0,
            @"data": [[UIPasteboard generalPasteboard]string]
    };

    return result;
}

#pragma mark - 设置系统剪贴板的内容
- (void)setClipboardData:(CDVInvokedUrlCommand *)command {
    NSString *content = [command.arguments.firstObject objectForKey:@"data"];

    [[UIPasteboard generalPasteboard]setString:content];
    CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{ @"errCode": @0 }];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
    });
}

#pragma mark - 打电话
- (void)makePhoneCall:(CDVInvokedUrlCommand *)command {
    NSString *telephoneNumber = [command.arguments.firstObject objectForKey:@"phoneNumber"];
    NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"tel:%@", telephoneNumber];
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:str];

    [application openURL:URL];
    CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{ @"errCode": @0 }];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
    });
}

#pragma mark - 获取推送权限开关状态
- (void)getNotificationSwitchStatus:(CDVInvokedUrlCommand *)command {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *_Nonnull settings) {
            dispatch_async(dispatch_get_main_queue(), ^() {
                if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                    CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsDictionary:@{ @"errCode": @0, @"status": [NSNumber numberWithBool:YES] }];
                    [self.commandDelegate sendPluginResult:plugResult
                                                callbackId:command.callbackId];
                } else {
                    CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsDictionary:@{ @"errCode": @0, @"status": [NSNumber numberWithBool:NO] }];
                    [self.commandDelegate sendPluginResult:plugResult
                                                callbackId:command.callbackId];
                }
            });
        }];
    } else {
        // Fallback on earlier versions
    }
}

#pragma mark - 获取语音播报开关状态
- (void)getVoiceBroadcastSwitchStatus:(CDVInvokedUrlCommand *)command {
    NSString *bundleId =  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    NSString *groupIdentifier = [NSString stringWithFormat:@"group.%@.VocalPush", bundleId];

    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupIdentifier];
    NSURL *fileURL = [groupURL URLByAppendingPathComponent:@"VocalPush.txt"];

    //读取文件
    NSString *nativeStatus = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:nil];

    BOOL status = [nativeStatus boolValue];


    dispatch_async(dispatch_get_main_queue(), ^() {
        CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{ @"errCode": @0, @"status": @(status) }];
        [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
    });
}

#pragma mark - 设置语音播报开关状态
- (void)setVoiceBroadcastSwitchStatus:(CDVInvokedUrlCommand *)command {
    NSString *statusStr = [NSString stringWithFormat:@"%d", [[command.arguments.firstObject objectForKey:@"status"]boolValue]];

    NSString *bundleId =  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    NSString *groupIdentifier = [NSString stringWithFormat:@"group.%@.VocalPush", bundleId];

    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupIdentifier];
    NSURL *fileURL = [groupURL URLByAppendingPathComponent:@"VocalPush.txt"];

    //写入文件
    [statusStr writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:nil];

    //读取文件
    NSString *nativeStatus = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:nil];

    BOOL status = [nativeStatus boolValue];

    dispatch_async(dispatch_get_main_queue(), ^() {
        CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{ @"errCode": @0, @"status": @(status) }];
        [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
    });
}

#pragma mark - 清理webview缓存
- (void)cleanWebviewCache:(CDVInvokedUrlCommand *)command {
    /**
     在磁盘缓存上。
     WKWebsiteDataTypeDiskCache,
     html离线Web应用程序缓存。
     WKWebsiteDataTypeOfflineWebApplicationCache,
     内存缓存。
     WKWebsiteDataTypeMemoryCache,
     */
    NSArray *types = @[WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeOfflineWebApplicationCache, WKWebsiteDataTypeMemoryCache];
    NSSet *websiteDataTypes = [NSSet setWithArray:types];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];

    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes
                                               modifiedSince:dateFrom
                                           completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^() {
                           CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                       messageAsDictionary:@{ @"errCode": @0 }];
                           [self.commandDelegate sendPluginResult:plugResult
                                                       callbackId:command.callbackId];
                       });
    }];
}

@end
