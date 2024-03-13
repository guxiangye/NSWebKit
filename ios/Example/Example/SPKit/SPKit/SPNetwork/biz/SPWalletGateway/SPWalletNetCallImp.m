//
//  SPGatewaryAPI1NetCallImp.m
//  SPKit
//
//  Created by 高鹏程 on 2023/3/7.
//

#import "NSObject+YYModel.h"
#import "SPWalletGenericNetResponse.h"
#import "SPWalletNetCallImp.h"
@implementation SPWalletNetCallImp
- (instancetype)initWithRequest:(id<SPINetRequest>)request {
    if (self = [super initWithRequest:request]) {
    }

    return self;
}

- (SPNetResponse *)converDataToModel:(id)responseData cls:(Class)class {
    SPWalletGenericNetResponse *walletResponse = [SPWalletGenericNetResponse modelWithDictionary:responseData];
    SPNetResponse *response = [SPNetResponse new];

    response.message = [walletResponse getMessage];
    response.code = [walletResponse getCode];
    response.isSuccessful = [walletResponse isSuccessful];

    if (class) {
        response.responseData = [class modelWithDictionary:[walletResponse getResponseData]];
    } else {
        response.responseData = [walletResponse getResponseData];
    }

    return response;
}

@end
