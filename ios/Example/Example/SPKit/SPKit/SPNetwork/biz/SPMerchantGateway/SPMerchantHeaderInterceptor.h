//
//  SDPNetworkHeaderInterceptor.h
//  SDPNetwork_Example
//
//  Created by 高鹏程 on 2021/3/11.
//  Copyright © 2021 高鹏程. All rights reserved.
//

#import "SDPNetworkInterceptor.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPMerchantHeaderInterceptor : SDPNetworkInterceptor

-(SPMerchantHeaderInterceptor *)initWithPublicKey:(NSString *)publicKey;

- (NSDictionary *)encryptAndCalculateMac:(NSDictionary *)paramDic;

@end

NS_ASSUME_NONNULL_END
