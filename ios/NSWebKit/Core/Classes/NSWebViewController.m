//
//  NSWebViewController.m
//  NSWebKit
//
//  Created by 相晔谷 on 2023/5/26.
//

#import "NSWebViewController.h"
#import <WebKit/WebKit.h>
#import "CDVPlugin.h"
#import "CDVUserAgentUtil.h"
#import "Masonry.h"
#import "NSDictionary+YYAdd.h"
#import "NSObject+YYAddForKVO.h"
#import "NSImageURLProtocol.h"
#import "UIColor+YYAdd.h"
#import "UIColor+YYAdd.h"
#import "UIControl+YYAdd.h"
#import "UIDevice+YYAdd.h"
#import "UIImage+YYAdd.h"
#import "UIView+Toast.h"
#import "YYKitMacro.h"
#import "YYReachability.h"

@interface NSWebViewController () {
    NSString *actionTxt;
    NSString *actionIcon;
    NSString *customTitle;
    NSString *webViewTitle;
    BOOL isBright;
    BOOL showBackBtn;
    BOOL showCloseBtn;
    BOOL navigationBarHidden;
    BOOL translucentStatusBars; //状态栏是否沉浸
    UIColor *titleColor;
    UIColor *navigationBarBgColor;
    UIButton *errorView; //当发生错误的时候显示的页面
}
@property (nonatomic, strong) NSMutableDictionary *defaultConfig; //默认配置
@property (nonatomic, strong) NSMutableDictionary *configs;

@end

@implementation NSWebViewController

+ (void)load {
    //拦截自定义协议 nsfile
    [NSImageURLProtocol registerSelf];
}

