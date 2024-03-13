//
//  SDPSecurityPolicy.h
//  SDPNetwork
//
//  Created by 高鹏程 on 2021/3/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDPSecurityPolicy : NSObject
+ (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(NSString *)domain;
@end

NS_ASSUME_NONNULL_END
