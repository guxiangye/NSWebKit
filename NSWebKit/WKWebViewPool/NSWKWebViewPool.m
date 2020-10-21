//
//  NSWKWebViewPool.m
//  OUYEEI_FINANCIAL
//
//  Created by 相晔谷 on 2019/7/8.
//  Copyright © 2019 neil. All rights reserved.
//

#import "NSWKWebViewPool.h"
#import "NSWebKit.h"
#import "WKWebView+ClearWebCache.h"

@interface NSWKWebViewPool ()

@property (nonatomic, strong, readwrite) WKWebView *webView;
@property (nonatomic, strong, readwrite) WKWebViewConfiguration *webConfig;
@property (nonatomic, strong, readwrite) UIProgressView *progressView;
@property (nonatomic, strong, readwrite) UIRefreshControl *refreshControl;

@property (nonatomic, strong, readwrite) dispatch_semaphore_t semaphore;
@property (nonatomic, strong, readwrite) NSMutableSet<__kindof WKWebView *> *visiableWebViewSet;
@property (nonatomic, strong, readwrite) NSMutableSet<__kindof WKWebView *> *reusableWebViewSet;

@end

@implementation NSWKWebViewPool

+ (void)load {
    
//    __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
    
        [self prepareWebView];
//        [[NSNotificationCenter defaultCenter] removeObserver:observer];
//    }];
}

+ (void)prepareWebView {
    [[NSWKWebViewPool sharedInstance] _prepareReuseWebView];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static NSWKWebViewPool *webViewPool = nil;
    dispatch_once(&once,^{
        webViewPool = [[NSWKWebViewPool alloc] init];
    });
    return webViewPool;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.semaphore = dispatch_semaphore_create(1);
        self.prepare = YES;
        if ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"WKWebViewForPrepare"]) {
            self.prepare = WKWebViewForPrepare_KEY;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_cleanPoolReusableWebViews) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Method
- (WKWebView *)getPoolWebViewForHolder:(id)holder {
    if (!holder) {
#if DEBUG
        NSLog(@"MSWKWebViewPool must have a holder");
#endif
        return nil;
    }
    [self _tryCompactWeakHolders];
    
    WKWebView *webView;
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    
    if (self.reusableWebViewSet.count > 0) {
        webView = (WKWebView *)[self.reusableWebViewSet anyObject];
        [self.reusableWebViewSet removeObject:webView];
        [self.visiableWebViewSet addObject:webView];
    } else {
        webView = self.webView;
        [self.visiableWebViewSet addObject:webView];
    }
    webView.holderObject = holder;
    
    dispatch_semaphore_signal(self.semaphore);
    return webView;
}

- (void)recyclePoolReusedWebView:(__kindof WKWebView *)webView {
    if (!webView) {
        return;
    }
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    
    if ([self.visiableWebViewSet containsObject:webView]) {
        //将webView重置为初始状态
        [self.visiableWebViewSet removeObject:webView];
        [self.reusableWebViewSet addObject:webView];
        
    } else {
        if (![self.reusableWebViewSet containsObject:webView]) {
#if DEBUG
            NSLog(@"MSWKWebViewPool没有在任何地方使用这个webView");
#endif
        }
    }
    dispatch_semaphore_signal(self.semaphore);
}

- (void)cleanPoolReusableWebViews {
    [self _cleanPoolReusableWebViews];
}

#pragma mark - Private Method
- (void)_prepareReuseWebView {
    if (!self.prepare) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"%@", self.webView);
        [self.reusableWebViewSet addObject:self.webView];
//        [self->_reusableWebViewSet addObject:self->_webView];
//        NSLog(@"%@", self->_reusableWebViewSet);
    });
}

- (void)_cleanPoolReusableWebViews {
//    [self _tryCompactWeakHolders];
//
//    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
//    [self.reusableWebViewSet removeAllObjects];
//    dispatch_semaphore_signal(self.semaphore);
//
//    [WKWebView clearAllWebCache];
}

- (void)_tryCompactWeakHolders {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    
    NSMutableSet<WKWebView *> *shouldreusedWebViewSet = [NSMutableSet set];
    for (WKWebView *webView in _visiableWebViewSet) {
        if (!webView.holderObject) {
            [shouldreusedWebViewSet addObject:webView];
        }
    }
    for (WKWebView *webView in shouldreusedWebViewSet) {
        [self.visiableWebViewSet removeObject:webView];
        [self.reusableWebViewSet addObject:webView];
    }
    
    dispatch_semaphore_signal(self.semaphore);
}

