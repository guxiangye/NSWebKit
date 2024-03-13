//
//  SPHttpManager.h
//  SPKit
//
//  Created by 高鹏程 on 2023/5/5.
//

#import <Foundation/Foundation.h>
#import "SPNetworkConfig.h"
#import "SPSingleHttpToolBox.h"
NS_ASSUME_NONNULL_BEGIN

@interface SPHttpManager : NSObject
+ (SPHttpManager *)sharedInstance;
- (void)registerConfig:(SPNetworkConfig *)config baseURL:(NSString *)baseURL;
- (nullable SPSingleHttpToolBox *)getHttpToolBox:(NSString *)baseURL;
@end

NS_ASSUME_NONNULL_END
