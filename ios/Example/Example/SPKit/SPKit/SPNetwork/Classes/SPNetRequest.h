//
//  SPBaseNetRequest.h
//  SPKit
//
//  Created by 高鹏程 on 2023/3/7.
//

#import <Foundation/Foundation.h>

#import "SPNetProtocol.h"


NS_ASSUME_NONNULL_BEGIN




@interface SPNetRequest<T> : NSObject<SPINetRequest>

//- (SPNetCall<T>*)buildNetCall;

@end

NS_ASSUME_NONNULL_END
