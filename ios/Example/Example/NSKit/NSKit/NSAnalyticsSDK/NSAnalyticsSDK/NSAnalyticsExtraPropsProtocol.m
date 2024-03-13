//
//  NSAnalyticsExtraPropsProtocol.m
//  Pods
//
//  Created by Neil on 2021/1/7.
//

#import "NSAnalyticsExtraPropsProtocol.h"
#import <objc/runtime.h>
static const int sdp_autotrack_view_extraPropsProtocol_key;
//@implementation UIView (ExtraPropsProtocol)
//
//
//-(void)setExtraProps:(NSDictionary *)extraProps{
//    objc_setAssociatedObject(self, &sdp_autotrack_view_extraPropsProtocol_key, extraProps, OBJC_ASSOCIATION_RETAIN);
//}
//-(NSDictionary *)extraProps{
//    return  objc_getAssociatedObject(self, &sdp_autotrack_view_extraPropsProtocol_key);
//}
//
//@end

@implementation UIViewController (ExtraPropsProtocol)


-(void)setExtraProps:(NSDictionary *)extraProps{
    objc_setAssociatedObject(self, &sdp_autotrack_view_extraPropsProtocol_key, extraProps, OBJC_ASSOCIATION_RETAIN);
}
-(NSDictionary *)extraProps{
    return  objc_getAssociatedObject(self, &sdp_autotrack_view_extraPropsProtocol_key);
}

@end
