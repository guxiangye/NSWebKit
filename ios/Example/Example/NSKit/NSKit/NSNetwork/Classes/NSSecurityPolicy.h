//
//  NSSecurityPolicy.h
//  NSNetwork
//
//  Created by Neil on 2021/3/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSSecurityPolicy : NSObject
+ (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(NSString *)domain;
@end

NS_ASSUME_NONNULL_END
