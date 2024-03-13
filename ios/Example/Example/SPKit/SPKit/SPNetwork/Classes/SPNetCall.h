//
//  SPNetCall.h
//  SPKit
//
//  Created by 高鹏程 on 2023/5/6.
//

#import <Foundation/Foundation.h>
#import "SDPNetwork.h"
#import "SPNetResponse.h"
#import "SPNetRequest.h"
#import "SPNetProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPNetCall<T> : NSObject


@property(nonatomic,strong)id<SPINetRequest>request;
@property (nonatomic, assign) NSUInteger retryCount;

-(instancetype)initWithRequest:(id<SPINetRequest>)request;

-(SPNetResponse*)converDataToModel:(id)responseData cls:(Class)_class;

- (void)sendAsync:(void (^)(SPNetResponse<T>* response))callback;

-(void)cancel;
@end

NS_ASSUME_NONNULL_END
