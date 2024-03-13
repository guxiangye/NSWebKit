//
//  CheckVersionReq.h
//  NSKit
//
//  Created by Neil on 2023/5/5.
//

#import <Foundation/Foundation.h>
#import "NSMerchantRequest.h"
NS_ASSUME_NONNULL_BEGIN

@interface CheckVersionReq : NSMerchantRequest
@property(nonatomic,copy)NSString *appType;
@property(nonatomic,copy)NSString *currentVersionName;
@property(nonatomic,copy)NSString *osPlatform;


@end

NS_ASSUME_NONNULL_END
