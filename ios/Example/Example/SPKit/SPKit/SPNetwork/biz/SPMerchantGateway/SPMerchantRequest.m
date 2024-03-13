//
//  SPMerchantRequest.m
//  SPKit
//
//  Created by 高鹏程 on 2023/3/7.
//

#import "SPMerchantRequest.h"
#import "SPMerchantNetCallImp.h"
@implementation SPMerchantRequest

- (NSString *)getContentType {
    return @"application/json";
}

-(SPNetCall *)buildNetCall{
    return [[SPMerchantNetCallImp alloc]initWithRequest:self];
}
@end
