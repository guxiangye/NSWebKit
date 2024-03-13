//
//  SDPNetworkSessionManager.h
//  SDPNetwork
//
//  Created by 高鹏程 on 2021/3/10.
//

#import <Foundation/Foundation.h>
#import "SDPNetworkInterceptor.h"
NS_ASSUME_NONNULL_BEGIN

@interface SDPNetworkSessionManager : NSObject
@property(nonatomic,assign)BOOL debug;
@property(nonatomic,assign)NSInteger timeoutSeconds;
@property (readonly, nonatomic, strong) NSURLSession *session;
@property (readonly, nonatomic, strong) NSOperationQueue *operationQueue;

- (instancetype)initWithBaseURL:(NSURL *)url;
- (instancetype)initWithBaseURL:(NSURL *)url interpectors:(nullable NSArray<SDPNetworkInterceptor *> * )interceptors;

- (NSURLSessionDataTask *)POST:(NSString *)path parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *task, id responseObjcect))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask *)dataTaskWithMethod:(NSString *)method path:(NSString *)path parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *task, id responseObjcect))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
- (NSURLSessionDataTask *)dataTaskWithNetworkRequestOptions:(SDPNetworkRequestOptions *)requestOptions success:(void (^)(NSURLSessionDataTask * task, id responseData))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@end

NS_ASSUME_NONNULL_END
