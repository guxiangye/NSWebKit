//
//  SDPNetworkInterceptor.m
//  SDPNetwork
//
//  Created by 高鹏程 on 2021/3/10.
//

#import "SDPNetworkInterceptor.h"

@implementation SDPNetworkRequestOptions
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
@implementation SDPNetworkResponseOptions

@end
@implementation SDPNetworkInterceptor
- (SDPNetworkRequestOptions *)onRequest:(SDPNetworkRequestOptions *)options {
    return options;
}

- (SDPNetworkResponseOptions *)onResponse:(SDPNetworkResponseOptions *)options {
    return options;
}

@end
