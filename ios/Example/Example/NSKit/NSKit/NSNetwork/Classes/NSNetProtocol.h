//
//  NSINetCall.h
//  NSKit
//
//  Created by Neil on 2023/3/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NSNetCall;

@protocol NSINetCall <NSObject>

- (void)sendAsync;

@end

@protocol NSINetRequest <NSObject>

@required
- (NSString *)getOperation;
- (NSString *)getBaseURL;
- (NSString *)getHttpMethod;
- (NSString *)getContentType;
- (NSNetCall *)buildNetCall;

@optional
- (Class)getResponseClass;

@end


@protocol NSINetResponse <NSObject>

@required
- (NSString *)getCode;
- (NSString *)getMessage;
- (id)getResponseData;
- (BOOL)isSuccessful;
@end

NS_ASSUME_NONNULL_END
