//
//  NSSingleHttpToolBox.h
//  NSKit
//
//  Created by Neil on 2023/5/6.
//

#import <Foundation/Foundation.h>
#import "NSNetworkSessionManager.h"
#import "NSNetworkConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSSingleHttpToolBox : NSObject


@property (nonatomic, strong) NSNetworkConfig *config;
@property (nonatomic, strong) NSNetworkSessionManager *session;
- (instancetype)initWithConfig:(NSNetworkConfig *)config baseURL:(NSString *)baseURL;

@end

NS_ASSUME_NONNULL_END
