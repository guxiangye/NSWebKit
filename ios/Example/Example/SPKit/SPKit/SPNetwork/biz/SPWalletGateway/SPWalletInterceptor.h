//
//  SDPNetworkHeaderInterceptor.h
//  SDPNetwork_Example
//
//  Created by 高鹏程 on 2021/3/11.
//  Copyright © 2021 高鹏程. All rights reserved.
//

#import "SDPNetworkInterceptor.h"

#define SPNetworkGetTicketPath    @"/getTicket"

NS_ASSUME_NONNULL_BEGIN

@interface SPWalletInterceptor : SDPNetworkInterceptor


-(SPWalletInterceptor *)initWithPrivateKey:(NSString *)privateKey appId:(NSString *)appid;
@end

NS_ASSUME_NONNULL_END
