//
//  SPSingleHttpToolBox.h
//  SPKit
//
//  Created by 高鹏程 on 2023/5/6.
//

#import <Foundation/Foundation.h>
#import "SDPNetworkSessionManager.h"
#import "SPNetworkConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPSingleHttpToolBox : NSObject


@property (nonatomic, strong) SPNetworkConfig *config;
@property (nonatomic, strong) SDPNetworkSessionManager *session;
- (instancetype)initWithConfig:(SPNetworkConfig *)config baseURL:(NSString *)baseURL;

@end

NS_ASSUME_NONNULL_END
