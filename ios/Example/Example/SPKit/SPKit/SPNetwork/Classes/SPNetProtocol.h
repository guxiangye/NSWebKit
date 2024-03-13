//
//  SPINetCall.h
//  SPKit
//
//  Created by 高鹏程 on 2023/3/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SPNetCall;

@protocol SPINetCall <NSObject>

- (void)sendAsync;

@end

@protocol SPINetRequest <NSObject>

@required
- (NSString *)getOperation;
- (NSString *)getBaseURL;
- (NSString *)getHttpMethod;
- (NSString *)getContentType;
- (SPNetCall *)buildNetCall;

@optional
- (Class)getResponseClass;

@end


@protocol SPINetResponse <NSObject>

@required
- (NSString *)getCode;
- (NSString *)getMessage;
- (id)getResponseData;
- (BOOL)isSuccessful;
@end

NS_ASSUME_NONNULL_END
