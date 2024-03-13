//
//  NSString+NS.h
//  NSKit
//
//  Created by Neil on 2023/5/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (NS)



/// 生成随机数
/// @param num 随机数数量
+ (NSString *)getRandomStringWithNum:(NSInteger)num;


-(NSString *)percentEscapedString;
@end

NS_ASSUME_NONNULL_END
