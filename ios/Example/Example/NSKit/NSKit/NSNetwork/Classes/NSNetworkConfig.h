//
//  NSNetworkConfig.h
//  NSKit
//
//  Created by Neil on 2023/3/7.
//

#import <Foundation/Foundation.h>
#import "NSNetworkInterceptor.h"
NS_ASSUME_NONNULL_BEGIN

@interface NSNetworkConfig : NSObject

@property(nonatomic,assign)BOOL debug;
@property(nonatomic,assign)NSInteger timeoutSeconds;
@property(nonatomic,copy)NSString *mediaType;
@property(nonatomic,strong)NSArray<NSNetworkInterceptor*>*interceptors;
@property(nonatomic,strong)NSArray<NSString*>*responseCodeOfSuccessfulBiz;
@end

NS_ASSUME_NONNULL_END
