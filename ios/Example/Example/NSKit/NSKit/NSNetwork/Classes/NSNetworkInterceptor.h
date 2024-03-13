//
//  NSNetworkInterceptor.h
//  NSNetwork
//
//  Created by Neil on 2021/3/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNetworkRequestOptions : NSObject
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

@interface NSNetworkResponseOptions : NSObject
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSNetworkRequestOptions *requestOptions;

@end
@interface NSNetworkInterceptor : NSObject

- (NSNetworkRequestOptions *)onRequest:(NSNetworkRequestOptions *)options;

- (NSNetworkResponseOptions *)onResponse:(NSNetworkResponseOptions *)options;

@end

NS_ASSUME_NONNULL_END
