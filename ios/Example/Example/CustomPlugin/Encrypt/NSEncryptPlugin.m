//
//  NSEncryptPlugin.m
//  Example
//
//  Created by 相晔谷 on 2024/3/13.
//

#import "NSEncryptPlugin.h"
#import "SPMerchantHeaderInterceptor.h"

@implementation NSEncryptPlugin

#pragma mark - 加密和加签
-(void)encryptAndCalculateMac:(CDVInvokedUrlCommand *)command{
    NSDictionary *dic = command.arguments.firstObject;
    
    SPMerchantHeaderInterceptor *interceptor = [[SPMerchantHeaderInterceptor alloc] initWithPublicKey:@"publicKey"];
    NSMutableDictionary *result =  @{}.mutableCopy;
    NSDictionary *data= [interceptor encryptAndCalculateMac:dic];
    result[@"data"]=data?:@{};
    result[@"errCode"]=@0;
    
    CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
    });
}

@end
