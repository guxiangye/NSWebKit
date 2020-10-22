//
//  WKWebView+NSKit.m
//  OUYEEI_FINANCIAL
//
//  Created by 相晔谷 on 2019/7/5.
//  Copyright © 2019 neil. All rights reserved.
//

#import "WKWebView+NSKit.h"
#import <objc/runtime.h>
#import "HtmlFileTransfer.h"
#import "WeakScriptMessageHandler.h"
#import "WKWebView+JavaScriptAlert.h"

@implementation WKWebView (NSKit)

#pragma mark - init
+ (void)load {
    Method originalMethod = class_getInstanceMethod(self, NSSelectorFromString(@"dealloc"));
    Method swizzledMethod = class_getInstanceMethod(self, @selector(ns_wk_dealloc));
    if (class_addMethod(self, NSSelectorFromString(@"dealloc"), method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(self, @selector(ns_wk_dealloc), method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)ns_wk_dealloc {
    [self ns_wk_dealloc];
    [self ns_wk_removeNoti];

    //清除UserScript
    [self.configuration.userContentController removeAllUserScripts];
    //停止加载
    [self stopLoading];
    [self setUIDelegate:nil];
    [self setNavigationDelegate:nil];
}

- (void)ns_wk_removeNoti {
    NSLog(@"%s",__FUNCTION__);
    @try {
        [self removeObserver:self forKeyPath:NS_WK_URL];
        [self removeObserver:self forKeyPath:NS_WK_TITLE];
        [self removeObserver:self forKeyPath:NS_WK_ESTIMATEDPROGRESS];
        if ( self.ns_wk_isAutoHeight ) [self.scrollView removeObserver:self forKeyPath:NS_WK_CONTENTSIZE];
    } @catch (NSException *exception) {} @finally {}
}

- (void)_ns_wk_addNoti {
    // 获取页面标题
    [self addObserver:self forKeyPath:NS_WK_TITLE options:NSKeyValueObservingOptionNew context:nil];
    // 当前页面载入进度
    [self addObserver:self forKeyPath:NS_WK_ESTIMATEDPROGRESS options:NSKeyValueObservingOptionNew context:nil];
    // 监听 URL，当之前的 URL 不为空，而新的 URL 为空时则表示进程被终止
    [self addObserver:self forKeyPath:NS_WK_URL options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:NS_WK_TITLE]) {
        if (self.ns_wk_getTitleBlock) {
            self.ns_wk_getTitleBlock(self.title);
        }
        return;
    } else if ([keyPath isEqualToString:NS_WK_ESTIMATEDPROGRESS]) {
        if (self.ns_wk_isLoadingBlock) {
            self.ns_wk_isLoadingBlock(self.loading, self.estimatedProgress);
        }
    } else if ([keyPath isEqualToString:NS_WK_URL]) {
        if (self.ns_wk_getCurrentUrlBlock) {
            self.ns_wk_getCurrentUrlBlock(self.URL);
        }
    } else if ( [keyPath isEqualToString:NS_WK_CONTENTSIZE] && [object isEqual:self.scrollView] ) {
        __block CGFloat height = floorf([change[NSKeyValueChangeNewKey] CGSizeValue].height);
        NSLog(@"%.2lf", height);
        if (height != self.ns_wk_webViewHeigt) {
            self.ns_wk_webViewHeigt = height;

            CGRect frame = self.frame;
            frame.size.height = height;
            self.frame = frame;

            if (self.ns_wk_getCurrentHeightBlock) {
                self.ns_wk_getCurrentHeightBlock(height);
            }
        } else if (height == self.ns_wk_webViewHeigt && height > 0.f) {

        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }

    // 加载完成
    if (!self.loading) {
        if (self.ns_wk_isLoadingBlock) {
            self.ns_wk_isLoadingBlock(self.loading, 1.0F);
        }
    }
}

#pragma mark - 属性（property）
- (BOOL)ns_wk_canGoBack {
    return [self canGoBack];
}

- (BOOL)ns_wk_canGoForward {
    return [self canGoForward];
}

- (void)setNs_wk_urlScheme:(NSString *)ns_wk_urlScheme {
    objc_setAssociatedObject(self, @selector(ns_wk_urlScheme), ns_wk_urlScheme, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)ns_wk_urlScheme {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNs_wk_isLoading:(BOOL)ns_wk_isLoading {
    objc_setAssociatedObject(self, @selector(ns_wk_isLoading), @(ns_wk_isLoading), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ns_wk_isLoading {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setNs_wk_isAutoHeight:(BOOL)ns_wk_isAutoHeight {
    objc_setAssociatedObject(self, @selector(ns_wk_isAutoHeight), @(ns_wk_isAutoHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    // 监听高度变化 (暂时拿掉)
//    if (ns_wk_isAutoHeight) {
//        [self.scrollView addObserver:self forKeyPath:NS_WK_CONTENTSIZE options:NSKeyValueObservingOptionNew context:nil];
//    }
}

- (BOOL)ns_wk_isAutoHeight {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setNs_wk_webViewHeigt:(CGFloat)ns_wk_webViewHeigt {
    objc_setAssociatedObject(self, @selector(ns_wk_webViewHeigt), @(ns_wk_webViewHeigt), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)ns_wk_webViewHeigt {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setNs_wk_didStartProvisionalNavigationBlock:(NS_WK_didStartProvisionalNavigationBlock)ns_wk_didStartProvisionalNavigationBlock {
    objc_setAssociatedObject(self, @selector(ns_wk_didStartProvisionalNavigationBlock), ns_wk_didStartProvisionalNavigationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NS_WK_didStartProvisionalNavigationBlock)ns_wk_didStartProvisionalNavigationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNs_wk_didCommitNavigationBlock:(NS_WK_didCommitNavigationBlock)ns_wk_didCommitNavigationBlock {
    objc_setAssociatedObject(self, @selector(ns_wk_didCommitNavigationBlock), ns_wk_didCommitNavigationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NS_WK_didCommitNavigationBlock)ns_wk_didCommitNavigationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNs_wk_didFinishNavigationBlock:(NS_WK_didFinishNavigationBlock)ns_wk_didFinishNavigationBlock {
    objc_setAssociatedObject(self, @selector(ns_wk_didFinishNavigationBlock), ns_wk_didFinishNavigationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NS_WK_didFinishNavigationBlock)ns_wk_didFinishNavigationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNs_wk_didFailProvisionalNavigationBlock:(NS_WK_didFailProvisionalNavigationBlock)ns_wk_didFailProvisionalNavigationBlock {
    objc_setAssociatedObject(self, @selector(ns_wk_didFailProvisionalNavigationBlock), ns_wk_didFailProvisionalNavigationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NS_WK_didFailProvisionalNavigationBlock)ns_wk_didFailProvisionalNavigationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNs_wk_didFailNavigationBlock:(NS_WK_didFailNavigationBlock)ns_wk_didFailNavigationBlock {
    objc_setAssociatedObject(self, @selector(ns_wk_didFailNavigationBlock), ns_wk_didFailNavigationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NS_WK_didFailNavigationBlock)ns_wk_didFailNavigationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNs_wk_isLoadingBlock:(NS_WK_isLoadingBlock)ns_wk_isLoadingBlock {
    objc_setAssociatedObject(self, @selector(ns_wk_isLoadingBlock), ns_wk_isLoadingBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NS_WK_isLoadingBlock)ns_wk_isLoadingBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNs_wk_getTitleBlock:(NS_WK_getTitleBlock)ns_wk_getTitleBlock {
    objc_setAssociatedObject(self, @selector(ns_wk_getTitleBlock), ns_wk_getTitleBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NS_WK_getTitleBlock)ns_wk_getTitleBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNs_wk_userContentControllerDidReceiveScriptMessageBlock:(NS_WK_userContentControllerDidReceiveScriptMessageBlock)ns_wk_userContentControllerDidReceiveScriptMessageBlock {
    objc_setAssociatedObject(self, @selector(ns_wk_userContentControllerDidReceiveScriptMessageBlock), ns_wk_userContentControllerDidReceiveScriptMessageBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NS_WK_userContentControllerDidReceiveScriptMessageBlock)ns_wk_userContentControllerDidReceiveScriptMessageBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNs_wk_decidePolicyForNavigationActionBlock:(NS_WK_decidePolicyForNavigationActionBlock)ns_wk_decidePolicyForNavigationActionBlock {
    objc_setAssociatedObject(self, @selector(ns_wk_decidePolicyForNavigationActionBlock), ns_wk_decidePolicyForNavigationActionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);

}

- (NS_WK_decidePolicyForNavigationActionBlock)ns_wk_decidePolicyForNavigationActionBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNs_wk_decidePolicyForNavigationResponseBlock:(NS_WK_decidePolicyForNavigationResponseBlock)ns_wk_decidePolicyForNavigationResponseBlock {
    objc_setAssociatedObject(self, @selector(ns_wk_decidePolicyForNavigationResponseBlock), ns_wk_decidePolicyForNavigationResponseBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NS_WK_decidePolicyForNavigationResponseBlock)ns_wk_decidePolicyForNavigationResponseBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNs_wk_getCurrentUrlBlock:(NS_WK_getCurrentUrlBlock)ns_wk_getCurrentUrlBlock {
    objc_setAssociatedObject(self, @selector(ns_wk_getCurrentUrlBlock), ns_wk_getCurrentUrlBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NS_WK_getCurrentUrlBlock)ns_wk_getCurrentUrlBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setNs_wk_getCurrentHeightBlock:(NS_WK_getCurrentHeightBlock)ns_wk_getCurrentHeightBlock {
    objc_setAssociatedObject(self, @selector(ns_wk_getCurrentHeightBlock), ns_wk_getCurrentHeightBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NS_WK_getCurrentHeightBlock)ns_wk_getCurrentHeightBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setHolderObject:(id)holderObject {
    objc_setAssociatedObject(self, @selector(holderObject), holderObject, OBJC_ASSOCIATION_ASSIGN);
}

- (id)holderObject {
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - methods
- (void)ns_wk_initWithNavigationDelegate:(id<WKNavigationDelegate>)navigationDelegate UIDelegate:(id<WKUIDelegate>)UIDelegate {
    self.navigationDelegate = navigationDelegate;
    self.UIDelegate = UIDelegate;
    self.ns_wk_webViewHeigt = 0.f;
    [self _ns_wk_addNoti];
}

- (void)ns_wk_goBack {
    if (self.canGoBack) { [self goBack]; }
}

- (void)ns_wk_goForward {
    if (self.canGoForward) { [self goForward]; }
}

- (void)ns_wk_reload {
    [self reload];
}

- (void)ns_wk_loadRequest:(NSURLRequest *)request {
    [self loadRequest:request];
}

static NSInteger kTimeoutCount = 30;
- (void)ns_wk_loadURL:(NSURL *)URL {
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:0 timeoutInterval:kTimeoutCount];
    [self ns_wk_loadRequest:request];
}

- (void)ns_wk_loadURLString:(NSString *)URLString {
    [self ns_wk_loadURL:[NSURL URLWithString:URLString]];
}

- (void)ns_wk_loadBundleHTMLPath:(NSString *)sandboxPath {
    NSString *path = [[NSBundle mainBundle] pathForResource:sandboxPath ofType:nil];
    [self ns_wk_loadURL:[NSURL fileURLWithPath:path]];
}

- (void)ns_wk_loadSandboxHTMLPath:(NSString *)sandboxPath {
    if (sandboxPath) {
        NSString *htmlPath = [NSHomeDirectory() stringByAppendingPathComponent:sandboxPath];
        if (@available(iOS 9.0, *)) {
            NSURL *fileURL = [NSURL fileURLWithPath:htmlPath];
            [self loadFileURL:fileURL allowingReadAccessToURL:fileURL];
        } else {
            NSURL *fileURL = [HtmlFileTransfer fileURLForBuggyWKWebView8:[NSURL fileURLWithPath:htmlPath]];
            [self ns_wk_loadURL:fileURL];
        }
    }
}

- (void)ns_wk_loadHTMLString:(NSString *)htmlString {
    NSString *basePath = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:basePath];
    [self loadHTMLString:htmlString baseURL:baseURL];
}

- (void)ns_wk_stringByEvaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id result, NSError * _Nullable error))completionHandler {
    [self evaluateJavaScript:javaScriptString completionHandler:completionHandler];
}

- (void)ns_wk_addScriptMessageHandlerWithNameArray:(NSArray *)nameArray {
    if ([nameArray isKindOfClass:[NSArray class]] && nameArray.count > 0) {
        [nameArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.configuration.userContentController addScriptMessageHandler:[[WeakScriptMessageHandler alloc] initWithDelegate:self] name:obj];
        }];
    }
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (self.ns_wk_userContentControllerDidReceiveScriptMessageBlock) {
        self.ns_wk_userContentControllerDidReceiveScriptMessageBlock(userContentController, message);
    }
}

#pragma mark - WKNavigationDelegate
#pragma mark 这个代理方法表示当客户端收到服务器的响应头，根据 response 相关信息，可以决定这次跳转是否可以继续进行。在发送请求之前，决定是否跳转，如果不添加这个，那么 wkwebview 跳转不了 AppStore 和 打电话
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    NSString *url_scheme = url.scheme;
    // url 拦截
    if ([url_scheme isEqualToString:self.ns_wk_urlScheme]) {
        if (self.ns_wk_decidePolicyForNavigationActionBlock) {
            self.ns_wk_decidePolicyForNavigationActionBlock(url, navigationAction);
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    // APPStore
    if ([url.absoluteString containsString:@"itunes.apple.com"]) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    // 调用电话
    if ([url.scheme isEqualToString:@"tel"]) {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }

    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - 在响应完成时，调用的方法。如果设置为不允许响应，web内 容就不会传过来
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if (self.ns_wk_decidePolicyForNavigationResponseBlock) {
        self.ns_wk_decidePolicyForNavigationResponseBlock(navigationResponse, decisionHandler);
        return;
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark - 接收到服务器跳转请求之后，即主机地址被重定向时调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {}

#pragma mark - 开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
    self.ns_wk_isLoading = YES;
    if (self.ns_wk_didStartProvisionalNavigationBlock) {
        self.ns_wk_didStartProvisionalNavigationBlock(webView, navigation);
    }
}

#pragma mark - 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    if (self.ns_wk_didCommitNavigationBlock) {
        self.ns_wk_didCommitNavigationBlock(webView, navigation);
    }
}

#pragma mark - 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
    self.ns_wk_isLoading = NO;

    if (self.ns_wk_didFinishNavigationBlock) {
        self.ns_wk_didFinishNavigationBlock(webView, navigation);
    }

    if (self.ns_wk_getCurrentHeightBlock) {
        NSString *heightString = @"document.body.scrollHeight";
        [self ns_wk_stringByEvaluateJavaScript:heightString completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
            // 获取页面高度，并重置 webview 的 frame
            CGFloat currentHeight = [result doubleValue];
            self.ns_wk_getCurrentHeightBlock(currentHeight);
        }];
    }

    if (self.ns_wk_isAutoHeight) {
        NSString *heightString = @"document.body.scrollHeight";
        [self ns_wk_stringByEvaluateJavaScript:heightString completionHandler:^(id  _Nullable result, NSError * _Nullable error) {
            // 获取页面高度，并重置 webview 的 frame
            CGFloat currentHeight = [result doubleValue];
            CGRect frame = webView.frame;
            frame.size.height = currentHeight;
            webView.frame = frame;
            [webView.superview setNeedsLayout];
        }];
    }
}

#pragma mark - 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
    self.ns_wk_isLoading = NO;
    if (self.ns_wk_didFailProvisionalNavigationBlock) {
        self.ns_wk_didFailProvisionalNavigationBlock(webView, navigation, error);
    }
}

#pragma mark - 跳转失败时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
    self.ns_wk_isLoading = NO;
    if (self.ns_wk_didFailNavigationBlock) {
        self.ns_wk_didFailNavigationBlock(navigation, error);
    }
}

#pragma mark -  如果需要证书验证，与使用AFN进行HTTPS证书验证是一样的
//- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
//    completionHandler(0, nil);
//}

#pragma mark - 9.0才能使用，web内容处理中断时会触发
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0)) {
    NSLog(@"[nskit]===> 进程被终止 %@", webView.URL);
}


#pragma mark - WKUIDelegate
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark -
- (void)webViewDidClose:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0)) {}


#if TARGET_OS_IPHONE

- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo API_AVAILABLE(ios(10.0)) {
    return YES;
}

- (nullable UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id <WKPreviewActionItem>> *)previewActions API_AVAILABLE(ios(10.0)) {
    return nil;
}

- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController API_AVAILABLE(ios(10.0)) {}

#endif

#if !TARGET_OS_IPHONE

- (void)webView:(WKWebView *)webView runOpenPanelWithParameters:(WKOpenPanelParameters *)parameters initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSArray<NSURL *> * _Nullable URLs))completionHandler API_AVAILABLE(macosx(10.12)) {}

#endif

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
