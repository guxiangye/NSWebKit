//
//  NSIPDirect.h
//  NSNetwork
//
//  Created by Neil on 2021/3/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSIPDirect : NSObject

+(NSString *)getIPWithHostName:(NSString *)host;
@end

NS_ASSUME_NONNULL_END
