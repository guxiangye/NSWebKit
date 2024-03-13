//
//  RSAManager.h
//  mpos-app
//
//  Created by SDPMobile on 2018/7/2.
//  Copyright © 2018年 shengpay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSAManager : NSObject

/**
 *  单例
 */
+ (id)sharedInstance;

/**
 *  设置公钥
 *
 *  @param pubKey 公钥
 *
 */
- (void)setPublicKey:(NSString *)pubKey;

/**
 *  加密数据
 *
 *  @param data 需要RSA加密的字符串
 *
 */
- (NSString *)encryptorData:(NSString *)data;

@end
