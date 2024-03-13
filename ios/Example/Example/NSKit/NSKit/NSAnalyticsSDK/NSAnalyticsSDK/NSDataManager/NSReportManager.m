//
//  NSReportManager.m
//
//  Created by jhon on 2020/5/18.
//  Copyright © 2020 shengpay. All rights reserved.
//

#import "NSReportManager.h"
#import "NSDBManager.h"
#import "NSEncryptManager.h"
#import "NSAnalyticsReachability.h"

/** 集成测试  */
#define kBatchUrlTest @"https://rdtgatewaytest.shengpay.com/rdt-gateway/rest/message"
/** 生产环境 */
#define kBatchUrlPro @"https://rdtgateway.shengpay.com/rdt-gateway/rest/message"


@interface NSReportManager()<NSURLSessionDelegate>

@property (assign) BOOL isTest;//是否是集成测试环境
@property (assign) BOOL isProgress0;//数据库表0正在处理
@property (assign) BOOL isProgress1;//数据库表1正在处理
@property (assign) BOOL isProgress2;//数据库表2正在处理
@property (assign) BOOL isProgress3;//数据库表3正在处理
@property (nonatomic, strong) NSOperationQueue *uploadQueue0;//上报数据队列0
@property (nonatomic, strong) NSOperationQueue *uploadQueue1;//上报数据队列1
@property (nonatomic, strong) NSOperationQueue *uploadQueue2;//上报数据队列2
@property (nonatomic, strong) NSOperationQueue *uploadQueue3;//上报数据队列3

@end

@implementation NSReportManager

#pragma mark - 创建单例
+ (NSReportManager * _Nullable)sharedInstance{
    static dispatch_once_t onceToken;
    static NSReportManager *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [NSReportManager new];
    });
    return sharedInstance;
}

#pragma mark - 设置集成环境
- (void)setTestEnv:(BOOL)value {
    self.isTest = value;
}

#pragma mark - 上报数据队列
- (NSOperationQueue *)uploadQueue0 {
    if (_uploadQueue0 == nil) {
        _uploadQueue0 = [[NSOperationQueue alloc] init];
        _uploadQueue0.maxConcurrentOperationCount = 1;
    }
    return _uploadQueue0;
}

- (NSOperationQueue *)uploadQueue1 {
    if (_uploadQueue1 == nil) {
        _uploadQueue1 = [[NSOperationQueue alloc] init];
        _uploadQueue1.maxConcurrentOperationCount = 1;
    }
    return _uploadQueue1;
}

- (NSOperationQueue *)uploadQueue2 {
    if (_uploadQueue2 == nil) {
        _uploadQueue2 = [[NSOperationQueue alloc] init];
        _uploadQueue2.maxConcurrentOperationCount = 1;
    }
    return _uploadQueue2;
}

- (NSOperationQueue *)uploadQueue3 {
    if (_uploadQueue3 == nil) {
        _uploadQueue3 = [[NSOperationQueue alloc] init];
        _uploadQueue3.maxConcurrentOperationCount = 1;
    }
    return _uploadQueue3;
}

#pragma mark - 调度发起上报
-(void)dispatch:(NSUInteger)priority{
    switch (priority) {
        case 0:
            if (self.isProgress0 == NO) {
                [self.uploadQueue0 addOperationWithBlock:^{
                    [self strategyMatch:priority];
                }];
            }
            break;
        case 1:
            if (self.isProgress1 == NO) {
                [self.uploadQueue1 addOperationWithBlock:^{
                    [self strategyMatch:priority];
                }];
            }
            break;
        case 2:
            if (self.isProgress2 == NO) {
                [self.uploadQueue2 addOperationWithBlock:^{
                    [self strategyMatch:priority];
                }];
            }
            break;
        case 3:
            if (self.isProgress3 == NO) {
                [self.uploadQueue3 addOperationWithBlock:^{
                    [self strategyMatch:priority];
                }];
            }
            break;
        default:
            break;
    }
}

#pragma mark - 策略匹配
-(void)strategyMatch:(NSUInteger)priority{
    //0
    if ([[self networkStatus] isEqualToString:@"NG"] && priority == 0) {
        self.isProgress0 = YES;
        [self postGatherInfoWithPriority:priority withNum:10 withTimeInterval:5];
    }
    else if ([[self networkStatus] isEqualToString:@"WiFi"] && priority == 0) {
        self.isProgress0 = YES;
        [self postGatherInfoWithPriority:priority withNum:100 withTimeInterval:0];
    }
    //2
    else if ([[self networkStatus] isEqualToString:@"WiFi"] && priority == 2) {
        self.isProgress2 = YES;
        [self postGatherInfoWithPriority:priority withNum:100 withTimeInterval:60];
    }
    //3
    else if ([[self networkStatus] isEqualToString:@"WiFi"] && priority == 3) {
        self.isProgress3 = YES;
        [self postGatherInfoWithPriority:priority withNum:100 withTimeInterval:60];
    }
    //1
    else if ([[self networkStatus] isEqualToString:@"WiFi"] && priority == 1) {
        self.isProgress1 = YES;
        [self postGatherInfoWithPriority:priority withNum:100 withTimeInterval:0];
    }
    else if ([[self networkStatus] isEqualToString:@"NG"] && [[NSDBManager shareDataManager] queryGatherInfoNumWithPriority:priority] >= 50 && priority == 1) {
        self.isProgress1 = YES;
        [self postGatherInfoWithPriority:priority withNum:50 withTimeInterval:60];
    }
}

