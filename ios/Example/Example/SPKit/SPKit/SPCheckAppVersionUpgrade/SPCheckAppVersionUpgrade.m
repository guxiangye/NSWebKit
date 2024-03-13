//
//  SPCheckAppVersionUpgrade.m
//  SPKit
//
//  Created by 高鹏程 on 2023/3/7.
//

#import "SPCheckAppVersionUpgrade.h"
#import "SPMerchantHeaderInterceptor.h"
#import "SDPNetworkSessionManager.h"
#import "SPHttpManager.h"
#import "SPMerchantRequest.h"
#import "CheckVersionReq.h"
#import "SPNetCall.h"
#import "CheckVersionResp.h"
#import "SPCore.h"
@interface SPCheckAppVersionUpgrade ()
@property(nonatomic,copy)NSString *appType;
@property(nonatomic,assign)SPCheckAppVersionEnviromentType enviromentType;

@end
@implementation SPCheckAppVersionUpgrade
+ (id)sharedInstance {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        
        SPNetworkConfig *config = [SPNetworkConfig new];
        NSString *publicKey = [SPCheckAppVersionUpgrade getPublicKey];
        SPMerchantHeaderInterceptor *interceptor = [[SPMerchantHeaderInterceptor alloc]initWithPublicKey:publicKey];

        config.interceptors = @[interceptor];
        [[SPHttpManager sharedInstance]registerConfig:config baseURL:[SPCheckAppVersionUpgrade getBaseURL]];
    });
    return _instance;
}
+(NSString *)getBaseURL{
    NSString *serverUrl = @"";
    
    switch ([SPCore sharedInstance].enviromentType) {
        case SPEnviromentTest:
            serverUrl =@"https://zqbtest.shengpay.com";
            break;
        case SPEnviromentPreProd:
            serverUrl = @"https://prezqb.shengpay.com";
            break;
        case SPEnviromentProd:
            serverUrl = @"https://zqb.shengpay.com";
            break;
            
        default:
            break;
    }
    return serverUrl;
}
+(NSString *)getPublicKey{
    NSString *publicKey = nil;
    switch ([SPCore sharedInstance].enviromentType) {
        case SPEnviromentTest:
            publicKey =@"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAr+ChYL+xMhG2WAIvx+fdJyl475a5+TnM80fmNRN7BV0lteFAtDscXzxPbIoXv9QMbDJIjotxucDViMv1LjyAtdhZ2HVNYCvvpqdjpwyI9NRkTCDUL4tF0CImat8099c7CCOf6xZLmGPlpsnsLTrQQEiSOX2J60a/WJAQpSsA1eWQ4zHDgpgFDLE74+Xrv7O4Z3qG6KSMNwUr/ttl9JqlEtQrUarS+1+ywfYcr4GxB74EWXg2olh4vzJg94QWhlnTR3zmQ+nXZQFaCv8eqhg3Z7vw3JTs0swDxM7g3Y1ZzPjjkc1pcTcdmwDLmqvbtcziFYP5z2iZFiUHKbrwMooRRwIDAQAB";
            break;
        case SPEnviromentPreProd:
            publicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCMIeMHB3fpp4RWIXjAt+N9Zz4zVoN0blg2wuVNZE3z+qJsQXY0HUQhK27mrmpUOaLFBNDYv2Axk1hRRyoy687FRgnoRlTQJ4G0JZi5SHeZK3um2nCB77P+K2H3Ldjofkg+Q25sH8KneVI0FIBwHBBXzD83TMT2dvfUugPRr34Q6wIDAQAB";
            break;
        case SPEnviromentProd:
            publicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCMIeMHB3fpp4RWIXjAt+N9Zz4zVoN0blg2wuVNZE3z+qJsQXY0HUQhK27mrmpUOaLFBNDYv2Axk1hRRyoy687FRgnoRlTQJ4G0JZi5SHeZK3um2nCB77P+K2H3Ldjofkg+Q25sH8KneVI0FIBwHBBXzD83TMT2dvfUugPRr34Q6wIDAQAB";
            break;
            
        default:
            break;
    }
    return publicKey;
}
+(void)setCheckAppVersionEnviromentType:(SPCheckAppVersionEnviromentType)enviromentType{
    SPCheckAppVersionUpgrade *checkAppVersion = [SPCheckAppVersionUpgrade sharedInstance];
    checkAppVersion.enviromentType =enviromentType;
}
+(void)checkAppVersionWithAppType:(NSString *)appType{
    SPCheckAppVersionUpgrade *checkAppVersion = [SPCheckAppVersionUpgrade sharedInstance];
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
    
    SPNetCall<CheckVersionResp*>*call = [req buildNetCall];
    [call sendAsync:^(SPNetResponse<CheckVersionResp *> * _Nonnull response) {

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
