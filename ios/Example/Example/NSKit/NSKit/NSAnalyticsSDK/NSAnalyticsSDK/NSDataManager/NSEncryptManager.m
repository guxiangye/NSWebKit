//
//  NSEncryptManager.m
//  FMDB
//
//  Created by jhon on 2019/8/6.
//

#import "NSEncryptManager.h"
#import <CommonCrypto/CommonCrypto.h>
#import <AssertMacros.h>
//#import "NSResources.h"

@implementation NSEncryptManager

//先定义一个初始向量的值。
NSString *const NSInitVectorNew = @"cNitHORyqbeYVE0l";
//确定密钥长度，这里选择 AES-128。
size_t const NSKCCKeySize = kCCKeySizeAES128;

//static NSSet *certSet = nil;
//+ (BOOL)verifyServerTrust:(SecTrustRef)serverTrust
//                withDomain:(NSString *)domain {
//    if (!certSet) {
//        NSBundle *bundle = NSGetBundle();
//        NSString *certFilePath = [bundle pathForResource:@"shengpay" ofType:@"cer"];
//        NSData *certData = [NSData dataWithContentsOfFile:certFilePath];
//        certSet = [NSSet setWithObject:certData];
//    }
//
//    if (certSet.count == 0) {
//        return NO;
//    }
//
//    NSMutableArray *policies = [NSMutableArray array];
//    [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
//
//    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
//
//    NSMutableArray *pinnedCertificates = [NSMutableArray array];
//    for (NSData *certificateData in certSet) {
//        [pinnedCertificates addObject:(__bridge_transfer id)SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData)];
//    }
//    SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)pinnedCertificates);
//
//    if (!NSServerTrustIsValid(serverTrust)) {
//        return NO;
//    }
//
//    NSArray *serverCertificates = NSCertificateTrustChainForServerTrust(serverTrust);
//
//    for (NSData *trustChainCertificate in [serverCertificates reverseObjectEnumerator]) {
//        if ([certSet containsObject:trustChainCertificate]) {
//            return YES;
//        }
//    }
//
//    return NO;
//}
//
//static BOOL NSServerTrustIsValid(SecTrustRef serverTrust)
//{
//    BOOL isValid = NO;
//    SecTrustResultType result;
//    __Require_noErr_Quiet(SecTrustEvaluate(serverTrust, &result), _out);
//
//    isValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
//
// _out:
//    return isValid;
//}
//
//static NSArray * NSCertificateTrustChainForServerTrust(SecTrustRef serverTrust)
//{
//    CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
//    NSMutableArray *trustChain = [NSMutableArray arrayWithCapacity:(NSUInteger)certificateCount];
//
//    for (CFIndex i = 0; i < certificateCount; i++) {
//        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
//        [trustChain addObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)];
//    }
//
//    return [NSArray arrayWithArray:trustChain];
//}

#pragma mark - AES加解密

+ (NSString *)sdpEncryptAES:(NSString *)content withKey:(NSString *)key {
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = contentData.length;
    // 为结束符'\\0' +1
    char keyPtr[NSKCCKeySize + 1];
    memset(keyPtr, 0, sizeof(keyPtr));

    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    // 密文长度 <= 明文长度 + BlockSize
    size_t encryptSize = dataLength + kCCBlockSizeAES128;
    void *encryptedBytes = malloc(encryptSize);
    size_t actualOutSize = 0;
    NSData *initVector = [NSInitVectorNew dataUsingEncoding:NSUTF8StringEncoding];
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,  // 系统默认使用 CBC，然后指明使用 PKCS7Padding
                                          keyPtr,
                                          NSKCCKeySize,
                                          initVector.bytes,
                                          contentData.bytes,
                                          dataLength,
                                          encryptedBytes,
                                          encryptSize,
                                          &actualOutSize);
    if (cryptStatus == kCCSuccess) {
        // 对加密后的数据进行 base64 编码
        return [[NSData dataWithBytesNoCopy:encryptedBytes length:actualOutSize] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    free(encryptedBytes);
    return @"";
}

+ (NSString *)sdpDecryptAES:(NSString *)content withKey:(NSString *)key {
    // 把 base64 String 转换成 Data
    NSData *contentData = [[NSData alloc] initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSUInteger dataLength = contentData.length;
    char keyPtr[NSKCCKeySize + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    size_t decryptSize = dataLength + kCCBlockSizeAES128;
    void *decryptedBytes = malloc(decryptSize);
    size_t actualOutSize = 0;
    NSData *initVector = [NSInitVectorNew dataUsingEncoding:NSUTF8StringEncoding];
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          NSKCCKeySize,
                                          initVector.bytes,
                                          contentData.bytes,
                                          dataLength,
                                          decryptedBytes,
                                          decryptSize,
                                          &actualOutSize);
    if (cryptStatus == kCCSuccess) {
        return [[NSString alloc] initWithData:[NSData dataWithBytesNoCopy:decryptedBytes length:actualOutSize] encoding:NSUTF8StringEncoding];
    }
    free(decryptedBytes);
    return @"";
}

@end
