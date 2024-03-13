//
//  NSNetworkSessionManager.m
//  NSNetwork
//
//  Created by Neil on 2021/3/10.
//

#import "NSNetworkSessionManager.h"
#import "NSSecurityPolicy.h"
#import "NSIPDirect.h"
#pragma mark -
NSString * NNSercentEscapedStringFromString(NSString *string)
{
    static NSString *const kAFCharactersGeneralDelimitersToEncode = @":#[]@";  // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString *const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";

    NSMutableCharacterSet *allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];

    // FIXME: https://github.com/AFNetworking/AFNetworking/pull/3028
    // return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];

    static NSUInteger const batchSize = 50;

    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;

    while (index < string.length) {
        NSUInteger length = MIN(string.length - index, batchSize);
        NSRange range = NSMakeRange(index, length);

        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [string rangeOfComposedCharacterSequencesForRange:range];

        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];

        index += range.length;
    }

    return escaped;
}

@interface NSQueryStringPair : NSObject
@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (instancetype)initWithField:(id)field value:(id)value;

- (NSString *)URLEncodedStringValue;
@end

@implementation NSQueryStringPair

- (instancetype)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.field = field;
    self.value = value;

    return self;
}

- (NSString *)URLEncodedStringValue {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return NNSercentEscapedStringFromString([self.field description]);
    } else {
        return [NSString stringWithFormat:@"%@=%@", NNSercentEscapedStringFromString([self.field description]), NNSercentEscapedStringFromString([self.value description])];
    }
}

@end
FOUNDATION_EXPORT NSArray * NSQueryStringPairsFromDictionary(NSDictionary *dictionary);
FOUNDATION_EXPORT NSArray * NSQueryStringPairsFromKeyAndValue(NSString *key, id value);
NSString * NSQueryStringFromParameters(NSDictionary *parameters)
{
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (NSQueryStringPair *pair in NSQueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:[pair URLEncodedStringValue]];
    }

    return [mutablePairs componentsJoinedByString:@"&"];
}

NSArray * NSQueryStringPairsFromDictionary(NSDictionary *dictionary)
{
    return NSQueryStringPairsFromKeyAndValue(nil, dictionary);
}

NSArray * NSQueryStringPairsFromKeyAndValue(NSString *key, id value)
{
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];

    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue = dictionary[nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:NSQueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:NSQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray:NSQueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[NSQueryStringPair alloc] initWithField:key value:value]];
    }

    return mutableQueryStringComponents;
}

