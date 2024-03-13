//
//  NSMerchantGenericNetResponse.h
//  NSKit
//
//  Created by Neil on 2023/5/6.
//

#import <Foundation/Foundation.h>
#import "NSNetProtocol.h"
#import "NSNetResponse.h"
NS_ASSUME_NONNULL_BEGIN

@interface NSWalletGenericNetResponse : NSObject<NSINetResponse>

@property(nonatomic,copy)NSString *errorCode;
@property(nonatomic,copy)NSString *errorCodeDes;
@property(nonatomic,copy)NSString *resultCode;

@property(nonatomic,strong)NSDictionary * resultObject;

@end

NS_ASSUME_NONNULL_END
