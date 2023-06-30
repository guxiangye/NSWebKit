//
//  NSWebViewController.h
//  NSWebKit
//
//  Created by neil on 2023/5/26.
//

#import "CDV.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString* (^NSWebViewFetchInitialUrlCallback)(NSString *initialUrl);
typedef NSString* (^NSWebViewFetchUserAgentCallback)(NSString *originalUserAgent);

typedef void (^NSWebViewStartedCallback)(NSString *url);
typedef void (^NSWebViewFinishedCallback)(NSString *url);
typedef void (^NSWebViewReceivedTitleCallback)(NSString *title);
typedef void (^NSWebViewOnWebResourceErrorCallback)(NSError *error);

@interface NSWebViewController : CDVViewController

/** 启动页URL */
@property(nonatomic,copy) NSString *initialUrl;

@property (nonatomic,copy)NSWebViewFetchInitialUrlCallback fetchInitialUrlCallBack;
@property (nonatomic,copy)NSWebViewFetchUserAgentCallback fetchUserAgentCallback;
@property (nonatomic,copy)NSWebViewStartedCallback startedCallback;
@property (nonatomic,copy)NSWebViewFinishedCallback finishedCallback;
@property (nonatomic,copy)NSWebViewReceivedTitleCallback receiveTitleCallback;
@property (nonatomic,copy)NSWebViewOnWebResourceErrorCallback webResourceErrorCallback;


/// 需要提前注入的JS文件 路径
@property (nonatomic,copy)NSArray * injectionJSFiles;


+(id)getWebviewControllerWithInitialUrl:(NSString *)initialUrl
          fetchInitialUrlCallBack:(NSWebViewFetchInitialUrlCallback)fetchInitialUrlCallBack
           fetchUserAgentCallback:(NSWebViewFetchUserAgentCallback)fetchUserAgentCallback
                  startedCallback:(NSWebViewStartedCallback)startedCallback
                 finishedCallback:(NSWebViewFinishedCallback)finishedCallback
             receiveTitleCallback:(NSWebViewReceivedTitleCallback)receiveTitleCallback
         webResourceErrorCallback:(NSWebViewOnWebResourceErrorCallback)webResourceErrorCallback;

+(id)getWebviewControllerWithConfig:(NSDictionary *)config
      fetchInitialUrlCallBack:(NSWebViewFetchInitialUrlCallback)fetchInitialUrlCallBack
       fetchUserAgentCallback:(NSWebViewFetchUserAgentCallback)fetchUserAgentCallback
              startedCallback:(NSWebViewStartedCallback)startedCallback
             finishedCallback:(NSWebViewFinishedCallback)finishedCallback
         receiveTitleCallback:(NSWebViewReceivedTitleCallback)receiveTitleCallback
     webResourceErrorCallback:(NSWebViewOnWebResourceErrorCallback)webResourceErrorCallback;

-(void)loadConfig:(NSDictionary *)config;

@end

NS_ASSUME_NONNULL_END
