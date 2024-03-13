//
//  NSHttpManager.h
//  NSKit
//
//  Created by Neil on 2023/5/5.
//

#import <Foundation/Foundation.h>
#import "NSNetworkConfig.h"
#import "NSSingleHttpToolBox.h"
NS_ASSUME_NONNULL_BEGIN

@interface NSHttpManager : NSObject
+ (NSHttpManager *)sharedInstance;
- (void)registerConfig:(NSNetworkConfig *)config baseURL:(NSString *)baseURL;
- (nullable NSSingleHttpToolBox *)getHttpToolBox:(NSString *)baseURL;
@end

NS_ASSUME_NONNULL_END
