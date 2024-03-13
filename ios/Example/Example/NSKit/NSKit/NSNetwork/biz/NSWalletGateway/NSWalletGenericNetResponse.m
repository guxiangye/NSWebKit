//
//  NSMerchantGenericNetResponse.m
//  NSKit
//
//  Created by Neil on 2023/5/6.
//

#import "NSWalletGenericNetResponse.h"

@implementation NSWalletGenericNetResponse

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
