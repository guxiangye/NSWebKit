//
//  CheckVersionReq.m
//  NSKit
//
//  Created by Neil on 2023/5/5.
//

#import "CheckVersionReq.h"
#import "CheckVersionResp.h"
#import "NSCheckAppVersionUpgrade.h"
@implementation CheckVersionReq


-(NSString *)getOperation{
    return @"/cp-bff-promoter/v1/bff/promoter/checkVersion";
}
-(NSString *)getBaseURL{
    return [NSCheckAppVersionUpgrade getBaseURL];
}
-(NSString *)getHttpMethod{
    return @"POST";
}
-(Class)getResponseClass{
    return CheckVersionResp.class;
}

@end
