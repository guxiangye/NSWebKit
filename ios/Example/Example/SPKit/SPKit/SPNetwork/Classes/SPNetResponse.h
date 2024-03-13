//
//  SPNetResponse.h
//  SPKit
//
//  Created by 高鹏程 on 2023/5/6.
//

#import <Foundation/Foundation.h>
#import "SPNetProtocol.h"
NS_ASSUME_NONNULL_BEGIN



@interface SPNetResponse<T> : NSObject
@property(nonatomic,assign)BOOL isSuccessful;
@property(nonatomic,copy)NSString * code;
@property(nonatomic,copy)NSString * message;
@property(nonatomic,strong)T responseData;
@end

NS_ASSUME_NONNULL_END
