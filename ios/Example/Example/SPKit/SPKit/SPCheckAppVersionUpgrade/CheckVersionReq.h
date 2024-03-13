//
//  CheckVersionReq.h
//  SPKit
//
//  Created by 高鹏程 on 2023/5/5.
//

#import <Foundation/Foundation.h>
#import "SPMerchantRequest.h"
NS_ASSUME_NONNULL_BEGIN

@interface CheckVersionReq : SPMerchantRequest
@property(nonatomic,copy)NSString *appType;
@property(nonatomic,copy)NSString *currentVersionName;
@property(nonatomic,copy)NSString *osPlatform;


@end

NS_ASSUME_NONNULL_END
