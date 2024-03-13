//
//  NSEncryptPlugin.h
//  Example
//
//  Created by 相晔谷 on 2024/3/13.
//

#import "CDVPlugin.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSEncryptPlugin : CDVPlugin

/// 加密和加签
- (void)encryptAndCalculateMac:(CDVInvokedUrlCommand *)command;

@end

NS_ASSUME_NONNULL_END
