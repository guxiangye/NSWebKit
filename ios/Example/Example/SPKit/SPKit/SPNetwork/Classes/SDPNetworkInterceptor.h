//
//  SDPNetworkInterceptor.h
//  SDPNetwork
//
//  Created by 高鹏程 on 2021/3/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDPNetworkRequestOptions : NSObject
@property (nonatomic, copy) NSString *baseURL;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSMutableDictionary *header;
@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, strong) NSMutableDictionary *extra;
@property (nonatomic, strong) NSURLRequest *request;
///使用IP直连
@property (nonatomic, assign) BOOL useIPDirect;
///需要重试
@property (nonatomic, readonly) BOOL needRetry;
@property (nonatomic, assign) NSUInteger retryCount;
@end

@interface SDPNetworkResponseOptions : NSObject
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) SDPNetworkRequestOptions *requestOptions;

@end
@interface SDPNetworkInterceptor : NSObject

- (SDPNetworkRequestOptions *)onRequest:(SDPNetworkRequestOptions *)options;

- (SDPNetworkResponseOptions *)onResponse:(SDPNetworkResponseOptions *)options;

@end

NS_ASSUME_NONNULL_END
