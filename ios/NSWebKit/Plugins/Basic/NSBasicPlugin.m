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
#import "NSStorage.h"
#import "NSNativePageProtocol.h"
#import "UIImage+NSWaterMark.h"
#import "UIColor+YYAdd.h"
#import "NSImageURLProtocol.h"

@interface NSBasicPlugin ()
<UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) UIDocumentInteractionController *documentVC;
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

#pragma mark - 存储相关
- (id)setStorageSync:(CDVInvokedUrlCommand *)command {
    if ([command.arguments.firstObject isKindOfClass:[NSDictionary class]]) {
        NSString *key = [command.arguments.firstObject objectForKey:@"key"];
        id data = [command.arguments.firstObject objectForKey:@"data"];
        NSString *groupName = [command.arguments.firstObject objectForKey:@"groupName"];
        NSInteger validSecond = [[command.arguments.firstObject objectForKey:@"validSecond"]integerValue];

        if (key != nil) {
            [NSStorage set:key value:data groupName:groupName validSecond:validSecond];
        }

        return @{
            @"data": @{
                key: data ? : [NSNull null]
            }
        };
    }

    return @{
        @"data": [NSNull null]
    };
}

- (void)setStorage:(CDVInvokedUrlCommand *)command {
    if ([command.arguments.firstObject isKindOfClass:[NSDictionary class]]) {
        NSString *groupName = [command.arguments.firstObject objectForKey:@"groupName"];
        NSString *key = [command.arguments.firstObject objectForKey:@"key"];
        id data = [command.arguments.firstObject objectForKey:@"data"];

        if (key.length > 0) {
            NSInteger validSecond = [[command.arguments.firstObject objectForKey:@"validSecond"]integerValue];

            [NSStorage set:key value:data ? : [NSNull null] groupName:groupName validSecond:validSecond];
            dispatch_async(dispatch_get_main_queue(), ^{
                CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                            messageAsDictionary:@{ @"errCode": @0, @"errorMsg": @"保存成功" }];
                [self.commandDelegate sendPluginResult:plugResult
                                            callbackId:command.callbackId];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                            messageAsDictionary:@{ @"errCode": @-1, @"errorMsg": @"key 不能为空" }];
                [self.commandDelegate sendPluginResult:plugResult
                                            callbackId:command.callbackId];
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                        messageAsDictionary:@{ @"errCode": @-2, @"errorMsg": @"参数不正确" }];
            [self.commandDelegate sendPluginResult:plugResult
                                        callbackId:command.callbackId];
        });
    }
}

- (id)getStorageSync:(CDVInvokedUrlCommand *)command {
    id data = nil;

    if ([command.arguments.firstObject isKindOfClass:[NSDictionary class]]) {
        NSString *groupName = [command.arguments.firstObject objectForKey:@"groupName"];
        NSString *key = [command.arguments.firstObject objectForKey:@"key"];
        data = [NSStorage get:key groupName:groupName];
    }

    return @{
        @"data": data ? : [NSNull null]
    };
}

- (void)getStorage:(CDVInvokedUrlCommand *)command {
    id data = nil;

    if ([command.arguments.firstObject isKindOfClass:[NSDictionary class]]) {
        NSString *groupName = [command.arguments.firstObject objectForKey:@"groupName"];
        NSString *key = [command.arguments.firstObject objectForKey:@"key"];
        data = [NSStorage get:key groupName:groupName];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                    messageAsDictionary:@{ @"errCode": @0, @"errorMsg": @"获取成功", @"data": data ? : [NSNull null] }];
        [self.commandDelegate sendPluginResult:plugResult
                                    callbackId:command.callbackId];
    });
}

- (id)removeStorageSync:(CDVInvokedUrlCommand *)command {
    if ([command.arguments.firstObject isKindOfClass:[NSDictionary class]]) {
        NSString *groupName = [command.arguments.firstObject objectForKey:@"groupName"];
        NSString *key = [command.arguments.firstObject objectForKey:@"key"];

        if (key.length > 0) {
            [NSStorage remove:key groupName:groupName];
        }
    }

    return nil;
}

- (void)removeStorage:(CDVInvokedUrlCommand *)command {
    if ([command.arguments.firstObject isKindOfClass:[NSDictionary class]]) {
        NSString *groupName = [command.arguments.firstObject objectForKey:@"groupName"];
        NSString *key = [command.arguments.firstObject objectForKey:@"key"];

        if (key.length > 0) {
            [NSStorage remove:key groupName:groupName];

            dispatch_async(dispatch_get_main_queue(), ^{
                CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                            messageAsDictionary:@{ @"errCode": @0, @"errorMsg": @"成功", }];
                [self.commandDelegate sendPluginResult:plugResult
                                            callbackId:command.callbackId];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                            messageAsDictionary:@{ @"errCode": @-1, @"errorMsg": @"key值不能为空", }];
                [self.commandDelegate sendPluginResult:plugResult
                                            callbackId:command.callbackId];
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                        messageAsDictionary:@{ @"errCode": @-2, @"errorMsg": @"参数不正确", }];
            [self.commandDelegate sendPluginResult:plugResult
                                        callbackId:command.callbackId];
        });
    }
}

