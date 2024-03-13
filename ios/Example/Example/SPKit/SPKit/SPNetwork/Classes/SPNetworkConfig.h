//
//  SPNetworkConfig.h
//  SPKit
//
//  Created by 高鹏程 on 2023/3/7.
//

#import <Foundation/Foundation.h>
#import "SDPNetworkInterceptor.h"
NS_ASSUME_NONNULL_BEGIN

@interface SPNetworkConfig : NSObject

@property(nonatomic,assign)BOOL debug;
@property(nonatomic,assign)NSInteger timeoutSeconds;
@property(nonatomic,copy)NSString *mediaType;
@property(nonatomic,strong)NSArray<SDPNetworkInterceptor*>*interceptors;
@property(nonatomic,strong)NSArray<NSString*>*responseCodeOfSuccessfulBiz;
@end

NS_ASSUME_NONNULL_END
