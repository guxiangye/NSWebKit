//
//  NSNetworkHeaderInterceptor.m
//  NSNetwork_Example
//
//  Created by Neil on 2021/3/11.
//  Copyright © 2021 Neil. All rights reserved.
//

#import "NSMerchantHeaderInterceptor.h"
#import "RSAManager.h"
#import "AESEncryptor.h"
#define AESRandomKey @"AESRandomKey"
#import "NSString+YYAdd.h"
#import "NSArray+YYAdd.h"
#import "NSString+NS.h"
@interface NSMerchantHeaderInterceptor ()

@property(nonatomic,strong)RSAManager *rsaManager;
@end

@implementation NSMerchantHeaderInterceptor

-(NSMerchantHeaderInterceptor *)initWithPublicKey:(NSString *)publicKey{
    if (self = [super init]) {
        
        self.rsaManager = [RSAManager new];
        [self.rsaManager setPublicKey:publicKey];
    }
    
    return self;
}
- (NSNetworkRequestOptions *)onRequest:(NSNetworkRequestOptions *)options {
    NSMutableDictionary *param = options.parameters;
    if (param && param.allKeys.count > 0) {
        NSString *key = nil;
        if ([param.allKeys containsObject:AESRandomKey]) {
            key = param[AESRandomKey];
            [(NSMutableDictionary *)param removeObjectForKey:AESRandomKey];
        } else {
            key = [NSString getRandomStringWithNum:16];
        }
        options.header[@"Content-Type"] = @"application/json; charset=utf-8";

        options.parameters = [self encryptAndCalculateMac:options.parameters withKey:key].mutableCopy;

    }

    return [super onRequest:options];
}

- (NSNetworkResponseOptions *)onResponse:(NSNetworkResponseOptions *)options {
    if (options.error) {

    } else {
        NSError *parseError;
        id responseObject = [NSJSONSerialization JSONObjectWithData:options.data
                                                            options:NSJSONReadingMutableLeaves
                                                              error:&parseError];
        options.data = responseObject;
    }

    return [super onResponse:options];
}





#pragma mark - 加密 计算Mac

- (NSDictionary *)encryptAndCalculateMac:(NSDictionary *)paramDic {
    NSString * random = [NSString getRandomStringWithNum:16];
    return [self encryptAndCalculateMac:paramDic.mutableCopy withKey:random];

}
- (NSDictionary *)encryptAndCalculateMac:(NSMutableDictionary *)paramDic withKey:(NSString *)random {
    paramDic = [self correctDecimalLoss:[NSMutableDictionary dictionaryWithDictionary:paramDic]];
    
    //加密后的请求报文
    NSMutableDictionary *rsDic = [NSMutableDictionary dictionaryWithDictionary:paramDic];
    
    //需要加密的字段数组
    NSArray *encryptDataArr = paramDic[@"mNeedEncFields"];
    
    [rsDic removeObjectForKey:@"mNeedEncFields"];
    
    
        for (NSString *key in encryptDataArr) {
            //字符串类型的key
            if ([key isKindOfClass:[NSString class]]) {
                if ([paramDic.allKeys containsObject:key]) {
                    NSString *aesValue = [AESEncryptor encryptAES:paramDic[key] key:random];
                    [rsDic setValue:aesValue forKey:key];
                }
            }
            //字典类型的key
            else if ([key isKindOfClass:[NSDictionary class]]) {
                //获取key
                NSString *jsonKey = [(NSDictionary *)key allKeys][0];
                NSArray *objectEncryptArr = [(NSDictionary *)key valueForKey:jsonKey];
                id objectContentDic = [rsDic valueForKey:jsonKey];

                //对字典类型的Value加密
                if ([objectContentDic isKindOfClass:[NSDictionary class]]) {
                    NSMutableDictionary *objectMContentDic = [NSMutableDictionary dictionaryWithDictionary:objectContentDic];
                    for (NSString *oKey in objectEncryptArr) {
                        if ([oKey isKindOfClass:[NSString class]]) {
                            if ([((NSDictionary *)objectContentDic).allKeys containsObject:oKey]) {
                                id objectValue = objectContentDic[oKey];
                                if ([objectValue isKindOfClass:[NSString class]]) {
                                    NSString *aesValue = [AESEncryptor encryptAES:objectContentDic[oKey] key:random];
                                    [objectMContentDic setValue:aesValue forKey:oKey];
                                }
                            }
                        }
                    }
                    [rsDic setValue:objectMContentDic forKey:jsonKey];//修改完成后设置回去
                }
                //对数组类型的Value加密
                else if ([objectContentDic isKindOfClass:[NSArray class]]) {
                    NSMutableArray *objectValueArr = [NSMutableArray arrayWithArray:objectContentDic];
                    for (int i = 0; i < [objectValueArr count]; i++) {
                        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[objectValueArr objectAtIndex:i]];
                        for (NSString *objKey in objectEncryptArr) {
                            if ([dic.allKeys containsObject:objKey]) {
                                id objectValue = dic[objKey];//
                                if ([objectValue isKindOfClass:[NSString class]]) {
                                    NSString *aesValue = [AESEncryptor encryptAES:objectValue key:random];
                                    [dic setValue:aesValue forKey:objKey];
                                }
                            }
                        }
                        [objectValueArr replaceObjectAtIndex:i withObject:dic];
                    }
                    [rsDic setValue:objectValueArr forKey:jsonKey];//修改完成后设置回去
                }
            }
        }
        
    

    //2 参数 按照key 进行排序
    NSArray *keyArr = [rsDic allKeys];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject:descriptor];
    NSArray *sortArr = [keyArr sortedArrayUsingDescriptors:descriptors];

    //3、参数排序后进行key Value 拼接
    NSMutableString *paramStr = [[NSMutableString alloc] init];
    for (int i = 0; i < sortArr.count; i++) {
        id value = paramDic[sortArr[i]];
        if ([value isKindOfClass:[NSDictionary class]]) {
            [paramStr appendString:[NSString stringWithFormat:@"%@=%@&", sortArr[i], [value jsonStringEncoded]]];
        } else if ([value isKindOfClass:[NSArray class]]) {
            [paramStr appendString:[NSString stringWithFormat:@"%@=%@&", sortArr[i], [value jsonStringEncoded]]];
        } else if ([value isKindOfClass:[NSNull class]]) {
            [paramStr appendString:[NSString stringWithFormat:@"%@=%@&", sortArr[i], @"null"]];
        }
        else if([value isKindOfClass:[NSDecimalNumber class]]){
            NSDecimalNumber *numberValue = value;
            [paramStr appendString:[NSString stringWithFormat:@"%@=%@&", sortArr[i], [numberValue stringValue]]];
        }
        else {
            [paramStr appendString:[NSString stringWithFormat:@"%@=%@&", sortArr[i], value]];
        }
    }
    if (paramStr.length > 1) {
        NSRange deleteRange = { [paramStr length] - 1, 1 };
        [paramStr deleteCharactersInRange:deleteRange];//去掉后面的&符号
    }
    NSString *newParamStr = [paramStr stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    //4、把拼接的字符串进行MD5
    NSString *md5String = [newParamStr md5String].lowercaseString;
    //5、把MD5 后的 数据 进行 AES 加密
    NSString *macString = [AESEncryptor encryptAES:md5String key:random];
    
    NSDictionary *dic = @{ @"sign": macString.uppercaseString,
                               @"nonce": [self.rsaManager encryptorData:random],
                               @"timestamp": [NSString stringWithFormat:@"%.f", [[NSDate date] timeIntervalSince1970]]
    };
    [rsDic addEntriesFromDictionary:dic];
    return rsDic.copy;
}

