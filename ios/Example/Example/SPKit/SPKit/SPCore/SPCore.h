//
//  SPCore.h
//  SPKit
//
//  Created by 高鹏程 on 2023/3/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,SPEnviromentType){
    SPEnviromentTest,//测试环境
    SPEnviromentPreProd,//预生产环境
    SPEnviromentProd,//生产环境
};

@interface SPCore : NSObject
+ (SPCore*)sharedInstance;
@property(nonatomic,assign)SPEnviromentType enviromentType;
@end

NS_ASSUME_NONNULL_END
