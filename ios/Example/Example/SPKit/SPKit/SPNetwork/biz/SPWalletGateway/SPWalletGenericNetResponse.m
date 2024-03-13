//
//  SPMerchantGenericNetResponse.m
//  SPKit
//
//  Created by 高鹏程 on 2023/5/6.
//

#import "SPWalletGenericNetResponse.h"

@implementation SPWalletGenericNetResponse

-(NSString *)getCode{
    return self.errorCode;
}
-(NSString *)getMessage{
    return self.errorCodeDes;
}

-(BOOL)isSuccessful{
    return [self.resultCode isEqualToString:@"SUCCESS"];
}
-(id)getResponseData{

    return self.resultObject;
}

@end
