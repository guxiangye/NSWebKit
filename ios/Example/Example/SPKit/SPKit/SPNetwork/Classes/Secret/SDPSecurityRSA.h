//
//  SDPSecurityRSA.h
//  SDPWalletSDK
//
//  Created by 高鹏程 on 2019/11/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDPSecurityRSA : NSObject
/**
 * -------RSA 字符串公钥加密-------
 @param plaintext 明文，待加密的字符串
 @param pubKey 公钥字符串
 @return 密文，加密后的字符串
 */
+ (NSString *)encrypt:(NSString *)plaintext publicKey:(NSString *)pubKey;
/**
 * -------RSA 私钥字符串解密-------
 @param ciphertext 密文，需要解密的字符串
 @param privKey 私钥字符串
 @return 明文，解密后的字符串
 */
+ (NSString *)decrypt:(NSString *)ciphertext privateKey:(NSString *)privKey;
/**
* -------RSA  验签-------
@param content 密文
@param signature 签名
@param publicKey 公钥字符串
@return 是否验签成功
*/
+ (BOOL)verify:(NSString *)content signature:(NSString *)signature withPublivKey:(NSString *)publicKey;
/**
* -------RSA  验签-------
@param content 密文
@param privateKey 私钥字符串
@return 签名字符串
*/
+ (NSString *)sign:(NSString *)content privateKey:(NSString *)priKey;
@end

NS_ASSUME_NONNULL_END
