//
//  SPMerchantGenericNetResponse.h
//  SPKit
//
//  Created by 高鹏程 on 2023/5/6.
//

#import <Foundation/Foundation.h>
#import "SPNetProtocol.h"
#import "SPNetResponse.h"
NS_ASSUME_NONNULL_BEGIN

@interface SPWalletGenericNetResponse : NSObject<SPINetResponse>

@property(nonatomic,copy)NSString *errorCode;
@property(nonatomic,copy)NSString *errorCodeDes;
@property(nonatomic,copy)NSString *resultCode;

@property(nonatomic,strong)NSDictionary * resultObject;

@end

NS_ASSUME_NONNULL_END
