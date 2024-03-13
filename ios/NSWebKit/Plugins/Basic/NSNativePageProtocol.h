//
//  NSNativePageProtocol.h
//
//  Created by Neil on 2023/12/6.
//

#ifndef NSNativePageProtocol_h
#define NSNativePageProtocol_h
#import <UIKit/UIKit.h>


/// 原生界面遵循协议 用于 cordova 插件 打开原生界面
@protocol NSNativePageProtocol <NSObject>

/// 传递参数拓展字段
@property (nonatomic, copy) NSDictionary *extInfo;
@end

#endif /* NSNativePageProtocol_h */
