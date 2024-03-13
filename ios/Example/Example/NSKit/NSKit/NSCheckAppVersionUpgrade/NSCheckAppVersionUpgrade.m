//
//  NSCheckAppVersionUpgrade.m
//  NSKit
//
//  Created by Neil on 2023/3/7.
//

#import "NSCheckAppVersionUpgrade.h"
#import "NSMerchantHeaderInterceptor.h"
#import "NSNetworkSessionManager.h"
#import "NSHttpManager.h"
#import "NSMerchantRequest.h"
#import "CheckVersionReq.h"
#import "NSNetCall.h"
#import "CheckVersionResp.h"
#import "NSCore.h"

@interface NSCheckAppVersionUpgrade ()
@property(nonatomic,copy)NSString *appType;
@property(nonatomic,assign)NSCheckAppVersionEnviromentType enviromentType;

@end
@implementation NSCheckAppVersionUpgrade
+ (id)sharedInstance {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        
        NSNetworkConfig *config = [NSNetworkConfig new];
        NSString *publicKey = [NSCheckAppVersionUpgrade getPublicKey];
        NSMerchantHeaderInterceptor *interceptor = [[NSMerchantHeaderInterceptor alloc]initWithPublicKey:publicKey];

        config.interceptors = @[interceptor];
        [[NSHttpManager sharedInstance]registerConfig:config baseURL:[NSCheckAppVersionUpgrade getBaseURL]];
    });
    return _instance;
}
+(NSString *)getBaseURL{
    NSString *serverUrl = @"";
    
    switch ([NSCore sharedInstance].enviromentType) {
        case NSEnviromentTest:
            serverUrl =@"https://test.nswebkit.com";
            break;
        case NSEnviromentPreProd:
            serverUrl = @"https://pre.nswebkit.com";
            break;
        case NSEnviromentProd:
            serverUrl = @"https://prod.nswebkit.com";
            break;
            
        default:
            break;
    }
    return serverUrl;
}
+(NSString *)getPublicKey{
    NSString *publicKey = nil;
    switch ([NSCore sharedInstance].enviromentType) {
        case NSEnviromentTest:
            publicKey = @"publicKey";
            break;
        case NSEnviromentPreProd:
            publicKey = @"publicKey";
            break;
        case NSEnviromentProd:
            publicKey = @"publicKey";
            break;
            
        default:
            break;
    }
    return publicKey;
}
+(void)setCheckAppVersionEnviromentType:(NSCheckAppVersionEnviromentType)enviromentType{
    NSCheckAppVersionUpgrade *checkAppVersion = [NSCheckAppVersionUpgrade sharedInstance];
    checkAppVersion.enviromentType =enviromentType;
}
+(void)checkAppVersionWithAppType:(NSString *)appType{
    NSCheckAppVersionUpgrade *checkAppVersion = [NSCheckAppVersionUpgrade sharedInstance];
    checkAppVersion.appType = appType;
    [[NSNotificationCenter defaultCenter]removeObserver:checkAppVersion];
    [[NSNotificationCenter defaultCenter] addObserver:checkAppVersion
                                             selector:@selector(checkAppVersion)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [checkAppVersion checkAppVersion];
    
}
- (void)checkAppVersion {
    CheckVersionReq *req = [CheckVersionReq new];
    req.appType = self.appType;
    req.osPlatform = @"2";
    NSString *currentVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    req.currentVersionName = currentVersion;
    
    NSNetCall<CheckVersionResp*>*call = [req buildNetCall];
    [call sendAsync:^(NSNetResponse<CheckVersionResp *> * _Nonnull response) {

        if (response.isSuccessful) {
            CheckVersionResp *responseData = response.responseData;
            NSString *lastVersion = responseData.versionName;
            NSString *releaseInfo = responseData.releaseInfo;
            NSString *url = responseData.url;
            BOOL forceUpdate = responseData.forceUpdate;

            NSInteger compareResult = [self compareVersion:lastVersion toVersion:currentVersion];
            if (lastVersion.length > 0 && (compareResult == 1)) {
                
                dispatch_async(dispatch_get_main_queue(), ^() {
                    // 有新版本

                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"检测到新版本 %@",lastVersion]
                                                                                   message:releaseInfo
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"立即升级"
                                                                         style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction *_Nonnull action) {
                        
                        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
                                            
                        }];
                    }];

                    [alert addAction:sureAction];

                    //非强制升级
                    if (!forceUpdate) {
                        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {}];
                        [alert addAction:cancleAction];
                    }

                    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                });
               
            } else {
                //已经是最新版本
            }
        }
    }];
  
}



#pragma mark - 比较两个版本号大小
- (NSInteger)compareVersion:(NSString *)version1 toVersion:(NSString *)version2 {
    NSArray *list1 = [version1 componentsSeparatedByString:@"."];
    NSArray *list2 = [version2 componentsSeparatedByString:@"."];
    for (int i = 0; i < list1.count || i < list2.count; i++) {
        NSInteger a = 0, b = 0;
        if (i < list1.count) {
            a = [list1[i] integerValue];
        }
        if (i < list2.count) {
            b = [list2[i] integerValue];
        }
        //version1大于version2
        if (a > b) {
            return 1;
        }
        //version1小于version2
        else if (a < b) {
            return -1;
        }
    }
    return 0;
}
@end
