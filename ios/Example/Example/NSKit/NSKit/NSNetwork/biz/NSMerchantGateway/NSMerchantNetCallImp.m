//
//  NSGatewaryAPI1NetCallImp.m
//  NSKit
//
//  Created by Neil on 2023/3/7.
//

#import "NSMerchantNetCallImp.h"
#import "NSMerchantGenericNetResponse.h"
#import "NSObject+YYModel.h"
@implementation NSMerchantNetCallImp
-(instancetype)initWithRequest:(id<NSINetRequest>)request{
    if (self = [super initWithRequest:request]) {
        
    }
    return self;
}

-(NSNetResponse*)converDataToModel:(id)responseData cls:(Class)class{
    NSMerchantGenericNetResponse* merchantResponse = [NSMerchantGenericNetResponse modelWithDictionary:responseData];
    NSNetResponse *response = [NSNetResponse new];
    response.message = [merchantResponse getMessage];
    response.code = [merchantResponse getCode];
    response.isSuccessful = [merchantResponse isSuccessful];
    if (class) {
        response.responseData = [class modelWithDictionary:[merchantResponse getResponseData]];
    }
    else{
        response.responseData = [merchantResponse getResponseData];
    }
    
    return response;
}
@end