#pragma mark - 懒加载..

- (NSMutableSet<WKWebView *> *)visiableWebViewSet {
    if (!_visiableWebViewSet) {
        _visiableWebViewSet = [NSSet set].mutableCopy;
    }
    return _visiableWebViewSet;
}

- (NSMutableSet<WKWebView *> *)reusableWebViewSet {
    if (!_reusableWebViewSet) {
        _reusableWebViewSet = [NSSet set].mutableCopy;
    }
    return _reusableWebViewSet;
}

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:self.webConfig];
        _webView.backgroundColor = [UIColor clearColor];
        _webView.scrollView.backgroundColor = [UIColor clearColor];
        
        _webView.ns_wk_isAutoHeight = NO;
        _webView.multipleTouchEnabled = NO;
        _webView.autoresizesSubviews = NO;
        _webView.allowsBackForwardNavigationGestures = NO;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
             // _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        @NSKit_Weakify(self);
        [_webView ns_wk_initWithNavigationDelegate:weak_self.webView UIDelegate:weak_self.webView];
#endif
    }
    return _webView;
}

- (WKWebViewConfiguration *)webConfig {
    if (!_webConfig) {
        // WKWebViewConfiguration:是WKWebView初始化时的配置类，里面存放着初始化WK的一系列属性；
        _webConfig = [[WKWebViewConfiguration alloc] init];
        
        // web内容处理池
        _webConfig.processPool = [[WKProcessPool alloc] init];
        // 是否支持记忆读取
        _webConfig.suppressesIncrementalRendering = NO;
        // 允许可以与网页交互，选择视图
        _webConfig.selectionGranularity = WKSelectionGranularityDynamic;
        // 通过 JS 与 webView 内容交互
        // 注入 JS 对象名称 senderModel，当 JS 通过 senderModel 来调用时，我们可以在WKScriptMessageHandler 代理中接收到
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        // 禁止选择CSS
        NSString *css = @"body{-webkit-user-select:none;-webkit-user-drag:none;-moz-user-select:none;}";
        
        // CSS选中样式取消
        NSMutableString *javascript = [NSMutableString string];
        [javascript appendString:@"var style = document.createElement('style');"];
        [javascript appendString:@"style.type = 'text/css';"];
        [javascript appendFormat:@"var cssContent = document.createTextNode('%@');", css];
        [javascript appendString:@"style.appendChild(cssContent);"];
        [javascript appendString:@"document.body.appendChild(style);"];

        // javascript注入
        WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:javascript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        // 添加 script
        [userContentController addUserScript:noneSelectScript];
        _webConfig.userContentController = userContentController;
        
        // 初始化偏好设置属性：preferences
        _webConfig.preferences = [WKPreferences new];
        // The minimum font size in points default is 0;
        // _webConfig.preferences.minimumFontSize = 40;
        // 是否支持 JavaScript
        _webConfig.preferences.javaScriptEnabled = YES;
        // 不通过用户交互，是否可以打开窗口
        _webConfig.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        
        // 视频播放 允许在线播放
        if ([_webConfig respondsToSelector:@selector(setAllowsInlineMediaPlayback:)]) {
            _webConfig.allowsInlineMediaPlayback = YES;
            if (@available(iOS 9.0, *)) {
                _webConfig.allowsAirPlayForMediaPlayback = YES;
            } else {
                // Fallback on earlier versions
            }
        }
        if (@available(iOS 10.0, *)) {
            if ([_webConfig respondsToSelector:@selector(setMediaTypesRequiringUserActionForPlayback:)]){
                [_webConfig setMediaTypesRequiringUserActionForPlayback:WKAudiovisualMediaTypeNone];
            }
        } else if (@available(iOS 9.0, *)) {
            if ([_webConfig respondsToSelector:@selector(setRequiresUserActionForMediaPlayback:)]) {
                [_webConfig setRequiresUserActionForMediaPlayback:NO];
            }
        } else {
            if ([_webConfig respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)]) {
                [_webConfig setMediaPlaybackRequiresUserAction:NO];
            }
        }
    }
    return _webConfig;
}

@end
