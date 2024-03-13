//
//  NSBaseNetRequest.m
//  NSKit
//
//  Created by Neil on 2023/3/7.
//

#import "NSNetCallImp.h"
#import "NSNetRequest.h"
@implementation NSNetRequest

- (nonnull id)buildNetCall {
    return [[NSNetCallImp alloc]initWithRequest:self];
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
