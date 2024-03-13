//
//  NSNetworkHeaderInterceptor.h
//  NSNetwork_Example
//
//  Created by Neil on 2021/3/11.
//  Copyright © 2021 Neil. All rights reserved.
//

#import "NSNetworkInterceptor.h"

#define NSNetworkGetTicketPath    @"/getTicket"

NS_ASSUME_NONNULL_BEGIN

@interface NSWalletInterceptor : NSNetworkInterceptor


-(NSWalletInterceptor *)initWithPrivateKey:(NSString *)privateKey appId:(NSString *)appid;
@end

NS_ASSUME_NONNULL_END