#pragma mark - 把字典中的精度类型转成字符串
- (NSMutableDictionary *)correctDecimalLoss:(NSMutableDictionary *)dic {
    if (dic) {
        return [self parseDic:dic];
    }
    return nil;
}

#pragma mark - 数组转Json
- (NSString *)objArrayToJSON:(NSArray *)array {

    return [array jsonStringEncoded];
}

#pragma mark - 字典转Json
- (NSString *)convertToJsonData:(NSDictionary *)dict options:(NSJSONWritingOptions)options {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:options error:&error];

    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@", error);
    } else {
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

#pragma mark - 解析字典
- (NSMutableDictionary *)parseDic:(NSMutableDictionary *)dic {
    NSArray *allKeys = [dic allKeys];
    for (int i = 0; i < allKeys.count; i++) {
        NSString *key = allKeys[i];
        id v = dic[key];
        if ([v isKindOfClass:[NSDictionary class]]) {
            [dic setObject:[self parseDic:v] ? [self parseDic:v] : @"" forKey:key];
        } else if ([v isKindOfClass:[NSArray class]]) {
            NSMutableArray *mutArr = [NSMutableArray arrayWithArray:v];
            [dic setObject:[self parseArr:mutArr] ? [self parseArr:mutArr] : @"" forKey:key];
        } else if ([NSStringFromClass([v class]) isEqualToString:@"__NSCFBoolean"]) {
            [dic setValue:([v boolValue] ? @"true" : @"false") forKey:key];
        } else if ([v isKindOfClass:[NSNumber class]]) {
            [dic setObject:[self parseNumber:v] ? [self parseNumber:v] : @"" forKey:key];
        }
    }
    return dic;
}

#pragma mark - 解析数组
- (NSMutableArray *)parseArr:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count; i++) {
        id v = arr[i];
        if ([v isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:v];
            [arr replaceObjectAtIndex:i withObject:[self parseDic:mutDic]];
        } else
        if ([v isKindOfClass:[NSArray class]]) {
            NSMutableArray *mutArr = [NSMutableArray arrayWithArray:v];
            [arr replaceObjectAtIndex:i withObject:[self parseArr:mutArr]];
        } else
        if ([v isKindOfClass:[NSNumber class]]) {
            [arr replaceObjectAtIndex:i withObject:[self parseNumber:v]];
        }
    }
    return arr;
}

#pragma mark - 解析数字
- (NSDecimalNumber *)parseNumber:(NSNumber *)number {
    //直接传入精度丢失有问题的Double类型
    double conversionValue = [number doubleValue];
    NSString *doubleString = [NSString stringWithFormat:@"%lf", conversionValue];
    NSDecimalNumber *decNumber = [NSDecimalNumber decimalNumberWithString:doubleString];
    return decNumber;
}

@end
