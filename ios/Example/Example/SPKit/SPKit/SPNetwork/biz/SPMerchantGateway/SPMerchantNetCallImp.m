//
//  SPGatewaryAPI1NetCallImp.m
//  SPKit
//
//  Created by 高鹏程 on 2023/3/7.
//

#import "SPMerchantNetCallImp.h"
#import "SPMerchantGenericNetResponse.h"
#import "NSObject+YYModel.h"
@implementation SPMerchantNetCallImp
-(instancetype)initWithRequest:(id<SPINetRequest>)request{
    if (self = [super initWithRequest:request]) {
        
    }
    return self;
}

-(SPNetResponse*)converDataToModel:(id)responseData cls:(Class)class{
    SPMerchantGenericNetResponse* merchantResponse = [SPMerchantGenericNetResponse modelWithDictionary:responseData];
    SPNetResponse *response = [SPNetResponse new];
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
