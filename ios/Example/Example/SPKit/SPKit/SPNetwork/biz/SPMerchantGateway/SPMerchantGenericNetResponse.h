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

@interface SPMerchantGenericNetResponse : NSObject<SPINetResponse>

@property(nonatomic,copy)NSString *errorCode;
@property(nonatomic,copy)NSString *errorMsg;
@property(assign,assign)BOOL success;

@property(nonatomic,strong)NSDictionary * data;

@end

NS_ASSUME_NONNULL_END
