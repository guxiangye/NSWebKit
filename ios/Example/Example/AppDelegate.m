//
//  AppDelegate.m
//  Example
//
//  Created by 相晔谷 on 2023/5/26.
//

#import "AppDelegate.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import "WXApi.h"
#import "NSWebViewController.h"
#import "NSServiceProxy.h"
#import "NSWXManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    NSString *url = @"w/index.html";
    // 加载本地包
//    url = @"www/index.html";
    // 推荐加载本地启动node服务地址
//    url = @"http://10.241.86.29:5173";
    NSWebViewController *webVC = [NSWebViewController getWebviewControllerWithConfig:@{ @"hidden": @YES, @"url": url, @"translucentStatusBars": @YES } fetchInitialUrlCallBack:NULL fetchUserAgentCallback:NULL startedCallback:NULL finishedCallback:NULL receiveTitleCallback:NULL webResourceErrorCallback:NULL];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
    self.window.rootViewController = nav;

    [self.window makeKeyAndVisible];
    [self initSDKs];
    return YES;
}

- (void)initSDKs {
    static BOOL sdkHasInit = NO;
    
    if (sdkHasInit == NO) {
        sdkHasInit = YES;
        
        [NSServiceProxy setFetchAppId:^NSString *{
            return @"ZF1234";
        } fetchDeviceId:^NSString *{
            return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        } fetchExtendInfo:^NSDictionary *{
            return nil;
        }];
        
        [AMapServices sharedServices].apiKey = @"d54ac047a964fa9c4d00febe9c8c89af";
        [AMapLocationManager updatePrivacyAgree:AMapPrivacyAgreeStatusDidAgree];
        [AMapLocationManager updatePrivacyShow:AMapPrivacyShowStatusDidShow privacyInfo:AMapPrivacyInfoStatusDidContain];
        
        [WXApi registerApp:@"wxAppid" universalLink:@"https://sckfk.share2dlink.com/"];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
          [[UIApplication sharedApplication] registerUserNotificationSettings:
              [UIUserNotificationSettings settingsForTypes:
                  (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
          [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else{
          [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
              (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
        }
    }
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return [WXApi handleOpenURL:url delegate:[NSWXManager sharedManager]];
}

@end
