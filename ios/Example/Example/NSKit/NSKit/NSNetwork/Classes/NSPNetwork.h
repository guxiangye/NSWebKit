//
//  NSNetwork.h
//  NSKit
//
//  Created by Neil on 2023/5/5.
//

#import <Foundation/Foundation.h>
#import "NSNetworkConfig.h"
NS_ASSUME_NONNULL_BEGIN

@interface NSPNetwork : NSObject


+(void)registerConfig:(NSNetworkConfig *)config baseURL:(NSString*)baseURL;

@end

NS_ASSUME_NONNULL_END