- (id)clearStorageSync:(CDVInvokedUrlCommand *)command {
    NSString *groupName = nil;

    if ([command.arguments.firstObject isKindOfClass:[NSDictionary class]]) {
        groupName = [command.arguments.firstObject objectForKey:@"groupName"];
    }

    [NSStorage clearWithGroupName:groupName];

    return nil;
}

- (void)clearStorage:(CDVInvokedUrlCommand *)command {
    NSString *groupName = nil;

    if ([command.arguments.firstObject isKindOfClass:[NSDictionary class]]) {
        groupName = [command.arguments.firstObject objectForKey:@"groupName"];
    }

    [NSStorage clearWithGroupName:groupName];


    dispatch_async(dispatch_get_main_queue(), ^{
        CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                    messageAsDictionary:@{ @"errCode": @0, @"errorMsg": @"清除完成" }];
        [self.commandDelegate sendPluginResult:plugResult
                                    callbackId:command.callbackId];
    });
}


#pragma mark - 打开文件
- (void)openFile:(CDVInvokedUrlCommand *)command  {
    NSString *urlString = nil;
    NSString *filename = nil;

    if ([command.arguments.firstObject isKindOfClass:[NSDictionary class]]) {
        urlString = [command.arguments.firstObject objectForKey:@"url"];
        filename = [command.arguments.firstObject objectForKey:@"fileName"];
    }

    if (filename.length == 0) {
        filename = urlString.lastPathComponent;
    }

    NSString *folderPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)firstObject]stringByAppendingPathComponent:[urlString md5String]];

    [[NSFileManager defaultManager]createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *localPath = [folderPath stringByAppendingPathComponent:filename];


    void (^openFileBlock)(void) = ^{
        UIDocumentInteractionController *documentVC = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:localPath]];
        documentVC.delegate = self;//设置分享代理
        BOOL canOpen = [documentVC presentPreviewAnimated:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!canOpen) {
                NSLog(@"没有程序可以打开选中的文件");
                CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                            messageAsDictionary:@{ @"errCode": @-1, @"errorMsg": @"无法查看" }];
                [self.commandDelegate sendPluginResult:plugResult
                                            callbackId:command.callbackId];
            } else {
                CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                            messageAsDictionary:@{ @"errCode": @0, @"errorMsg": @"打开成功" }];
                [self.commandDelegate sendPluginResult:plugResult
                                            callbackId:command.callbackId];
            }
        });
    };

    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {    //判断沙盒中是否存在此文件
        openFileBlock();
        return;
    }

    //不存在 重新下载
    NSURLSession *seesion = [NSURLSession sharedSession];

    // 3.创建NSURLRequest
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    // 4.根据NSURLSession创建下载
    NSURLSessionDownloadTask *downloadTask = [seesion downloadTaskWithRequest:request
                                                            completionHandler:^(NSURL *_Nullable location, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        NSFileManager *fileManager =  [NSFileManager defaultManager];
        NSError *copyError;

        [fileManager moveItemAtURL:location
                             toURL:[NSURL fileURLWithPath:localPath]
                             error:&copyError];
        NSLog(@"%@", copyError);
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([fileManager fileExistsAtPath:localPath]) {
                NSLog(@"下载完成");
                openFileBlock();
            } else {
                //下载文件失败
                CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{ @"errCode": @-2, @"errorMsg": @"下载失败" }];
                [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
            }
        });
    }];
    // 5.开始下载
    [downloadTask resume];
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self.viewController;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller {
    return self.viewController.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller {
    return self.viewController.view.frame;
}

/// 点击预览窗口的“Done”(完成)按钮时调用
- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller {
}

/// 文件分享面板弹出的时候调用
- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller {
    NSLog(@"WillPresentOpenInMenu");
}

/// 当选择一个文件分享App的时候调用
- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(nullable NSString *)application {
    NSLog(@"begin send : %@", application);
}

/// 弹框消失的时候走的方法
- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
    NSLog(@"dissMiss");
}

#pragma mark - 转换 图片path 为 base64
- (void)convertImagePathToBase64:(CDVInvokedUrlCommand *)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([command.arguments.firstObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *param = command.arguments.firstObject;
            NSString *imagePath = [param objectForKey:@"path"];

            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]];

            UIImage *image = [UIImage imageWithData:data];

            if (image) {
                NSMutableDictionary *dic = @{ @"errCode": @0 }.mutableCopy;
                NSData *data = UIImageJPEGRepresentation(image, 1.0f);
                NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                dic[@"base64Image"] = encodedImageStr;

                CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
                [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
            } else {
                CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{ @"errCode": @-1, @"errorMsg": @"转换失败" }];
                [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
            }
        } else {
            CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                        messageAsDictionary:@{ @"errCode": @-2, @"errorMsg": @"参数不正确" }];
            [self.commandDelegate sendPluginResult:plugResult
                                        callbackId:command.callbackId];
        }
    });
}

