//
//  NSNetworkInterceptor.m
//  NSNetwork
//
//  Created by Neil on 2021/3/10.
//

#import "NSNetworkInterceptor.h"

@implementation NSNetworkRequestOptions
-(instancetype)init{
    if (self = [super init]) {
        self.header = @{}.mutableCopy;
        self.extra = @{}.mutableCopy;
    }
    return self;
}



- (BOOL)needRetry {
    return self.retryCount > 0;
}

@end
@implementation NSNetworkResponseOptions

@end
@implementation NSNetworkInterceptor
- (NSNetworkRequestOptions *)onRequest:(NSNetworkRequestOptions *)options {
    return options;
}

- (NSNetworkResponseOptions *)onResponse:(NSNetworkResponseOptions *)options {
    return options;
}

@end
