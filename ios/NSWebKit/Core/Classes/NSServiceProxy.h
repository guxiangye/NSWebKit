//
//  NSServiceProxy.h
//  NSWebKit
//
//  Created by 相晔谷 on 2023/5/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString* _Nullable (^NSServiceProxyFetchStringCallback)(void);
typedef NSDictionary* _Nullable (^NSServiceProxyFetchExtendInfoCallback)(void);

@interface NSServiceProxy : NSObject

+ (NSString*)getAppId;
+ (NSString*)getDeviceId;
+ (NSDictionary *)getExtendInfo;

+ (NSServiceProxy *)sharedInstance;

+ (void)setFetchAppId:(NSServiceProxyFetchStringCallback)fetchAppId fetchDeviceId:(NSServiceProxyFetchStringCallback)fetchDeviceId fetchExtendInfo:(NSServiceProxyFetchExtendInfoCallback)fetchExtendInfo;

@end

NS_ASSUME_NONNULL_END
