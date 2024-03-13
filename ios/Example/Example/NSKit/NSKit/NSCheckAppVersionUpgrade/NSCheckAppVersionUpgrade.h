//
//  NSCheckAppVersionUpgrade.h
//  NSKit
//
//  Created by Neil on 2023/3/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,NSCheckAppVersionEnviromentType){
    NSCheckAppVersionEnviromentTest,//测试环境
    NSCheckAppVersionEnviromentPreProd,//预生产环境
    NSCheckAppVersionEnviromentProd,//生产环境
};

@interface NSCheckAppVersionUpgrade : NSObject
/// 设置 检查版本 环境
/// @param enviromentType  环境
+(void)setCheckAppVersionEnviromentType:(NSCheckAppVersionEnviromentType)enviromentType;


/// 检查版本更新
/// @param appType     赚钱吧 :8 盛钱呗: 9 盛店宝:11 盛意旺:16 盛意旺旺旺:17 同学优先:18
+(void)checkAppVersionWithAppType:(NSString *)appType;

+(NSString *)getBaseURL;

@end

NS_ASSUME_NONNULL_END
