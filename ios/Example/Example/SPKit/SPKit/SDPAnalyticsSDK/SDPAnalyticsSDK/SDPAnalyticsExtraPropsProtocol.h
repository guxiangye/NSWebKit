//
//  SDPAnalyticsExtraPropsProtocol.h
//  Pods
//
//  Created by 高鹏程 on 2021/1/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@protocol SDPAnalyticsExtraPropsProtocol
@property (nonatomic, strong) NSDictionary *extraProps;
@end

//@interface UIView(ExtraPropsProtocol) <SDPAnalyticsExtraPropsProtocol>
//
//@end

@interface UIViewController (ExtraPropsProtocol) <SDPAnalyticsExtraPropsProtocol>

@end
NS_ASSUME_NONNULL_END
