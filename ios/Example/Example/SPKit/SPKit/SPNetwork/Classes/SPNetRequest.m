//
//  SPBaseNetRequest.m
//  SPKit
//
//  Created by 高鹏程 on 2023/3/7.
//

#import "SPNetCallImp.h"
#import "SPNetRequest.h"
@implementation SPNetRequest

- (nonnull id)buildNetCall {
    return [[SPNetCallImp alloc]initWithRequest:self];
}

- (nonnull NSString *)getBaseURL {
    return @"";
}

- (nonnull NSString *)getHttpMethod {
    return @"POST";
}

- (nonnull NSString *)getOperation {
    return @"";
}

- (NSString *)getContentType {
    return @"application/x-www-form-urlencoded";
}

@end
