//
//  SDPAutoTrackUtils.h
//  SDPAutoTrack
//
//  Created by 高鹏程 on 2020/5/22.
//  Copyright © 2020 高鹏程. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDPAutoTrackProperty.h"
NS_ASSUME_NONNULL_BEGIN

@interface SDPAutoTrackUtils : NSObject

/// 判断对象是否为空
/// @param obj  对象
+ (BOOL)isNull:(id)obj;

/// 获取当前控制器
+ (UIViewController<SDPAutoTrackViewControllerProperty> *)currentViewController;

/// 获取元素在当前层级 相同类元素里的位置序号
/// @param responder 元素
+ (NSInteger)itemIndexForResponder:(UIResponder *)responder;

/// 通过 AutoTrack 控件，获取事件的属性
/// @param object 控件的对象，UIView 及其子类
+ (nullable NSMutableDictionary<NSString *, NSString *> *)trackInfoWithAutoTrackObject:(id<SDPAutoTrackViewProperty>)object eventType:(SDPAutoTrackEventType)eventType;

/// 获取弹出框的打点属性
/// @param alertViewController 弹出框
+ (NSDictionary<NSString *, NSString *> *)trackInfoWithAlertController:(UIAlertController <SDPAutoTrackViewProperty> *)alertViewController eventType:(SDPAutoTrackEventType)eventType;

/// 获取弹出框的按钮点击的打点属性
/// @param alertViewController 弹出框
/// @param action action
+ (NSDictionary<NSString *, NSString *> *)trackInfoWithAlertController:(UIAlertController <SDPAutoTrackViewProperty> *)alertViewController action:(UIAlertAction<SDPAutoTrackUIAlertActionProperty> *)action;
#pragma mark - 获取APP的启动上下文
+ (NSDictionary<NSString *, NSString *> *)trackInfoWithAppLaunchContext ;
/// 获取控制器的打点属性
/// @param viewController 控制器
/// @param eventType 控制器是显示 还是消失
+ (NSDictionary<NSString *, NSString *> *)trackInfoWithViewController:(UIViewController<SDPAutoTrackViewControllerProperty> *)viewController eventType:(SDPAutoTrackEventType)eventType;

/// 获取当前时间
+ (NSString *)getCurrentTime;

@end

@interface UIDevice (SDPAnalytics)
+ (NSString *)sdp_analytics_getAppVersion;
+ (NSString *)sdp_analytics_getAppName;
+ (NSString *)sdp_analytics_getNetworkType;
+ (NSString *)sdp_analytics_getDeviceModel;
// 获取运营商信息
+ (NSString *)sdp_analytics_getOperatorInfomation;

@end
NS_ASSUME_NONNULL_END
