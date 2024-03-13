//
//  SPNetwork.h
//  SPKit
//
//  Created by 高鹏程 on 2023/5/5.
//

#import <Foundation/Foundation.h>
#import "SPNetworkConfig.h"
NS_ASSUME_NONNULL_BEGIN

@interface SPNetwork : NSObject


+(void)registerConfig:(SPNetworkConfig *)config baseURL:(NSString*)baseURL;

@end

NS_ASSUME_NONNULL_END
