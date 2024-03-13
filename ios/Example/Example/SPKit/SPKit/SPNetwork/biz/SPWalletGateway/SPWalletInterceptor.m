//
//  SDPNetworkHeaderInterceptor.m
//  SDPNetwork_Example
//
//  Created by 高鹏程 on 2021/3/11.
//  Copyright © 2021 高鹏程. All rights reserved.
//

#import "AESEncryptor.h"
#import "NSDictionary+YYAdd.h"
#import "NSObject+YYModel.h"
#import "NSString+SP.h"
#import "NSString+YYAdd.h"
#import "SDPSecurityRSA.h"
#import "SPHttpManager.h"
#import "SPNetCall.h"
#import "SPSingleHttpToolBox.h"
#import "SPWalletGenericNetResponse.h"
#import "SPWalletInterceptor.h"
#import "SPWalletRequest.h"

#define SPNetworkGetTicketVersion @"v1"




@interface SPWalletGetTicketReq : SPWalletRequest {
    NSString *_baseURL;
}
@property (nonatomic, copy) NSString *timestamp;
@property (nonatomic, copy) NSString *nonceStr;
@property (nonatomic, copy) NSString *sign;
@property (nonatomic, copy) NSString *apiVersion;
@end
@interface SPWalletGetTicketResp : NSObject
@property (nonatomic, copy) NSString *salt;
@property (nonatomic, copy) NSString *ticket;
@property (nonatomic, assign) NSInteger validPeriodSec;
@property (nonatomic, assign) NSUInteger ticketGotTime;
@end
@implementation SPWalletGetTicketReq

- (id)initWithBaseURL:(NSString *)baseURL {
    if (self = [super init]) {
        _baseURL = baseURL;
        self.apiVersion = SPNetworkGetTicketVersion;
    }

    return self;
}

- (NSString *)getOperation {
    return SPNetworkGetTicketPath;
}

- (NSString *)getBaseURL {
    return _baseURL;
}

- (Class)getResponseClass {
    return [SPWalletGetTicketResp class];
}

@end



@implementation SPWalletGetTicketResp



@end


@interface SPWalletInterceptor ()
@property (nonatomic, copy) NSString *privateKey;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, strong) SPWalletGetTicketResp *ticketInfo;


/// 是否正在请求ticket
@property (nonatomic, assign) BOOL isRequestTicketing;
@end

@implementation SPWalletInterceptor
- (SPWalletInterceptor *)initWithPrivateKey:(NSString *)privateKey appId:(nonnull NSString *)appid {
    if (self = [super init]) {
        self.privateKey = privateKey;
        self.appId = appid;
    }

    return self;
}

- (BOOL)isTicketVaild {
    return self.ticketInfo != nil &&  [[NSDate date] timeIntervalSince1970] * 1000 < self.ticketInfo.ticketGotTime + self.ticketInfo.validPeriodSec * 1000 * 0.95;
}

- (BOOL)isTicketWillExpire {
    return [self isTicketVaild ] && [[NSDate date] timeIntervalSince1970] * 1000 > self.ticketInfo.ticketGotTime + self.ticketInfo.validPeriodSec * 1000 * 0.8;
}

