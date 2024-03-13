//
//  NSEncryptManager.h
//  FMDB
//
//  Created by jhon on 2019/8/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSEncryptManager : NSObject
///**
// 证书校验
// */
//+ (BOOL)verifyServerTrust:(SecTrustRef)serverTrust
//                  withDomain:(NSString *)domain;
/**
 AES加密方法
 
 @param content 需要加密的字符串
 @ keykey
 @return 加密后的字符串
 */
+ (NSString *)sdpEncryptAES:(NSString *)content withKey:(NSString *)key;

/**
 AES解密方法
 
 @param content 需要解密的字符串
 @ key
 @return 解密后的字符串
 */
+ (NSString *)sdpDecryptAES:(NSString *)content withKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
