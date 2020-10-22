//
//  NSWKWebViewController.m
//  OUYEEI_FINANCIAL
//
//  Created by 相晔谷 on 2019/7/8.
//  Copyright © 2019 neil. All rights reserved.
//

#import "NSWKWebViewController.h"
#import "NSWebKit.h"

@interface NSWKWebViewController ()

@end

@implementation NSWKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initDatas];
    [self setupUI];
    [self setupWKWebViewDelagate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)initDatas {
    self.ns_wk_allowsBackForwardNavigationGestures = YES;
    self.ns_wk_isAutoHeight = NO;
    self.ns_wk_multipleTouchEnabled = YES;
    self.ns_wk_autoresizesSubviews = YES;
}

- (void)setupUI {
    self.webView = [[NSWKWebViewPool sharedInstance] getPoolWebViewForHolder:self];
    self.webView.hidden = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    
    self.webView.ns_wk_isAutoHeight = self.ns_wk_isAutoHeight;
    self.webView.multipleTouchEnabled = self.ns_wk_multipleTouchEnabled;
    self.webView.autoresizesSubviews = self.ns_wk_autoresizesSubviews;
    self.webView.allowsBackForwardNavigationGestures = self.ns_wk_allowsBackForwardNavigationGestures;
    
    CGFloat progressBarX = 20;
    if (NSWK_WINDOW_HEIGHT >= 812) {
        progressBarX += 24;
    }
    self.webView.frame = CGRectMake(0, progressBarX, NSWK_WINDOW_WIDTH, NSWK_WINDOW_HEIGHT-progressBarX);
    
    [self.view addSubview:self.webView];
}

- (void)setupWKWebViewDelagate {
    @NSKit_Weakify(self);
    // 开始加载
    self.webView.ns_wk_didStartProvisionalNavigationBlock = ^(WKWebView * _Nullable webView, WKNavigation * _Nonnull navigation) {
        @NSKit_Strongify(self);
        NSLog(@"开始加载: ==>%@", webView.URL.absoluteString);
        [self ns_wk_didStartProvisionalNavigation:navigation];
    };
    // 结束加载
    self.webView.ns_wk_didFinishNavigationBlock = ^(WKWebView * _Nonnull webView, WKNavigation * _Nonnull navigation) {
        @NSKit_Strongify(self);
        
        [self ns_wk_didFinishNavigation:navigation];
    };
    // 加载失败
    self.webView.ns_wk_didFailProvisionalNavigationBlock = ^(WKWebView * _Nonnull webView, WKNavigation * _Nonnull navigation, NSError * _Nonnull error) {
        @NSKit_Strongify(self);
        
        [self ns_wk_didFailProvisionalNavigation:navigation withError:error];
    };
    // 正在加载
    self.webView.ns_wk_isLoadingBlock = ^(BOOL isLoading, CGFloat progress) {
        @NSKit_Strongify(self);
        NSLog(@"isLoading: %d | %.2lf", isLoading, progress);
        
        [self ns_wk_isLoading:isLoading progress:progress];
    };
    // 获取标题
    self.webView.ns_wk_getTitleBlock = ^(NSString * _Nonnull title) {
        @NSKit_Strongify(self);
        // 获取当前网页的 title
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.title = [NSString stringWithFormat:@"%@", title];
        });
        [self ns_wk_getTitle:title];
    };
    // 获取 URL
    self.webView.ns_wk_getCurrentUrlBlock = ^(NSURL * _Nonnull currentUrl) {
        @NSKit_Strongify(self);
        
        [self ns_wk_getCurrentUrl:currentUrl];
    };
    // 获取 web 动态高度
    self.webView.ns_wk_getCurrentHeightBlock = ^(CGFloat currentHeight) {
        @NSKit_Strongify(self);
        NSLog(@"%.2lf", currentHeight);
        [self ns_wk_getCurrentHeight:currentHeight];
    };
    // js 调用 OC
    self.webView.ns_wk_userContentControllerDidReceiveScriptMessageBlock = ^(WKUserContentController * _Nonnull userContentController, WKScriptMessage * _Nonnull message) {
        @NSKit_Strongify(self);
        [self ns_wk_userContentController:userContentController didReceiveScriptMessage:message];
    };
}

#pragma mark - wkwebview 方法包装
- (void)ns_wk_goBack {
    [self.webView ns_wk_goBack];
}

- (void)ns_wk_goForward {
    [self.webView ns_wk_goForward];
}

- (void)ns_wk_reload {
    [self.webView ns_wk_reload];
}

- (void)ns_wk_loadRequest:(NSURLRequest *)request {
    [self.webView ns_wk_loadRequest:request];
}

- (void)ns_wk_loadURL:(NSURL *)URL {
    [self.webView ns_wk_loadURL:URL];
}

- (void)ns_wk_loadURLString:(NSString *)URLString {
    [self.webView ns_wk_loadURLString:URLString];
}

- (void)ns_wk_loadBundleHTMLPath:(NSString *)sandboxPath {
    [self.webView ns_wk_loadBundleHTMLPath:sandboxPath];
}

- (void)ns_wk_loadSandboxHTMLPath:(NSString *)sandboxPath {
    [self.webView ns_wk_loadSandboxHTMLPath:sandboxPath];
}

- (void)ns_wk_loadHTMLString:(NSString *)htmlString {
    [self.webView ns_wk_loadHTMLString:htmlString];
}

- (void)ns_wk_stringByEvaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id result, NSError * _Nullable error))completionHandler {
    [self.webView ns_wk_stringByEvaluateJavaScript:javaScriptString completionHandler:completionHandler];
}

- (void)ns_wk_addScriptMessageHandlerWithNameArray:(NSArray *)nameArray {
    [self.webView ns_wk_addScriptMessageHandlerWithNameArray:nameArray];
}

#pragma mark - 子类重写
- (void)ns_wk_isLoading:(BOOL)isLoading progress:(CGFloat)progress {}

- (void)ns_wk_getTitle:(NSString * _Nonnull)title {}

- (void)ns_wk_getCurrentUrl:(NSURL * _Nonnull)currentUrl {}

- (void)ns_wk_getCurrentHeight:(CGFloat)currentHeight {}

- (void)ns_wk_userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {}

- (void)ns_wk_decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction {}

- (void)ns_wk_decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {}

- (void)ns_wk_didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {}

- (void)ns_wk_didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {}

- (void)ns_wk_didCommitNavigation:(null_unspecified WKNavigation *)navigation {}

- (void)ns_wk_didFinishNavigation:(null_unspecified WKNavigation *)navigation {}

- (void)ns_wk_didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {}

- (void)ns_wk_didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
