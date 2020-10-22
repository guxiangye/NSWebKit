//
//  NSWKWebView.h
//  OUYEEI_FINANCIAL
//
//  Created by 相晔谷 on 2019/7/8.
//  Copyright © 2019 neil. All rights reserved.
//

#ifndef NSWebKit_h
#define NSWebKit_h

#import "NSWebViewController.h"
#import "NSWebViewPool.h"
#import "NSWebWeakScriptMessageHandler.h"

#import "WKWebView+NSKit.h"
#import "WKWebView+JavaScriptAlert.h"
#import "WKWebView+NSPost.h"
#import "WKWebView+ClearWebCache.h"

#define WKWebViewForPrepare_KEY [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"WKWebViewForPrepare"] boolValue]

#define NSWK_WINDOW_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define NSWK_WINDOW_WIDTH  [[UIScreen mainScreen] bounds].size.width

#ifndef NSKit_Weakify
#if DEBUG
#if __has_feature(objc_arc)
#define NSKit_Weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define NSKit_Weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define NSKit_Weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define NSKit_Weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef NSKit_Strongify
#if DEBUG
#if __has_feature(objc_arc)
#define NSKit_Strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define NSKit_Strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define NSKit_Strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define NSKit_Strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#endif
