//
//  NSMerchantRequest.m
//  NSKit
//
//  Created by Neil on 2023/3/7.
//

#import "NSMerchantRequest.h"
#import "NSMerchantNetCallImp.h"
@implementation NSMerchantRequest

- (NSString *)getContentType {
    return @"application/json";
}

-(NSNetCall *)buildNetCall{
    return [[NSMerchantNetCallImp alloc]initWithRequest:self];
}
@end
