//
//  NSGatewaryAPI1NetCallImp.m
//  NSKit
//
//  Created by Neil on 2023/3/7.
//

#import "NSObject+YYModel.h"
#import "NSWalletGenericNetResponse.h"
#import "NSWalletNetCallImp.h"
@implementation NSWalletNetCallImp
- (instancetype)initWithRequest:(id<NSINetRequest>)request {
    if (self = [super initWithRequest:request]) {
    }

    return self;
}

- (NSNetResponse *)converDataToModel:(id)responseData cls:(Class)class {
    NSWalletGenericNetResponse *walletResponse = [NSWalletGenericNetResponse modelWithDictionary:responseData];
    NSNetResponse *response = [NSNetResponse new];

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
