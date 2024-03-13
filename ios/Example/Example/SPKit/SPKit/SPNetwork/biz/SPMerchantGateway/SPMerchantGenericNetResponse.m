//
//  SPMerchantGenericNetResponse.m
//  SPKit
//
//  Created by 高鹏程 on 2023/5/6.
//

#import "SPMerchantGenericNetResponse.h"

@implementation SPMerchantGenericNetResponse

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
