//
//  CheckVersionReq.m
//  SPKit
//
//  Created by 高鹏程 on 2023/5/5.
//

#import "CheckVersionReq.h"
#import "CheckVersionResp.h"
#import "SPCheckAppVersionUpgrade.h"
@implementation CheckVersionReq


-(NSString *)getOperation{
    return @"/cp-bff-promoter/v1/bff/promoter/checkVersion";
}
-(NSString *)getBaseURL{
    return [SPCheckAppVersionUpgrade getBaseURL];
}
-(NSString *)getHttpMethod{
    return @"POST";
}
-(Class)getResponseClass{
    return CheckVersionResp.class;
}

@end
