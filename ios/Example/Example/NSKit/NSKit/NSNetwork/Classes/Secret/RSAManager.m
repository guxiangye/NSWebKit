//
//  RSAManager.m
//  mpos-app
//
//  Created by NSMobile on 2018/7/2.
//  Copyright © 2018年 shengpay. All rights reserved.
//

#import "RSAManager.h"
#import "RSAEncryptor.h"

#import <UIKit/UIKit.h>

NSString *const k_publickey = @"publickey";

@interface RSAManager ()
{
    RSAEncryptor *rsaEncryptor;
    NSString *_publicKey;
}
@end

@implementation RSAManager

#pragma mrak - 单例
+ (id)sharedInstance {
    static RSAManager *rsaManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rsaManager = [[RSAManager alloc] init];
    });
    return rsaManager;
}

#pragma mrak - 设置公钥
- (void)setPublicKey:(NSString *)pubKey {
    if ([pubKey hasPrefix:@"-----BEGIN PUBLIC KEY-----"] && [pubKey hasSuffix:@"-----END PUBLIC KEY-----"]) {
        _publicKey = pubKey;
    } else {
        _publicKey = [NSString stringWithFormat:@"-----BEGIN PUBLIC KEY-----\n%@\n-----END PUBLIC KEY-----", pubKey];
    }
}

#pragma mrak - 加密数据
- (NSString *)encryptorData:(NSString *)data {
    return [RSAEncryptor encryptString:data publicKey:_publicKey];
}

@end
