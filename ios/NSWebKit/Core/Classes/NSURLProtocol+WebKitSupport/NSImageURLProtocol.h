//
//  NSImageURLProtocol.h
//  Pods
//
//  Created by Neil on 2023/3/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString* const NSSchemeKey = @"nsfile";

@interface NSImageURLProtocol : NSURLProtocol

+(void)registerSelf;
+(void)unregisterSelf;

@end

NS_ASSUME_NONNULL_END