- (void)dealloc {
    //    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserverBlocksForKeyPath:@"title"];
    //    [self.webView removeObserverBlocksForKeyPath:@"URL"];

    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

+ (id)getWebviewControllerWithInitialUrl:(NSString *)initialUrl fetchInitialUrlCallBack:(NSWebViewFetchInitialUrlCallback)fetchInitialUrlCallBack fetchUserAgentCallback:(NSWebViewFetchUserAgentCallback)fetchUserAgentCallback startedCallback:(NSWebViewStartedCallback)startedCallback finishedCallback:(NSWebViewFinishedCallback)finishedCallback receiveTitleCallback:(NSWebViewReceivedTitleCallback)receiveTitleCallback webResourceErrorCallback:(NSWebViewOnWebResourceErrorCallback)webResourceErrorCallback {
    NSWebViewController *vc = [NSWebViewController new];

    vc.initialUrl = initialUrl;
    vc.fetchInitialUrlCallBack = fetchInitialUrlCallBack;
    vc.fetchUserAgentCallback = fetchUserAgentCallback;
    vc.startedCallback = startedCallback;
    vc.finishedCallback = finishedCallback;
    vc.receiveTitleCallback = receiveTitleCallback;
    vc.webResourceErrorCallback = webResourceErrorCallback;
    [vc loadDefaultConfig:nil];
    return vc;
}

+ (id)getWebviewControllerWithConfig:(NSDictionary *)config fetchInitialUrlCallBack:(NSWebViewFetchInitialUrlCallback)fetchInitialUrlCallBack fetchUserAgentCallback:(NSWebViewFetchUserAgentCallback)fetchUserAgentCallback startedCallback:(NSWebViewStartedCallback)startedCallback finishedCallback:(NSWebViewFinishedCallback)finishedCallback receiveTitleCallback:(NSWebViewReceivedTitleCallback)receiveTitleCallback webResourceErrorCallback:(NSWebViewOnWebResourceErrorCallback)webResourceErrorCallback {
    NSString *initialUrl = config[@"url"];

    NSWebViewController *vc = [self getWebviewControllerWithInitialUrl:initialUrl
                                               fetchInitialUrlCallBack:fetchInitialUrlCallBack
                                                fetchUserAgentCallback:fetchUserAgentCallback
                                                       startedCallback:startedCallback
                                                      finishedCallback:finishedCallback
                                                  receiveTitleCallback:receiveTitleCallback
                                              webResourceErrorCallback:webResourceErrorCallback];

    [vc loadDefaultConfig:config.mutableCopy];
    return vc;
}

- (NSMutableDictionary *)configs {
    if (_configs == nil) {
        _configs = @{}.mutableCopy;
    }

    return _configs;
}

#pragma mark - 视图生命周期
- (void)viewDidLoad {
    self.navigationItem.hidesBackButton = YES;
    //解决使用自定义返回按钮 无法手势返回的问题
    //启用返回手势，需要解决卡死问题
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;

    if (self.fetchInitialUrlCallBack) {
        self.startPage = self.fetchInitialUrlCallBack(self.initialUrl);
    } else {
        self.startPage = self.initialUrl;
    }

    self.wwwFolderName = @"";
    //    self.navigationController.navigationBarHidden = YES;
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);

        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.top.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }
    }];

    errorView = [UIButton new];

    errorView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:errorView];
    [errorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    WKWebView *wkWebview = (WKWebView *)self.webView;

    __weak NSWebViewController *weakSelf = self;

    [errorView addBlockForControlEvents:UIControlEventTouchUpInside
                                  block:^(UIView *_Nonnull sender) {
        sender.hidden = YES;

        if ([wkWebview URL] == nil && weakSelf.startPage.length != 0) {
            NSURLRequest *appReq = [NSURLRequest requestWithURL:[NSURL URLWithString:weakSelf.startPage]
                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                timeoutInterval:20.0];
            [wkWebview loadRequest:appReq];
        } else {
            [wkWebview reload];
        }
    }];
    errorView.hidden = YES;

    UIImageView *refreshImage = [UIImageView new];
    refreshImage.image = [[UIImage imageNamed:@"refresh_arrow"]imageByTintColor:UIColorHex(0xDDDDDD)];
    [errorView addSubview:refreshImage];
    [refreshImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-80);
    }];

    UILabel *tips = [UILabel new];
    tips.text = @"轻触屏幕重新加载";
    tips.textColor = UIColorHex(0xDDDDDD);

    [errorView addSubview:tips];

    [tips mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(errorView);
        make.top.equalTo(refreshImage.mas_bottom).offset(20);
    }];

    WKWebView *webView = (WKWebView *)self.webView;
    if (@available(iOS 11.0, *)) {
        webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self injectionJSFile:[[NSBundle mainBundle]pathForResource:@"js/cordova.js" ofType:nil]];
    [self injectionJSFile:[[NSBundle mainBundle]pathForResource:@"js/cordova_plugins.js" ofType:nil] ];
    [self injectionJSFile:[[NSBundle mainBundle]pathForResource:@"js/plugins/cordova-plugin-wkwebview-engine/src/www/ios/ios-wkwebview-exec.js"  ofType:nil]];
    [self injectionJSFile:[[NSBundle mainBundle]pathForResource:@"js/plugins/cordova-plugin-wkwebview-engine/src/www/ios/ios-wkwebview.js" ofType:nil]];
    [self injectionJSFile:[[NSBundle mainBundle]pathForResource:@"js/plugins/cordova-plugin-network-information/www/Connection.js" ofType:nil]];
    [self injectionJSFile:[[NSBundle mainBundle]pathForResource:@"js/plugins/cordova-plugin-network-information/www/network.js" ofType:nil]];

    [self injectionJSFile:[[NSBundle mainBundle]pathForResource:@"js/ns.js" ofType:nil]];
    [self injectionJS:@"window.ns.isLocal = true"];

    for (NSString *jsFile in self.injectionJSFiles) {
        [self injectionJSFile:jsFile];
    }
    NSLog(@"\n\n JRJR URL:%@\n\n", self.startPage);

    //监听title
    @weakify(self)
    [self.webView addObserverBlockForKeyPath: @"title" block:^(id _Nonnull obj, id _Nullable oldVal, id _Nullable newVal) {
        @strongify(self)
        self->webViewTitle = webView.title;

        if (self.receiveTitleCallback) {
            self.receiveTitleCallback(webView.title);
        }

        NSDictionary *config = [self.configs objectForKey:[wkWebview.URL path]];

        if (config) {
            [self loadConfig:config];
        } else {
            [self loadConfig:self.defaultConfig];
        }
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewShouldStartLoad:) name:CDVPageShouldStartLoadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidFinishLoad:) name:CDVPageDidLoadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidLoadFail:) name:CDVPageDidLoadFailNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self refreshUI:animated];
    [super viewWillAppear:animated];
    WKWebView *wkWebView = (WKWebView *)self.webView;
    [wkWebView evaluateJavaScript:@"ns.noticePageShow()"
                completionHandler:^(id _Nullable obj, NSError *_Nullable error) {
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    //解决根试图左边滑动手势页面卡死问题
    if (self.navigationController.viewControllers.count == 1) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    } else {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    WKWebView *wkWebView = (WKWebView *)self.webView;
    [wkWebView evaluateJavaScript:@"ns.noticePageHide()"
                completionHandler:^(id _Nullable obj, NSError *_Nullable error) {
    }];
}

- (void)loadDefaultConfig:(NSMutableDictionary *)config {
    if (config == nil) {
        config = @{}.mutableCopy;
    }

    self.defaultConfig = config;

    if (self.defaultConfig[@"title"] == nil) {
        self.defaultConfig[@"title"] = @"";
    }

    if (self.defaultConfig[@"hidden"] == nil) {
        self.defaultConfig[@"hidden"] = @NO;
    }

    if (self.defaultConfig[@"color"] == nil) {
        self.defaultConfig[@"color"] = @"#eeeeee";
    }

    if (self.defaultConfig[@"titleColor"] == nil) {
        self.defaultConfig[@"titleColor"] = @"#000000";
    }

    if (self.defaultConfig[@"showBackButton"] == nil) {
        self.defaultConfig[@"showBackButton"] = @NO;
    }

    if (self.defaultConfig[@"showCloseButton"] == nil) {
        self.defaultConfig[@"showCloseButton"] = @NO;
    }

    if (self.defaultConfig[@"actionTxt"] == nil) {
        self.defaultConfig[@"actionTxt"] = @"";
    }

    if (self.defaultConfig[@"isBright"] == nil) {
        self.defaultConfig[@"isBright"] = @NO;
    }

    if (self.defaultConfig[@"translucentStatusBars"] == nil) {
        self.defaultConfig[@"translucentStatusBars"] = @NO;
    }

    [self loadConfig:self.defaultConfig];
}

- (void)loadConfig:(NSDictionary *)config {
    if ([config.allKeys containsObject:@"title"]) {
        customTitle = config[@"title"];
    }

    if ([config.allKeys containsObject:@"hidden"]) {
        navigationBarHidden = [config[@"hidden"]boolValue];
    }

    if ([config.allKeys containsObject:@"titleColor"]) {
        titleColor = [UIColor colorWithHexString:config[@"titleColor"]];
    }

    if ([config.allKeys containsObject:@"color"]) {
        navigationBarBgColor = [UIColor colorWithHexString:config[@"color"]];
    }

    if ([config.allKeys containsObject:@"showBackButton"]) {
        showBackBtn = [config[@"showBackButton"]boolValue];
    }

    if ([config.allKeys containsObject:@"showCloseButton"]) {
        showCloseBtn = [config[@"showCloseButton"]boolValue];
    }

    if ([config.allKeys containsObject:@"actionTxt"]) {
        actionTxt = config[@"actionTxt"];
    }

    if ([config.allKeys containsObject:@"isBright"]) {
        isBright = [config[@"isBright"]boolValue];
    }

    if ([config.allKeys containsObject:@"actionIcon"]) {
        actionIcon = config[@"actionIcon"];
    }

    if ([config.allKeys containsObject:@"translucentStatusBars"]) {
        translucentStatusBars = [config[@"translucentStatusBars"]boolValue];
    }

    //为当前页面保存配置
    NSDictionary *_config = @{
            @"title": customTitle ? : @"",
            @"hidden": @(navigationBarHidden),
            @"titleColor": [titleColor hexString],
            @"color": [navigationBarBgColor hexString],
            @"showBackButton": @(showBackBtn),
            @"showCloseBtn": @(showCloseBtn),
            @"actionTxt": actionTxt ? : @"",
            @"isBright": @(isBright),
            @"actionIcon": actionIcon ? : @"",
            @"translucentStatusBars": @(translucentStatusBars)
    };
    WKWebView *webView = (WKWebView *)self.webView;

    if (webView.URL.path) {
        self.configs[webView.URL.path] = _config;
    }

    [self refreshUI];
}

- (void)refreshUI {
    [self refreshUI:NO];
}

- (void)refreshUI:(BOOL)animated {
    [self setNeedsStatusBarAppearanceUpdate];

    [self.navigationController setNavigationBarHidden:navigationBarHidden animated:animated];

    if (navigationBarHidden == NO) {
        //只有在navigationBar现实的时候才去设置 VC.title, 否则会遇到 TabBarVC 的title 被切换的问题.
        if (customTitle.length != 0) {
            self.title = customTitle;
        } else if (webViewTitle.length != 0) {
            self.title = webViewTitle;
        }

        if (@available(iOS 15.0, *)) {
            UINavigationBarAppearance *navigationBarAppearance = [UINavigationBarAppearance new];
            [navigationBarAppearance configureWithTransparentBackground];
            navigationBarAppearance.backgroundEffect = nil;
            //隐藏导航栏分割线
            [navigationBarAppearance setShadowImage:[UIImage new]];
            [navigationBarAppearance setBackgroundImage:[UIImage new] ];

            if (navigationBarBgColor) {
                navigationBarAppearance.backgroundColor = navigationBarBgColor;
            }

            if (titleColor) {
                [navigationBarAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObject:titleColor forKey:NSForegroundColorAttributeName]];
            }

            self.navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance;
            self.navigationController.navigationBar.standardAppearance = navigationBarAppearance;
        } else {
            //隐藏导航栏分割线
            [self.navigationController.navigationBar setShadowImage:[UIImage new]];
            [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];

            self.navigationController.navigationBar.barTintColor = navigationBarBgColor;

            if (titleColor) {
                self.navigationController.navigationBar.tintColor = titleColor;
                [self.navigationController.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName: titleColor }];
            }
        }

        self.navigationController.navigationBar.translucent = NO;
        NSMutableArray *leftBarButtomItems = @[].mutableCopy;

        if ([self fetchWebViewCanGoBack]) {
            UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [backBtn setImage:[[UIImage imageNamed:@"sdp_back_btn"]imageByTintColor:titleColor] forState:UIControlStateNormal];
            backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [backBtn addTarget:self action:@selector(clickBackBtn) forControlEvents:UIControlEventTouchUpInside];
            backBtn.frame = CGRectMake(0, 0, 25, 44);
            [leftBarButtomItems addObject:[[UIBarButtonItem alloc]initWithCustomView:backBtn]];
        }

        if (showCloseBtn) {
            UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            //        closeBtn.backgroundColor = [UIColor redColor];
            [closeBtn setImage:[[UIImage imageNamed:@"sdp_close_btn"]imageByTintColor:titleColor] forState:UIControlStateNormal];
            closeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [closeBtn addTarget:self action:@selector(clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
            closeBtn.frame = CGRectMake(0, 0, 44, 44);
            [leftBarButtomItems addObject:[[UIBarButtonItem alloc]initWithCustomView:closeBtn]];
        }

        self.navigationItem.leftBarButtonItems = leftBarButtomItems;

        if (actionTxt.length != 0) {
            UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:actionTxt style:(UIBarButtonItemStylePlain) target:self action:@selector(clickRightBtnAction)];
            rightBtn.tintColor = titleColor;
            self.navigationItem.rightBarButtonItem = rightBtn;
        } else {
            self.navigationItem.rightBarButtonItem = nil;
        }

        if (actionIcon.length != 0) {
            NSString *base64Image = actionIcon;

            if ([base64Image hasPrefix:@"data:image/png;base64,"]) {
                base64Image = [base64Image stringByReplacingOccurrencesOfString:@"data:image/png;base64," withString:@""];
            }

            if ([base64Image hasPrefix:@"data:image/jpeg;base64,"]) {
                base64Image = [base64Image stringByReplacingOccurrencesOfString:@"data:image/jpeg;base64," withString:@""];
            }

            NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64Image options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage *image = [UIImage imageWithData:imageData];

            if (image) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                //            image = [image imageByResizeToSize:CGSizeMake(35, 35)];
                [button setImage:image forState:UIControlStateNormal];
                [button addTarget:self action:@selector(clickRightBtnAction) forControlEvents:UIControlEventTouchUpInside];
                [button.widthAnchor constraintEqualToConstant:35].active = YES;
                [button.heightAnchor constraintEqualToConstant:35].active = YES;
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
            }
        }

        [self.webView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);

            if (@available(iOS 11.0, *)) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            } else {
                make.top.equalTo(self.view);
            }
        }];
    } else {
        if (translucentStatusBars) {
            [self.webView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
        } else {
            [self.webView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.equalTo(self.view);

                if (@available(iOS 11.0, *)) {
                    make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
                } else {
                    make.top.equalTo(self.view);
                }
            }];
        }
    }
}