#pragma mark - 上报网络请求
-(void)postGatherInfoWithPriority:(NSUInteger)priority withNum:(NSInteger)num withTimeInterval:(NSInteger)seconds{
    NSURL *url = nil;
    if (self.isTest) {
        url = [NSURL URLWithString:kBatchUrlTest];
    }else {
        url = [NSURL URLWithString:kBatchUrlPro];
    }
    NSMutableArray *loadInfoArray = @[].mutableCopy;
    loadInfoArray = [[NSDBManager shareDataManager] getGatherInfoWithPriority:priority withNum:num];
    if (loadInfoArray.count == 0) {
        if (priority == 0) {
            self.isProgress0 = NO;
        }
        else if (priority == 1) {
            self.isProgress1 = NO;
        }
        else if (priority == 2) {
            self.isProgress2 = NO;
        }
        else if (priority == 3) {
            self.isProgress3 = NO;
        }
        return;
    }
    NSDictionary *params = @{@"clientId" : @"unifySdkAuto.shengpay.com",
                             @"clientType" : @"native",
                             @"content" : loadInfoArray,
                             @"certSerial" : @"abcd",
                             @"encryptType": @"1",
                             @"sign": @"8DA09AFFDB763B19F96667DD05CAAD8422",
                             @"timeStamp":[NSString stringWithFormat:@"%.0f",[NSDate date].timeIntervalSince1970 * 1000]
    };
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:self delegateQueue: [NSOperationQueue currentQueue]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:NULL];
    request.timeoutInterval = 60.0f;
    
    NSURLSessionDataTask *sessionDataTask = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *resultStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSDictionary *resultDic = [self dictionaryWithJsonString:resultStr];
        if ([resultDic[@"code"] isEqualToString:@"000000"]) {
            NSLog(@"上报成功");
            if (priority != 3) {
                [[NSDBManager shareDataManager] deleteGatherInfoWithPriority:priority withNum:loadInfoArray.count];
            }
        }
        //优先级4 成功或失败都删除
        if (priority == 3) {
            [[NSDBManager shareDataManager] deleteGatherInfoWithPriority:priority withNum:loadInfoArray.count];
        }
        
        //间隔上报
        if ([[NSDBManager shareDataManager] queryGatherInfoNumWithPriority:priority] > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self postGatherInfoWithPriority:priority withNum:num withTimeInterval:seconds];
            });
        }else{
            //当前上报结束，重置状态
            if (priority == 0) {
                self.isProgress0 = NO;
            }
            else if (priority == 1) {
                self.isProgress1 = NO;
            }
            else if (priority == 2) {
                self.isProgress2 = NO;
            }
            else if (priority == 3) {
                self.isProgress3 = NO;
            }
        }
        if (error) {
            NSLog(@"上报失败，error：%@",error);
        }
    }];
    
    [sessionDataTask resume];
}

//json转字典
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

//// https 证书处理
//- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
//    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
//    __block NSURLCredential *credential =nil;
//    
//    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
//        // 校验域名是否一致
//        if([NSEncryptManager verifyServerTrust:challenge.protectionSpace.serverTrust withDomain:challenge.protectionSpace.host]) {
//            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//            if(credential) {
//                disposition =NSURLSessionAuthChallengeUseCredential;
//            } else {
//                disposition =NSURLSessionAuthChallengePerformDefaultHandling;
//            }
//        } else {
//            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
//        }
//    }
//    
//    if (completionHandler) {
//        completionHandler(disposition, credential);
//    }
//}
#pragma mark - 网络状态判断
- (NSString *)networkStatus {
    NSString *network = nil;
    NSAnalyticsReachability *reachability = [NSAnalyticsReachability reachability];
    switch (reachability.status) {
        case NSAnalyticsReachabilityStatusNone:
            network = @"None";
            break;
        case NSAnalyticsReachabilityStatusWiFi:
            network = @"WiFi";
            break;
        case NSAnalyticsReachabilityStatusWWAN:
            network = @"NG";
            break;
        default:
            network = @"DefaultNone";
            break;
    }
    return network;
}

#pragma mark - 策略配置

+(NSString *)strategyRule{
    return @"{\"level1\":{\"nG\":{\"numberPer\":10,\"interval\":5},\"wifi\":{\"numberPer\":100,\"interval\":0}}\"level2\":{\"nG\":{\"numberPer\":50,\"interval\":60},\"wifi\":{\"numberPer\":100,\"interval\":0}}\"level3\":{\"wifi\":{\"numberPer\":100,\"interval\":60}}\"level4\":{\"wifi\":{\"numberPer\":100,\"interval\":60}}}";
}
@end
