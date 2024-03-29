//
//  NSBasicPlugin.h
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//


#import "CDV.h"

@interface NSBasicPlugin : CDVPlugin

/// Toast
- (void)toast:(CDVInvokedUrlCommand *)command;

/// 跳转当前App的系统授权管理⻚
- (void)openAppAuthorizeSetting:(CDVInvokedUrlCommand *)command;

/// 获取当前App相关信息
- (id)getAppInfoSync:(CDVInvokedUrlCommand *)command;

/// 设置角标
- (void)setBadgeCount:(CDVInvokedUrlCommand *)command;

/// 打开新页面
- (void)navigateTo:(CDVInvokedUrlCommand *)command;

/// 返回上一页
- (void)navigateBack:(CDVInvokedUrlCommand *)command;

/// 打开系统浏览器
- (void)openExternalBrowser:(CDVInvokedUrlCommand *)command;

/// 设置WebView容器⻚面的导航栏主题
- (void)setNavigationBarTheme:(CDVInvokedUrlCommand *)command;

/// 获取设备相关信息
- (id)getDeviceInfoSync:(CDVInvokedUrlCommand *)command;

/// 获取系统剪贴板的内容
- (id)getClipboardDataSync:(CDVInvokedUrlCommand *)command;

/// 设置系统剪贴板的内容
- (void)setClipboardData:(CDVInvokedUrlCommand *)command;

/// 打电话
- (void)makePhoneCall:(CDVInvokedUrlCommand *)command;

/// 获取推送权限开关状态
- (void)getNotificationSwitchStatus:(CDVInvokedUrlCommand *)command;

/// 获取语音播报开关状态
- (void)getVoiceBroadcastSwitchStatus:(CDVInvokedUrlCommand *)command;

/// 设置语音播报开关状态
- (void)setVoiceBroadcastSwitchStatus:(CDVInvokedUrlCommand *)command;

/// 清理webview缓存
- (void)cleanWebviewCache:(CDVInvokedUrlCommand *)command;

/// 存储相关（同步）
- (id)setStorageSync:(CDVInvokedUrlCommand *)command;
- (id)getStorageSync:(CDVInvokedUrlCommand *)command;
- (id)removeStorageSync:(CDVInvokedUrlCommand *)command;
- (id)clearStorageSync:(CDVInvokedUrlCommand *)command;

/// 存储相关（异步）
- (void)setStorage:(CDVInvokedUrlCommand *)command;
- (void)getStorage:(CDVInvokedUrlCommand *)command;
- (void)removeStorage:(CDVInvokedUrlCommand *)command;
- (void)clearStorage:(CDVInvokedUrlCommand *)command;

/// 转换 图片path 为 base64
- (void)convertImagePathToBase64:(CDVInvokedUrlCommand *)command;

/// 打开APP 原生页面
- (void)openNativePage:(CDVInvokedUrlCommand *)command;

///  打开文件
- (void)openFile:(CDVInvokedUrlCommand *)command;

/// 添加水印
- (void)addWaterMark:(CDVInvokedUrlCommand *)command;
@end
