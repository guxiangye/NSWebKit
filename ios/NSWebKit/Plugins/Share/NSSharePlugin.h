//
//  NSSharePlugin.h
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//

#import "CDV.h"

@interface NSSharePlugin : CDVPlugin

/// 授权
- (void)sendWXAuthRequest:(CDVInvokedUrlCommand *)command;

/// 分享到微信
- (void)shareToWX:(CDVInvokedUrlCommand *)command;

/// 打开小程序
- (void)launchWXMiniProgram:(CDVInvokedUrlCommand *)command;

/// 分享到小程序
- (void)shareToWXMiniProgram:(CDVInvokedUrlCommand *)command;

@end
