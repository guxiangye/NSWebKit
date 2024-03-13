//
//  AESEncryptor.h
//  mpos-app
//
//  Created by SDPMobile on 2018/7/3.
//  Copyright © 2018年 shengpay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AESEncryptor : NSObject

/**
 *  AES加密
 *
 *  @param content  加密内容
 *  @param key      随机数Key
 *
 */
+ (NSString *)encryptAES:(NSString *)content
                     key:(NSString *)key;

/**
 *  AES解密
 *
 *  @param content  解密内容
 *  @param key      随机数Key
 *
 */
+ (NSString *)decryptAES:(NSString *)content
                     key:(NSString *)key;
+ (NSString *)aes256_encryptWithContent:(NSString *)content key:(NSString *)key;

+ (NSString *)aes256_decryptWithContent:(NSString *)content key:(NSString *)key;

@end
