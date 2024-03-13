//
//  NSCore.h
//  NSKit
//
//  Created by Neil on 2023/3/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,NSEnviromentType){
    NSEnviromentTest,//测试环境
    NSEnviromentPreProd,//预生产环境
    NSEnviromentProd,//生产环境
};

@interface NSCore : NSObject
+ (NSCore*)sharedInstance;
@property(nonatomic,assign)NSEnviromentType enviromentType;
@end

NS_ASSUME_NONNULL_END