- (BOOL)fetchWebViewCanGoBack {
    if (showBackBtn) {
        return YES;
    }

    WKWebView *wkWebview = (WKWebView *)self.webView;

    return wkWebview.canGoBack || self.navigationController.viewControllers.count > 1 || self.navigationController.presentingViewController != nil;
}

#pragma mark - 点击返回按钮
- (void)clickBackBtn {
    WKWebView *wkWebview = (WKWebView *)self.webView;

    if (wkWebview.canGoBack) {
        if (errorView.hidden == NO) {
            return;
        }

        YYReachability *reachability = [YYReachability reachability];

        if ([UIDevice systemVersion] < 13 && reachability.status == YYReachabilityStatusNone) {
            [self.view makeToast:@"当前无网络,请检查网络" duration:2 position:[CSToastManager defaultPosition]];
            return;
        }

        [wkWebview goBack];
    } else {
        if (self.navigationController.viewControllers.count == 1) {
            [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - 点击关闭按钮
- (void)clickCloseBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 点击右侧按钮
- (void)clickRightBtnAction {
    WKWebView *wkWebView = (WKWebView *)self.webView;
    NSDictionary *dic = @{
            @"handlerName": @"rightActionCallback", @"data": @{
                @"actionTxt": actionTxt ? : @""
            }
    };

    [wkWebView evaluateJavaScript:[NSString stringWithFormat:@"ns.handleMessageFromNative('%@')", [dic jsonStringEncoded]]
                completionHandler:^(id _Nullable obj, NSError *_Nullable error) {
    }];
}

#pragma mark - 获取系统相关配置返回H5
- (NSString *)userAgent {
    NSString *originalUserAgent = [CDVUserAgentUtil originalUserAgent];

    if (self.fetchUserAgentCallback) {
        return self.fetchUserAgentCallback(originalUserAgent);
    }

    return originalUserAgent;
}

#pragma mark - wkWebViewNSNotification
- (void)webViewDidLoadFail:(NSNotification *)notification {
    WKWebView *webView = [notification.object objectForKey:@"webview"];
    NSError *error = [notification.object objectForKey:@"error"];

    if (webView == self.webView) {
        //当前无网络
        if (error.code == -1009 || error.code == -1001 || [error.domain isEqualToString:@"NSURLErrorDomain"]) {
            errorView.hidden = NO;

            if (self.webResourceErrorCallback) {
                self.webResourceErrorCallback(error);
            }
        }
    }
}

- (void)webViewDidFinishLoad:(NSNotification *)notification {
    if (notification.object == self.webView) {
        WKWebView *webView = (WKWebView *)self.webView;
        [webView evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';" completionHandler:nil];
        [webView evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];

        errorView.hidden = YES;

        if (self.finishedCallback) {
            self.finishedCallback(webView.URL.absoluteString);
        }
    }
}

- (void)webViewShouldStartLoad:(NSNotification *)notification {
    if (notification.object == self.webView) {
        WKWebView *webView = (WKWebView *)self.webView;

        if (self.startedCallback) {
            self.startedCallback(webView.URL.absoluteString);
        }
    }
}

#pragma mark 注入JS
- (void)injectionJSFile:(NSString *)jsFilePath {
    NSString *wrapperSource = [[NSString alloc]initWithContentsOfFile:jsFilePath encoding:NSUTF8StringEncoding error:nil];

    [self injectionJS:wrapperSource];
}

- (void)injectionJS:(NSString *)js {
    WKWebView *wkWebView = (WKWebView *)self.webView;
    WKUserContentController *userContentController = wkWebView.configuration.userContentController;
    WKUserScript *wrapperScript =
        [[WKUserScript alloc] initWithSource:js
                               injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                            forMainFrameOnly:NO];

    [userContentController addUserScript:wrapperScript];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return isBright ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (BOOL)prefersNavigationBarHidden {
    return navigationBarHidden;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
