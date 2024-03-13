//
//  SPCheckAppVersionUpgrade.h
//  SPKit
//
//  Created by 高鹏程 on 2023/3/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,SPCheckAppVersionEnviromentType){
    SPCheckAppVersionEnviromentTest,//测试环境
    SPCheckAppVersionEnviromentPreProd,//预生产环境
    SPCheckAppVersionEnviromentProd,//生产环境
};

@interface SPCheckAppVersionUpgrade : NSObject
/// 设置 检查版本 环境
/// @param enviromentType  环境
+(void)setCheckAppVersionEnviromentType:(SPCheckAppVersionEnviromentType)enviromentType;


/// 检查版本更新
/// @param appType     赚钱吧 :8 盛钱呗: 9 盛店宝:11 盛意旺:16 盛意旺旺旺:17 同学优先:18
+(void)checkAppVersionWithAppType:(NSString *)appType;

+(NSString *)getBaseURL;

@end

NS_ASSUME_NONNULL_END
