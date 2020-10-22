//
//  NSWKWebViewController.h
//  OUYEEI_FINANCIAL
//
//  Created by 相晔谷 on 2019/7/8.
//  Copyright © 2019 neil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKWebView+NSKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSWebViewController : UIViewController

#pragma mark - wkwebview 属性
@property (nonatomic, strong) WKWebView * _Nullable webView;
/**
 是否开启往返手势, 默认 YES
 */
@property (nonatomic, assign) BOOL ns_wk_allowsBackForwardNavigationGestures;
/**
 开启自动计算高度, 默认 NO
 */
@property (nonatomic, assign) BOOL ns_wk_isAutoHeight;
/**
 开启多联系, 默认 YES
 */
@property (nonatomic, assign) BOOL ns_wk_multipleTouchEnabled;
/**
 自动调整子视图大小, 默认 YES
 */
@property (nonatomic, assign) BOOL ns_wk_autoresizesSubviews;

#pragma mark - wkwebview 方法包装
/**
 *  返回上一级页面
 */
- (void)ns_wk_goBack;
/**
 *  进入下一级页面
 */
- (void)ns_wk_goForward;
/**
 *  刷新 webView
 */
- (void)ns_wk_reload;
/**
 *  加载一个 webview
 *  @param request 请求的 NSURL URLRequest
 */
- (void)ns_wk_loadRequest:(NSURLRequest *)request;
/**
 *  加载一个 webview
 *  @param URL 请求的 URL
 */
- (void)ns_wk_loadURL:(NSURL *)URL;
/**
 *  加载一个 webview
 *  @param URLString 请求的 URLString
 */
- (void)ns_wk_loadURLString:(NSString *)URLString;
/**
 *  加载项目工程路径
 */
- (void)ns_wk_loadBundleHTMLPath:(NSString *)sandboxPath;
/**
 *  加载项目沙盒路径
 */
- (void)ns_wk_loadSandboxHTMLPath:(NSString *)sandboxPath;
/**
 *  加载本地 htmlString
 *  @param htmlString 请求的本地 htmlString
 */
- (void)ns_wk_loadHTMLString:(NSString *)htmlString;

/**
 *  OC 调用 JS，加载 js 字符串，例如：高度自适应获取代码：
 // webView 高度自适应
 [self ns_wk_stringByEvaluateJavaScript:@"document.body.offsetHeight" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
 // 获取页面高度，并重置 webview 的 frame
 self.ns_wk_currentHeight = [result doubleValue];
 CGRect frame = webView.frame;
 frame.size.height = self.ns_wk_currentHeight;
 webView.frame = frame;
 }];
 *  @param javaScriptString js 字符串
 */
- (void)ns_wk_stringByEvaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id result, NSError * _Nullable error))completionHandler;

/**
 JS 调用 OC，addScriptMessageHandler:name:有两个参数，第一个参数是 userContentController的代理对象，第二个参数是 JS 里发送 postMessage 的对象。添加一个脚本消息的处理器,同时需要在 JS 中添加，window.webkit.messageHandlers.<name>.postMessage(<messageBody>)才能起作用。
 @param nameArray JS 里发送 postMessage 的对象数组，可同时添加多个对象
 */
- (void)ns_wk_addScriptMessageHandlerWithNameArray:(NSArray *)nameArray;

#pragma mark - 子类重写
- (void)ns_wk_isLoading:(BOOL)isLoading progress:(CGFloat)progress;

- (void)ns_wk_getTitle:(NSString * _Nonnull)title;

- (void)ns_wk_getCurrentUrl:(NSURL * _Nonnull)currentUrl;

- (void)ns_wk_getCurrentHeight:(CGFloat)currentHeight;

#pragma mark - WKScriptMessageHandler
- (void)ns_wk_userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;

#pragma mark - WKNavigationDelegate
#pragma mark 这个代理方法表示当客户端收到服务器的响应头，根据 response 相关信息，可以决定这次跳转是否可以继续进行。在发送请求之前，决定是否跳转，如果不添加这个，那么 wkwebview 跳转不了 AppStore 和 打电话
- (void)ns_wk_decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction;

#pragma mark - 在响应完成时，调用的方法。如果设置为不允许响应，web内 容就不会传过来
- (void)ns_wk_decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;

#pragma mark - 接收到服务器跳转请求之后，即主机地址被重定向时调用
- (void)ns_wk_didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation;

#pragma mark - 开始加载时调用
- (void)ns_wk_didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation;

#pragma mark - 当内容开始返回时调用
- (void)ns_wk_didCommitNavigation:(null_unspecified WKNavigation *)navigation;

#pragma mark - 页面加载完成之后调用
- (void)ns_wk_didFinishNavigation:(null_unspecified WKNavigation *)navigation;

#pragma mark - 页面加载失败时调用
- (void)ns_wk_didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error;

#pragma mark - 跳转失败时调用
- (void)ns_wk_didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