@interface NSNetworkSessionManager ()<NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>
@property (readwrite, nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (readwrite, nonatomic, strong) NSOperationQueue *operationQueue;
@property (readwrite, nonatomic, strong) NSURLSession *session;
@property (readwrite, nonatomic, strong) NSURL *baseURL;
@property (readwrite, nonatomic, strong) dispatch_queue_t requestHeaderModificationQueue;
@property (readwrite, nonatomic, strong) NSMutableDictionary *mutableHTTPRequestHeaders;
@property (nonatomic, strong) NSArray<NSNetworkInterceptor *> *interceptors;
@property (nonatomic, strong) NSMutableDictionary *ipDirectInfo;
@end

@implementation NSNetworkSessionManager
- (instancetype)initWithBaseURL:(NSURL *)url {
    return [self initWithBaseURL:url interpectors:nil];
}

- (instancetype)initWithBaseURL:(NSURL *)url interpectors:(nullable NSArray  <NSNetworkInterceptor *> *)interceptors {
    if (self = [super init]) {
        self.baseURL = url;
        self.interceptors = interceptors;
        self.ipDirectInfo = [NSMutableDictionary new];
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
        self.mutableHTTPRequestHeaders = [NSMutableDictionary dictionary];
        self.requestHeaderModificationQueue = dispatch_queue_create("requestHeaderModificationQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}


#pragma mark -
-(NSURLSessionConfiguration *)sessionConfiguration{
    if (_sessionConfiguration == nil) {
        _sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    _sessionConfiguration.timeoutIntervalForRequest  = self.timeoutSeconds == 0 ? 15 :self.timeoutSeconds;
    return _sessionConfiguration;
}
- (NSURLSession *)session {
    @synchronized (self) {
        if (!_session) {
            _session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration delegate:self delegateQueue:self.operationQueue];
            
        }
    }
    return _session;
}

- (NSDictionary *)HTTPRequestHeaders {
    NSDictionary __block *value;
    dispatch_sync(self.requestHeaderModificationQueue, ^{
        value = [NSDictionary dictionaryWithDictionary:self.mutableHTTPRequestHeaders];
    });
    return value;
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    dispatch_barrier_sync(self.requestHeaderModificationQueue, ^{
        [self.mutableHTTPRequestHeaders setValue:value forKey:field];
    });
}

- (NSString *)valueForHTTPHeaderField:(NSString *)field {
    NSString __block *value;
    dispatch_sync(self.requestHeaderModificationQueue, ^{
        value = [self.mutableHTTPRequestHeaders valueForKey:field];
    });
    return value;
}

- (NSURLRequest *)handelWithRequestOptions:(NSNetworkRequestOptions *)options {
    NSMutableURLRequest *request = nil;
    NSURL *url = [NSURL URLWithString:options.path relativeToURL:self.baseURL];
    if (options.request == nil) {
        __block NSNetworkRequestOptions *op = options;
        [self.interceptors enumerateObjectsUsingBlock:^(NSNetworkInterceptor *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            op = [obj onRequest:op];
        }];

        request = [[NSMutableURLRequest alloc]initWithURL:url];
        if (op.header[@"Content-Type"] == nil) {
            op.header[@"Content-Type"] = @"application/json";
        }
        request.HTTPMethod = op.method;
        [options.header enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
            [request setValue:obj forHTTPHeaderField:key];
        }];
        if ([options.header[@"Content-Type"] containsString:@"application/json"]) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:op.parameters options:NSUTF8StringEncoding error:nil];
            [request setHTTPBody:jsonData];
        } else {
            NSString *bodyStr = NSQueryStringFromParameters(op.parameters);
            [request setHTTPBody:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
        }
    } else {
        request = options.request.mutableCopy;
        if (options.useIPDirect) {
            NSString *host = url.host;
            NSString *ip = [NSIPDirect getIPWithHostName:host];
            if (ip.length > 0) {
                self.ipDirectInfo[ip] = host;
                url = [NSURL URLWithString:[url.absoluteString stringByReplacingOccurrencesOfString:host withString:ip]];
                request.URL = url;
                [request setValue:host forHTTPHeaderField:@"host"];
            }
        }
    }

    options.request = request;

    return request;
}

- (id)handelWithResponseOptions:(NSNetworkResponseOptions *)options {
    __block NSNetworkResponseOptions *op = options;
    [self.interceptors enumerateObjectsUsingBlock:^(NSNetworkInterceptor *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        op = [obj onResponse:op];
    }];

    return op;
}

//-(id)responseWithOp

- (NSURLSessionDataTask *)POST:(NSString *)path parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [self dataTaskWithMethod:@"POST" path:path parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask *)dataTaskWithMethod:(NSString *)method path:(NSString *)path parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSNetworkRequestOptions *options = [NSNetworkRequestOptions new];
    options.method = method;
    options.path = path;
    options.parameters = [NSMutableDictionary dictionaryWithDictionary:parameters];


    return [self dataTaskWithNetworkRequestOptions:options success:success failure:failure];
}

- (NSURLSessionDataTask *)dataTaskWithNetworkRequestOptions:(NSNetworkRequestOptions *)requestOptions success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSURLRequest *request = [self handelWithRequestOptions:requestOptions];

    __block NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        NSNetworkResponseOptions *responseOptions = [NSNetworkResponseOptions new];
        responseOptions.data = data;
        responseOptions.response = response;
        responseOptions.error = error;
        responseOptions.requestOptions = requestOptions;

        responseOptions = [self handelWithResponseOptions:responseOptions];
        if (responseOptions.error && responseOptions.requestOptions.needRetry) {
            responseOptions.requestOptions.retryCount --;
            [self dataTaskWithNetworkRequestOptions:requestOptions success:success failure:failure];
        } else {
            if (responseOptions.error && failure) {
                failure(dataTask, responseOptions.error);
            } else if (success) {
                success(dataTask, responseOptions.data);
            }
        }
    }];

    [dataTask resume];
    return dataTask;
}

#pragma mark -- NSURLSessionDelegate
- (void)   URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
    completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *_Nullable credential))completionHandler {
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;

    NSString *domain = challenge.protectionSpace.host;
    if (self.ipDirectInfo[domain]) {
        //ip直连的时候替换ip为原本的域名去校验证书
        domain = self.ipDirectInfo[domain];
    }
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([NSSecurityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:domain]) {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            if (credential) {
                disposition = NSURLSessionAuthChallengeUseCredential;
            } else {
                disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            }
        } else {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    }

    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

@end
