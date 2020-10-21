//
//  WKWebView+NSKit.h
//  OUYEEI_FINANCIAL
//
//  Created by 相晔谷 on 2019/7/5.
//  Copyright © 2019 neil. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

#define NS_WK_TITLE                 @"title"
#define NS_WK_ESTIMATEDPROGRESS     @"estimatedProgress"
#define NS_WK_URL                   @"URL"
#define NS_WK_CONTENTSIZE           @"contentSize"

typedef void (^NS_WK_didStartProvisionalNavigationBlock)(WKWebView * _Nullable webView, WKNavigation *navigation);
typedef void (^NS_WK_didCommitNavigationBlock)(WKWebView *webView, WKNavigation *navigation);
typedef void (^NS_WK_didFinishNavigationBlock)(WKWebView *webView, WKNavigation *navigation);
typedef void (^NS_WK_didFailProvisionalNavigationBlock)(WKWebView *webView, WKNavigation *navigation, NSError *error);
typedef void (^NS_WK_didFailNavigationBlock)(WKNavigation *navigation, NSError *error);
typedef void (^NS_WK_isLoadingBlock)(BOOL isLoading, CGFloat progress);
typedef void (^NS_WK_getTitleBlock)(NSString *title);
typedef void (^NS_WK_userContentControllerDidReceiveScriptMessageBlock)(WKUserContentController *userContentController, WKScriptMessage *message);
typedef void (^NS_WK_decidePolicyForNavigationActionBlock)(NSURL *currentUrl, WKNavigationAction *navigationAction);

typedef void (^NS_WK_decisionHandler)(WKNavigationResponsePolicy);
typedef void (^NS_WK_decidePolicyForNavigationResponseBlock)(WKNavigationResponse *navigationResponse, NS_WK_decisionHandler decisionHandler);
typedef void (^NS_WK_getCurrentUrlBlock)(NSURL *currentUrl);
typedef void (^NS_WK_getCurrentHeightBlock)(CGFloat currentHeight);


@interface WKWebView (NSKit)
<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

#pragma mark - property
/**
 是否可以返回上级页面
 */
@property (nonatomic, readonly) BOOL ns_wk_canGoBack;
/**
 是否可以进入下级页面
 */
@property (nonatomic, readonly) BOOL ns_wk_canGoForward;
/**
 需要拦截的 urlScheme，白名单
 */
@property(nonatomic, strong) NSString *ns_wk_urlScheme;
/**
 是否需要自动设定高度
 */
@property (nonatomic, assign) BOOL ns_wk_isAutoHeight;
/**
 计算的页面高度
 */
@property (nonatomic, assign) CGFloat ns_wk_webViewHeigt;
/**
 获取 是不是正在加载
 */
@property (nonatomic, assign) BOOL ns_wk_isLoading;

#pragma mark - WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler,
/**
 开始加载时调用
 */
@property(nonatomic, copy) NS_WK_didStartProvisionalNavigationBlock ns_wk_didStartProvisionalNavigationBlock;
/**
 当内容开始返回时调用
 */
@property(nonatomic, copy) NS_WK_didCommitNavigationBlock ns_wk_didCommitNavigationBlock;
/**
 页面加载完成之后调用
 */
@property(nonatomic, copy) NS_WK_didFinishNavigationBlock ns_wk_didFinishNavigationBlock;
/**
 页面加载失败时调用
 */
@property(nonatomic, copy) NS_WK_didFailProvisionalNavigationBlock ns_wk_didFailProvisionalNavigationBlock;
/**
 跳转失败时调用
 */
@property(nonatomic, copy) NS_WK_didFailNavigationBlock ns_wk_didFailNavigationBlock;
/**
 获取 webview 当前的加载进度，判断是否正在加载
 */
@property(nonatomic, copy) NS_WK_isLoadingBlock ns_wk_isLoadingBlock;
/**
 获取 webview 当前的 title
 */
@property(nonatomic, copy) NS_WK_getTitleBlock ns_wk_getTitleBlock;
/**
 JS 调用 OC 时 webview 会调用此方法
 */
@property(nonatomic, copy) NS_WK_userContentControllerDidReceiveScriptMessageBlock ns_wk_userContentControllerDidReceiveScriptMessageBlock;
/**
 在发送请求之前，决定是否跳转，如果不添加这个，那么 wkwebview 跳转不了 AppStore 和 打电话，所谓拦截 URL 进行进一步处理，就在这里处理
 */
@property(nonatomic, copy) NS_WK_decidePolicyForNavigationActionBlock ns_wk_decidePolicyForNavigationActionBlock;
/**
 在响应完成时，调用的方法，决定是否跳转。如果设置为不允许响应，web内 容就不会传过来
 */
@property(nonatomic, copy) NS_WK_decidePolicyForNavigationResponseBlock ns_wk_decidePolicyForNavigationResponseBlock;
/**
 获取 webview 当前的 URL
 */
@property(nonatomic, copy) NS_WK_getCurrentUrlBlock ns_wk_getCurrentUrlBlock;
/**
 获取 webview 当前的 currentHeight
 */
@property(nonatomic, copy) NS_WK_getCurrentHeightBlock ns_wk_getCurrentHeightBlock;

#pragma mark - 其他
@property(nonatomic, weak) id holderObject;

#pragma mark - methods
/**
 初始化
 */
- (void)ns_wk_initWithNavigationDelegate:(id<WKNavigationDelegate>)navigationDelegate UIDelegate:(id<WKUIDelegate>)UIDelegate;
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

@end

NS_ASSUME_NONNULL_END
