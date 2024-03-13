//
//  NSBaseNetRequest.h
//  NSKit
//
//  Created by Neil on 2023/3/7.
//

#import <Foundation/Foundation.h>

#import "NSNetProtocol.h"


NS_ASSUME_NONNULL_BEGIN




@interface NSNetRequest<T> : NSObject<NSINetRequest>

//- (NSNetCall<T>*)buildNetCall;

@end

NS_ASSUME_NONNULL_END
