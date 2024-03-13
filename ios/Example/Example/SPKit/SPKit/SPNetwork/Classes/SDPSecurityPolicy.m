//
//  SDPSecurityPolicy.m
//  SDPNetwork
//
//  Created by 高鹏程 on 2021/3/12.
//

#import "SDPSecurityPolicy.h"
#import <AssertMacros.h>
@implementation SDPSecurityPolicy
+ (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(NSString *)domain {
    NSMutableArray *policies = [NSMutableArray array];
    [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
    BOOL isValid = NO;
    SecTrustResultType result;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    __Require_noErr_Quiet(SecTrustEvaluate(serverTrust, &result), _out);
#pragma clang diagnostic pop

    isValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);

 _out:
    return isValid;
}

@end
