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

@interface NSMerchantGenericNetResponse : NSObject<NSINetResponse>

@property(nonatomic,copy)NSString *errorCode;
@property(nonatomic,copy)NSString *errorMsg;
@property(assign,assign)BOOL success;

@property(nonatomic,strong)NSDictionary * data;

@end

NS_ASSUME_NONNULL_END
