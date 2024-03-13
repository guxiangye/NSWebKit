//
//  NSMerchantGenericNetResponse.m
//  NSKit
//
//  Created by Neil on 2023/5/6.
//

#import "NSMerchantGenericNetResponse.h"

@implementation NSMerchantGenericNetResponse

-(NSString *)getCode{
    return self.errorCode;
}
-(NSString *)getMessage{
    return self.errorMsg;
}

-(BOOL)isSuccessful{
    return self.success;
}
-(id)getResponseData{

    return self.data;
}

@end
