//
//  NSNetworkHeaderInterceptor.h
//  NSNetwork_Example
//
//  Created by Neil on 2021/3/11.
//  Copyright © 2021 Neil. All rights reserved.
//

#import "NSNetworkInterceptor.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSMerchantHeaderInterceptor : NSNetworkInterceptor

-(NSMerchantHeaderInterceptor *)initWithPublicKey:(NSString *)publicKey;

- (NSDictionary *)encryptAndCalculateMac:(NSDictionary *)paramDic;

@end

NS_ASSUME_NONNULL_END
