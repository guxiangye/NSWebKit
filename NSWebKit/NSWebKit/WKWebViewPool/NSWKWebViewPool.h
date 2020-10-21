//
//  NSWKWebViewPool.h
//  OUYEEI_FINANCIAL
//
//  Created by 相晔谷 on 2019/7/8.
//  Copyright © 2019 neil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WKWebView+NSKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSWKWebViewPool : NSObject

/**
 需要在 info.plist 中配置 WKWebViewForPrepare
 是否需要在App启动时提前准备好一个可复用的WebView, 默认为YES.
 prepare=YES时, 可显著优化WKWebView首次启动时间.
 prepare=NO时, 不会提前初始化一个可复用的WebView.
 */
@property (nonatomic, assign) BOOL prepare;

/**
 单例
 */
+ (instancetype)sharedInstance;

/**
 从 pool 中获取webview
 */
- (WKWebView *)getPoolWebViewForHolder:(id)holder;
/**
 从 pool 中清理webview
 */
- (void)cleanPoolReusableWebViews;

@end

NS_ASSUME_NONNULL_END