- (void)requestTikcetWithBaseURL:(NSString *)baseURL completion:(void (^)(SPNetResponse<SPWalletGetTicketResp *> *_Nonnull response))completionBlock {
    NSMutableDictionary *mutableParamDic = @{}.mutableCopy;
    NSString *randomKey = [NSString getRandomStringWithNum:22];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *timeStr = [NSString stringWithFormat:@"%.0f", timeInterval * 1000];

    mutableParamDic[@"timestamp"] = timeStr;
    mutableParamDic[@"nonceStr"] = randomKey;
    mutableParamDic[@"apiVersion"] = SPNetworkGetTicketVersion;


    NSArray *sortKeys = [mutableParamDic.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSMutableArray *keyValues = @[].mutableCopy;

    for (id key in sortKeys) {
        [keyValues addObject:[NSString stringWithFormat:@"%@=%@", key, mutableParamDic[key]]];
    }

    NSString *str = [keyValues componentsJoinedByString:@"&"];
    NSString *sign = [SDPSecurityRSA sign:str privateKey:self.privateKey];

    SPWalletGetTicketReq *ticketReq = [[SPWalletGetTicketReq alloc]initWithBaseURL:baseURL];
    ticketReq.timestamp = timeStr;
    ticketReq.nonceStr = randomKey;
    ticketReq.sign = sign;

    SPNetCall<SPWalletGetTicketResp *> *call = [ticketReq buildNetCall];

    call.retryCount = 3;
    [call sendAsync:^(SPNetResponse<SPWalletGetTicketResp *> *_Nonnull response) {
        if (response.isSuccessful) {
            self.ticketInfo = response.responseData;
            self.ticketInfo.ticketGotTime = [[NSDate date] timeIntervalSince1970] * 1000;
        } else {
        }

        if (completionBlock) {
            completionBlock(response);
        }
    }];
}

- (SDPNetworkRequestOptions *)onRequest:(SDPNetworkRequestOptions *)options {
    options.header[@"appid"] = self.appId ? : @"";
    options.header[@"ostype"] = @"2";
    options.header[@"deviceId"] = [[[UIDevice currentDevice] identifierForVendor] UUIDString] ? : @"null";

    if (![options.path hasSuffix:SPNetworkGetTicketPath]) {
        if (![self isTicketVaild]) {
            if (self.isRequestTicketing == NO) {
                self.isRequestTicketing = YES;
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

                [self requestTikcetWithBaseURL:options.baseURL
                                    completion:^(SPNetResponse<SPWalletGetTicketResp *> *_Nonnull response) {
                    self.isRequestTicketing = NO;
                    dispatch_semaphore_signal(semaphore);
                }];

                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            } else {
                //正在请求ticket 阻断等待
                while (self.isRequestTicketing == YES) {
                }
            }
        } else if ([self isTicketWillExpire]) {
            [self requestTikcetWithBaseURL:options.baseURL
                                completion:^(SPNetResponse<SPWalletGetTicketResp *> *_Nonnull response) {
            }];
        }

        NSMutableDictionary *param = options.parameters;
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
        NSString *timeStr = [NSString stringWithFormat:@"%.0f", timeInterval * 1000];
        param[@"_"] = timeStr;
        NSString *body = [param jsonStringEncoded];
        NSString *enData = [AESEncryptor aes256_encryptWithContent:body key:self.ticketInfo.salt];
        options.extra[@"salt"] = self.ticketInfo.salt ? : @"";
        options.parameters = @{
                @"param": [@{ @"enData": enData } jsonStringEncoded]
            }.mutableCopy;
        options.header[@"ticket"] = self.ticketInfo.ticket ? : @"";
    }

    return [super onRequest:options];
}

- (SDPNetworkResponseOptions *)onResponse:(SDPNetworkResponseOptions *)options {
    if (options.error) {
//        int retryCount = [options.requestOptions.extra[@"retryCount"]intValue];
//
//        if (retryCount < 1) {
//            retryCount++;
//            options.requestOptions.extra[@"retryCount"] = [NSNumber numberWithInt:retryCount];
//            options.requestOptions.useIPDirect = NO;
//            options.requestOptions.ret = YES;
//        } else {
//        }
    } else {
        NSHTTPURLResponse *httpRespone = (NSHTTPURLResponse *)options.response;
        NSDictionary *allHeaderFields = httpRespone.allHeaderFields;
        BOOL encrypt = [allHeaderFields[@"encrypt"]boolValue];

        if (encrypt) {
            if ([options.requestOptions.path isEqualToString:SPNetworkGetTicketPath]) {
                NSError *parseError;
                id responseObject = [NSJSONSerialization JSONObjectWithData:options.data
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&parseError];
                NSString *ticketInfo = responseObject[@"resultObject"];
                NSString *decryptStr = [SDPSecurityRSA decrypt:ticketInfo privateKey:self.privateKey];
                NSDictionary *resultObject = [decryptStr jsonValueDecoded];
                NSMutableDictionary *newResponseObject = [NSMutableDictionary dictionaryWithDictionary:responseObject];
                newResponseObject[@"resultObject"] = resultObject;
                responseObject = newResponseObject;
                options.data = responseObject;
            } else {
                NSString *salt = options.requestOptions.extra[@"salt"];
                NSString *encryptStr = [[NSString alloc]initWithData:options.data encoding:NSUTF8StringEncoding];
                options.data = [[AESEncryptor aes256_decryptWithContent:encryptStr key:salt]jsonValueDecoded];
            }
        }
        else{
            NSError *parseError;
            id responseObject = [NSJSONSerialization JSONObjectWithData:options.data
                                                                options:NSJSONReadingMutableLeaves
                                                                  error:&parseError];
            options.data = responseObject;
        }
    }

    return [super onResponse:options];
}

@end