#pragma mark - 打开APP 原生页面
- (void)openNativePage:(CDVInvokedUrlCommand *)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([command.arguments.firstObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *param = command.arguments.firstObject;
            NSString *pageName = param[@"pageName"];
            NSDictionary *extInfo = param[@"extInfo"];

            Class pageClass = NSClassFromString(pageName);
            UIViewController<NSNativePageProtocol> *vc = [pageClass new];

            if ([vc isKindOfClass:[UIViewController class]]) {
                if ([vc conformsToProtocol:@protocol(NSNativePageProtocol)]) {
                    vc.extInfo = extInfo;
                }

                vc.hidesBottomBarWhenPushed = YES;
                [self.viewController.navigationController pushViewController:vc animated:YES];


                NSMutableDictionary *dic = @{ @"errCode": @0 }.mutableCopy;
                CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
                [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
            } else {
                CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                            messageAsDictionary:@{ @"errCode": @-3002, @"errorMsg": @"参数异常" }];
                [self.commandDelegate sendPluginResult:plugResult
                                            callbackId:command.callbackId];
            }
        } else {
            CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                        messageAsDictionary:@{ @"errCode": @-2, @"errorMsg": @"参数不正确" }];
            [self.commandDelegate sendPluginResult:plugResult
                                        callbackId:command.callbackId];
        }
    });
}
#pragma mark - 添加水印
- (void)addWaterMark:(CDVInvokedUrlCommand *)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([command.arguments.firstObject isKindOfClass:[NSDictionary class]]) {
            UIImage *image = nil;
            NSDictionary *param = command.arguments.firstObject;
            NSString *imagePath = [param objectForKey:@"imagePath"];
            NSString *text = [param objectForKey:@"text"];
            NSString *color = [param objectForKey:@"color"];
            NSString *backgroundColor = [param objectForKey:@"backgroundColor"];
            NSInteger cornerRadius = [[param objectForKey:@"cornerRadius"]intValue];
            NSInteger fontSize = [[param objectForKey:@"fontSize"]intValue];
            NSInteger margin = 8;

            if ([param objectForKey:@"margin"]) {
                margin = [[param objectForKey:@"margin"]intValue];
            }

            NSInteger padding = 8;

            if ([param objectForKey:@"margin"]) {
                padding = [[param objectForKey:@"padding"]intValue];
            }

            NSWaterMarkPosition position = NSWaterMarkRightBottom;

            if ([param objectForKey:@"position"]) {
                position =  [[param objectForKey:@"position"]intValue];
            }

            UIColor *textColor = [UIColor blackColor];
            UIColor *bgColor = [UIColor clearColor];

            if (color) {
                textColor = [UIColor colorWithHexString:param[@"color"]];
            }

            if (backgroundColor) {
                bgColor = [UIColor colorWithHexString:param[@"backgroundColor"]];
            }

            if (imagePath.length > 0) {
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]];
                image = [UIImage imageWithData:data];
            }

            if (image == nil) {
                NSString *base64Image = [command.arguments.firstObject objectForKey:@"base64Image"];
                //去除data:image/*;base64,前缀
                base64Image = [base64Image stringByReplacingRegex:@"data:image/[a-z]+;base64," options:NSRegularExpressionCaseInsensitive withString:@""];


                NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64Image options:NSDataBase64DecodingIgnoreUnknownCharacters];

                if (imageData) {
                    image = [UIImage imageWithData:imageData];
                }
            }

            image = [image addWaterMarkWithText:text position:position textColor:textColor backgroudColor:bgColor cornerRadius:cornerRadius font:[UIFont systemFontOfSize:fontSize ? : [UIFont systemFontSize]] margin:margin padding:padding ];

            if (image) {
                NSMutableDictionary *dic = @{ @"errCode": @0 }.mutableCopy;
                NSData *data = UIImageJPEGRepresentation(image, 1.0f);
                NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                dic[@"base64Image"] = encodedImageStr;

                NSString *tmpDir =  NSTemporaryDirectory();
                NSString *picFileName = [NSString stringWithFormat:@"%@%u.png", [[NSString stringWithFormat:@"%ld", data.hash] md5String], arc4random_uniform(10000000)];
                NSString *tempPath = [tmpDir stringByAppendingPathComponent:picFileName];
                BOOL result =  [data writeToFile:tempPath atomically:YES];

                if (result) {
                    dic[@"path"] = [NSString stringWithFormat:@"%@://%@", NSSchemeKey, picFileName];
                }

                CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
                [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
            } else {
                CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{ @"errCode": @-1, @"errorMsg": @"添加水印失败" }];
                [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
            }
        } else {
            CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                        messageAsDictionary:@{ @"errCode": @-2, @"errorMsg": @"参数不正确" }];
            [self.commandDelegate sendPluginResult:plugResult
                                        callbackId:command.callbackId];
        }
    });
}
@end
