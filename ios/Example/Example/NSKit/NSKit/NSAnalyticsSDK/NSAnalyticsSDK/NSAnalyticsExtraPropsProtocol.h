//
//  NSAnalyticsExtraPropsProtocol.h
//  Pods
//
//  Created by Neil on 2021/1/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@protocol NSAnalyticsExtraPropsProtocol
@property (nonatomic, strong) NSDictionary *extraProps;
@end

//@interface UIView(ExtraPropsProtocol) <NSAnalyticsExtraPropsProtocol>
//
//@end

@interface UIViewController (ExtraPropsProtocol) <NSAnalyticsExtraPropsProtocol>

@end
NS_ASSUME_NONNULL_END
