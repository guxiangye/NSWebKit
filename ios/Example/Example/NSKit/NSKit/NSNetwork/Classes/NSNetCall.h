//
//  NSNetCall.h
//  NSKit
//
//  Created by Neil on 2023/5/6.
//

#import <Foundation/Foundation.h>
#import "NSNetwork.h"
#import "NSNetResponse.h"
#import "NSNetRequest.h"
#import "NSNetProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSNetCall<T> : NSObject


@property(nonatomic,strong)id<NSINetRequest>request;
@property (nonatomic, assign) NSUInteger retryCount;

-(instancetype)initWithRequest:(id<NSINetRequest>)request;

-(NSNetResponse*)converDataToModel:(id)responseData cls:(Class)_class;

- (void)sendAsync:(void (^)(NSNetResponse<T>* response))callback;

-(void)cancel;
@end

NS_ASSUME_NONNULL_END
