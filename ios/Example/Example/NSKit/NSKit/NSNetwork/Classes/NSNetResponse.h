//
//  NSNetResponse.h
//  NSKit
//
//  Created by Neil on 2023/5/6.
//

#import <Foundation/Foundation.h>
#import "NSNetProtocol.h"
NS_ASSUME_NONNULL_BEGIN



@interface NSNetResponse<T> : NSObject
@property(nonatomic,assign)BOOL isSuccessful;
@property(nonatomic,copy)NSString * code;
@property(nonatomic,copy)NSString * message;
@property(nonatomic,strong)T responseData;
@end

NS_ASSUME_NONNULL_END
