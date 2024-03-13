//
//  SDPAutoTrack.m
//  SDPAutoTrack
//
//  Created by 高鹏程 on 2020/5/19.
//  Copyright © 2020 高鹏程. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SDPAutoTrack.h"
#import "SDPAspects.h"
#import "UIGestureRecognizer+SDPAutoTrack.h"
#import "UIView+SDPAutoTrack.h"
#import "SDPAnalyticsManager.h"
#import "SDPAutoTrackUtils.h"
#import "UIView+SDPAutoTrackTableHeaderFooterView.h"
#import "SDPAnalyticsSDK.h"
#import "SDPAnalyticsSDK+AutoTrack.h"
#import "SDPAutoTrackConstants.h"
#import <objc/runtime.h>
#import "UIImage+SDPAutoTrack.h"
#import "SDPReportManager.h"

@interface SDPAutoTrack ()

/// 存储 所有 自动埋点的 SDPAspectToken 方便以后移除
@property (nonatomic, strong) NSMutableArray<id<SDPAspectToken> > *aspectTokenArray;

/// 是否开启自动埋点
@property (nonatomic, assign) BOOL isEnableAutoTrack;
@end

@implementation SDPAutoTrack

+ (SDPAutoTrack *)sharedInstance {
    static SDPAutoTrack *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        _instance.aspectTokenArray = [[NSMutableArray alloc]init];
    });
    return _instance;
}

#pragma mark - 开启自动埋点
+ (void)enableAutoTrack {
    SDP_AUTOTRACK_TRY_CATCH_BEGIN
    SDPAutoTrack *singleton = [SDPAutoTrack sharedInstance];
    if (singleton.isEnableAutoTrack) {
        return;
    }
    //延迟10秒发起上报
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[SDPReportManager sharedInstance] dispatch:0];
        [[SDPReportManager sharedInstance] dispatch:1];
        [[SDPReportManager sharedInstance] dispatch:2];
        [[SDPReportManager sharedInstance] dispatch:3];
    });
    singleton.isEnableAutoTrack = YES;
    #pragma mark - 生成全局sessionId
    [SDPAnalyticsManager generateSessionId];
    #pragma mark - 从UIImage 里 获取从 bundle 读取图片的文件名
    Class classMetal = object_getClass([UIImage class]);
    id<SDPAspectToken>token = [classMetal sdp_aspect_hookSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:) withOptions:SDPAspectPositionAfter usingBlock:^(id<SDPAspectInfo>info) {
        SDP_AUTOTRACK_TRY_CATCH_BEGIN
        NSInvocation *invocation = info.originalInvocation;
        /**
         这里之所以加上 __unsafe_unretained.不加的话会出现闪退
         1.NSInvocation 不会引用参数
         2.ARC 在隐式赋值不会自动插入 retain 语句
         3.ARC下 UIImage *value = nil; 相当于 __strong UIImage * value; 所以在退出作用域时会自动插入release语句.
         --------
         两种解决方案
         1.如下面用到所示 加__unsafe_unretained
         2.
         UIImage *value = nil;
         void *result;
         [invocation getReturnValue:&result];
         value = (__bridge id)result;
         */
        __unsafe_unretained UIImage *value = nil;
        [invocation getReturnValue:&value];
        NSString *imageName = [[info arguments]firstObject];
        [value setSdp_autotrack_filename:imageName];
        SDP_AUTOTRACK_TRY_CATCH_END
    }];
    [self addAspectToken:token];

    #pragma mark - 从UImageView 获取 网络图片地址

    if (NSClassFromString(@"SDPAnimatedImageView")) {
        SEL sdp_setImageWithURLSEL = NSSelectorFromString(@"sdp_setImageWithURL:placeholder:options:manager:progress:transform:completion:");
        token = [UIImageView sdp_aspect_hookSelector:sdp_setImageWithURLSEL withOptions:SDPAspectPositionBefore usingBlock:^(id<SDPAspectInfo>info) {
            SDP_AUTOTRACK_TRY_CATCH_BEGIN
            UIImageView *imageView = info.instance;
            NSURL *url = [[info arguments]firstObject];
            [imageView setSdp_autotrack_filename:[url.absoluteString lastPathComponent]];
            SDP_AUTOTRACK_TRY_CATCH_END
        }];
        [self addAspectToken:token];

        sdp_setImageWithURLSEL = NSSelectorFromString(@"sdp_setImageWithURL:forState:placeholder:options:manager:progress:transform:completion:");
        token = [UIButton sdp_aspect_hookSelector:sdp_setImageWithURLSEL withOptions:SDPAspectPositionBefore usingBlock:^(id<SDPAspectInfo>info) {
            SDP_AUTOTRACK_TRY_CATCH_BEGIN

            UIControlState state = [[info arguments][1]integerValue];
            if (state == UIControlStateNormal) {
                UIButton *button = info.instance;
                NSURL *url = [[info arguments]firstObject];
                [button setSdp_autotrack_filename:[url.absoluteString lastPathComponent]];
            }

            SDP_AUTOTRACK_TRY_CATCH_END
        }];
        [self addAspectToken:token];
    }
    //取消页面创建时上送的 上下文信息 2023.3.31
//    #pragma mark - 控制器的加载 获取页面上下文
//    token = [UIViewController sdp_aspect_hookSelector:@selector(viewDidLoad)
//                                          withOptions:SDPAspectPositionAfter
//                                           usingBlock:^(id<SDPAspectInfo> info) {
//        SDP_AUTOTRACK_TRY_CATCH_BEGIN
//        UIViewController<SDPAutoTrackElementIsIgnoredProtocol> *viewController = [info instance];
//
//        if (viewController.sdp_autotrack_isIgnored) {
//            return;
//        }
//        SDPReportPolicy reportPolicy;
//        if ([viewController sdp_autotrack_isIgnored:SDPAutoTrackControlShow reportPolicy:&reportPolicy]) {
//            return;
//        }
//        SDP_AUTOTRACK_TRY_CATCH_END
//    }];
//    [self addAspectToken:token];
    #pragma mark - 控制器的显示
    token = [UIViewController sdp_aspect_hookSelector:@selector(viewDidAppear:)
                                          withOptions:SDPAspectPositionBefore
                                           usingBlock:^(id<SDPAspectInfo>info) {
        SDP_AUTOTRACK_TRY_CATCH_BEGIN
        UIViewController<SDPAutoTrackElementIsIgnoredProtocol> *viewController = [info instance];

        if (viewController.sdp_autotrack_isIgnored) {
            return;
        }
        SDPReportPolicy reportPolicy;
        if ([viewController sdp_autotrack_isIgnored:SDPAutoTrackControlShow reportPolicy:&reportPolicy]) {
            return;
        }
        NSDictionary *trackInfo = nil;
        if ([viewController isKindOfClass:[UIAlertController class]]) {
            //弹出框 属于 ControlShow

            trackInfo = [SDPAutoTrackUtils trackInfoWithAlertController:(id)viewController eventType:SDPAutoTrackControlShow];
        } else {
            //VC 属于 PageAppear

            trackInfo = [SDPAutoTrackUtils trackInfoWithViewController:viewController eventType:SDPAutoTrackPageAppear];
        }

        [SDPAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:reportPolicy];
        SDP_AUTOTRACK_TRY_CATCH_END
    } ];
    [self addAspectToken:token];
//    #pragma mark 控制器的消失
//    token = [UIViewController sdp_aspect_hookSelector:@selector(viewDidDisappear:)
//                                          withOptions:SDPAspectPositionBefore
//                                           usingBlock:^(id<SDPAspectInfo>info) {
//        SDP_AUTOTRACK_TRY_CATCH_BEGIN
//        UIViewController<SDPAutoTrackViewControllerProperty> *viewController = [info instance];
//
//        SDPReportPolicy reportPolicy;
//        if ([viewController sdp_autotrack_isIgnored:SDPAutoTrackPageDisappear reportPolicy:&reportPolicy]) {
//            return;
//        }
//        NSDictionary *trackInfo = [SDPAutoTrackUtils trackInfoWithViewController:viewController eventType:SDPAutoTrackPageDisappear];
//        [SDPAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:reportPolicy];
//        SDP_AUTOTRACK_TRY_CATCH_END
//    } ];
//    [self addAspectToken:token];

    #pragma mark - 响应链点击事件
    token = [UIApplication sdp_aspect_hookSelector:@selector(sendAction:to:from:forEvent:)
                                       withOptions:SDPAspectPositionBefore
                                        usingBlock:^(id<SDPAspectInfo>info) {
        SDP_AUTOTRACK_TRY_CATCH_BEGIN
        SDPReportPolicy reportPolicy;
        NSArray *arguments = [info arguments];
        UIView<SDPAutoTrackViewProperty> *sender = arguments[2];
        //UITextFile 和 UITextVIew  不响应
        if ([sender isKindOfClass:UITextField.class] || [sender isKindOfClass:UITextView.class]) {
            return;
        }
        if (![sender conformsToProtocol:@protocol(SDPAutoTrackViewProperty)] || [sender sdp_autotrack_isIgnored:SDPAutoTrackControlClick reportPolicy:&reportPolicy]) {
            return;
        }
        /*如果是 导航栏上的 UIBarButtonItem 被点击
         这里会被执行两次不同的方法,_invalidateAssistant: 和 _invoke:forEvent:
         我们过滤掉 _invalidateAssistant:方法
         */
        NSString *action = arguments[0];
        if ([sender isKindOfClass:NSClassFromString(@"_UIButtonBarButton")] && [action isEqualToString:@"_invalidateAssistant:"]) {
            return;
        }
        NSDictionary *trackInfo = [SDPAutoTrackUtils trackInfoWithAutoTrackObject:sender eventType:SDPAutoTrackControlClick];
        [SDPAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:reportPolicy];
        SDP_AUTOTRACK_TRY_CATCH_END
    }];
    [self addAspectToken:token];

    #pragma mark - 手势事件
    token = [UITapGestureRecognizer sdp_aspect_hookSelector:@selector(initWithTarget:action:)
                                                withOptions:SDPAspectPositionAfter
                                                 usingBlock:^(id<SDPAspectInfo>info) {
        SDP_AUTOTRACK_TRY_CATCH_BEGIN
        UITapGestureRecognizer *gesture = [info instance];
        SDPReportPolicy reportPolicy;
        [gesture addActionBlock:^(UIGestureRecognizer *_Nonnull sender) {
            UIView<SDPAutoTrackViewProperty> *view = (id)sender.view;
            if ([view sdp_autotrack_isIgnored:SDPAutoTrackControlClick reportPolicy:&reportPolicy]) {
                return;
            }
            NSDictionary *trackInfo = [SDPAutoTrackUtils trackInfoWithAutoTrackObject:view eventType:SDPAutoTrackControlClick];
            [SDPAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:reportPolicy];
        }];
        SDP_AUTOTRACK_TRY_CATCH_END
    } ];
    [self addAspectToken:token];

    #pragma mark  UITableView
    token = [UITableView sdp_aspect_hookSelector:@selector(setDelegate:)
                                     withOptions:SDPAspectPositionAfter
                                      usingBlock:^(id<SDPAspectInfo>info) {
        SDP_AUTOTRACK_TRY_CATCH_BEGIN
        id delegate = [[info arguments]firstObject];
        if ([SDPAutoTrackUtils isNull:delegate]) {
            return;
        }
        id<SDPAutoTrackIsIgnoredProtocol> instance = [info instance];
        if ([instance conformsToProtocol:@protocol(SDPAutoTrackIsIgnoredProtocol)] && instance.sdp_autotrack_isIgnored) {
            return;
        }

        #pragma mark UITableView Cell的点击事件
        SEL didSelectRowAtIndexPathSEL = @selector(tableView:didSelectRowAtIndexPath:);
        if ([delegate respondsToSelector:didSelectRowAtIndexPathSEL]) {
            [delegate sdp_aspect_hookSelector:didSelectRowAtIndexPathSEL
                                  withOptions:SDPAspectPositionBefore
                                   usingBlock:^(id<SDPAspectInfo> info)
            {
                SDP_AUTOTRACK_TRY_CATCH_BEGIN
                SDPReportPolicy reportPolicy;
                UITableView<SDPAutoTrackElementIsIgnoredProtocol> *table = [info.arguments firstObject];
                if ([table sdp_autotrack_isIgnored:SDPAutoTrackControlClick reportPolicy:&reportPolicy]) {
                    return;
                }
                NSIndexPath *indexPath = [info.arguments lastObject];
                UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
                NSDictionary *trackInfo = [SDPAutoTrackUtils trackInfoWithAutoTrackObject:cell eventType:SDPAutoTrackControlClick];
                [SDPAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:reportPolicy];
                SDP_AUTOTRACK_TRY_CATCH_END
            }];
        }

        #pragma mark 标记 tableview headerview 的位置
        SEL viewForHeaderInSectionSEL = @selector(tableView:viewForHeaderInSection:);
        if ([delegate respondsToSelector:viewForHeaderInSectionSEL]) {
            [delegate sdp_aspect_hookSelector:viewForHeaderInSectionSEL
                                  withOptions:SDPAspectPositionAfter
                                   usingBlock:^(id<SDPAspectInfo> info) {
                SDP_AUTOTRACK_TRY_CATCH_BEGIN
                NSInteger section = [[info.arguments lastObject]integerValue];
                NSInvocation *invocation = info.originalInvocation;
                __unsafe_unretained UIView *value = nil;
                [invocation getReturnValue:&value];
                value.sdp_autotrack_header_footer_view_type = SDPAutoTrackViewInHeaderView;
                value.sdp_autotrack_header_footer_section = section;
                SDP_AUTOTRACK_TRY_CATCH_END
            } ];
        }

        #pragma mark 标记 tableview footerview 的位置
        SEL viewForFooterInSectionSEL = @selector(tableView:viewForFooterInSection:);
        if ([delegate respondsToSelector:viewForFooterInSectionSEL]) {
            [delegate sdp_aspect_hookSelector:viewForFooterInSectionSEL
                                  withOptions:SDPAspectPositionAfter
                                   usingBlock:^(id<SDPAspectInfo> info) {
                SDP_AUTOTRACK_TRY_CATCH_BEGIN
                NSInteger section = [[info.arguments lastObject]integerValue];
                NSInvocation *invocation = info.originalInvocation;
                __unsafe_unretained UIView *value = nil;
                [invocation getReturnValue:&value];
                value.sdp_autotrack_header_footer_view_type = SDPAutoTrackViewInFooterView;
                value.sdp_autotrack_header_footer_section = section;
                SDP_AUTOTRACK_TRY_CATCH_END
            } ];
        }

        SDP_AUTOTRACK_TRY_CATCH_END
    } ];
    [self addAspectToken:token];

    #pragma mark - UICollectionView setDelegate:
    token = [UICollectionView sdp_aspect_hookSelector:@selector(setDelegate:)
                                          withOptions:SDPAspectPositionAfter
                                           usingBlock:^(id<SDPAspectInfo> info) {
        SDP_AUTOTRACK_TRY_CATCH_BEGIN
        id delegate = [[info arguments]firstObject];
        if ([SDPAutoTrackUtils isNull:delegate]) {
            return;
        }
        id<SDPAutoTrackIsIgnoredProtocol> instance = [info instance];
        if ([instance conformsToProtocol:@protocol(SDPAutoTrackIsIgnoredProtocol)] && instance.sdp_autotrack_isIgnored) {
            return;
        }
        //创建UIAlertController 的时候 也会创建一个 CollectionView
        Class _UIAlertControllerTextFieldViewControllerClass = NSClassFromString(@"_UIAlertControllerTextFieldViewController");
        if ([delegate isKindOfClass:_UIAlertControllerTextFieldViewControllerClass]) {
            return;
        }
        //解决 在获取短信验证码时,自动回填验证码,发生的闪退
        Class TUICandidateGridClass = NSClassFromString(@"TUICandidateGrid");
        if ([delegate isKindOfClass:TUICandidateGridClass]) {
            return;
        }
        #pragma mark UICollectionView Cell的点击事件
        SEL didSelectItemAtIndexPathSEL =  @selector(collectionView:didSelectItemAtIndexPath:);
        if ([delegate respondsToSelector:didSelectItemAtIndexPathSEL]) {
            [delegate sdp_aspect_hookSelector:didSelectItemAtIndexPathSEL
                                  withOptions:SDPAspectPositionBefore
                                   usingBlock:^(id<SDPAspectInfo> info) {
                SDP_AUTOTRACK_TRY_CATCH_BEGIN
                SDPReportPolicy reportPolicy;
                UICollectionView<SDPAutoTrackElementIsIgnoredProtocol> *collection = [info.arguments firstObject];
                if ([collection sdp_autotrack_isIgnored:SDPAutoTrackControlClick reportPolicy:&reportPolicy]) {
                    return;
                }
                NSIndexPath *indexPath = [info.arguments lastObject];
                UICollectionViewCell *cell = [collection cellForItemAtIndexPath:indexPath];
                UIView<SDPAutoTrackViewProperty> *view = cell;
                NSDictionary *trackInfo = [SDPAutoTrackUtils trackInfoWithAutoTrackObject:view eventType:SDPAutoTrackControlClick];
                [SDPAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:reportPolicy];
                SDP_AUTOTRACK_TRY_CATCH_END
            }];
        }

        SDP_AUTOTRACK_TRY_CATCH_END
    } ];
    [self addAspectToken:token];

    #pragma mark - UICollectionView setDataSource:
    token = [UICollectionView sdp_aspect_hookSelector:@selector(setDataSource:)
                                          withOptions:SDPAspectPositionAfter
                                           usingBlock:^(id<SDPAspectInfo> info) {
        SDP_AUTOTRACK_TRY_CATCH_BEGIN
        id datasouce = [[info arguments]firstObject];
        if ([SDPAutoTrackUtils isNull:datasouce]) {
            return;
        }
        //创建UIAlertController 的时候 也会创建一个 CollectionView
        Class _UIAlertControllerTextFieldViewControllerClass = NSClassFromString(@"_UIAlertControllerTextFieldViewController");
        if ([datasouce isKindOfClass:_UIAlertControllerTextFieldViewControllerClass]) {
            return;
        }
        //解决 在获取短信验证码时,自动回填验证码,发生的闪退
        Class _TUICandidateGridClass = NSClassFromString(@"TUICandidateGrid");
        if ([datasouce isKindOfClass:_TUICandidateGridClass]) {
            return;
        }
        id<SDPAutoTrackIsIgnoredProtocol> instance = [info instance];
        if ([instance conformsToProtocol:@protocol(SDPAutoTrackIsIgnoredProtocol)] && instance.sdp_autotrack_isIgnored) {
            return;
        }
        #pragma mark 标记 tableview headerview footerview 的位置
        SEL viewForSupplementaryElementOfKindSEL = @selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:);
        if ([datasouce respondsToSelector:viewForSupplementaryElementOfKindSEL]) {
            [datasouce sdp_aspect_hookSelector:viewForSupplementaryElementOfKindSEL
                                   withOptions:SDPAspectPositionAfter
                                    usingBlock: ^(id<SDPAspectInfo> info) {
                SDP_AUTOTRACK_TRY_CATCH_BEGIN
                NSString *kind = info.arguments[1];
                NSIndexPath *indexPath = [info.arguments lastObject];
                NSInvocation *invocation = info.originalInvocation;
                __unsafe_unretained UIView *value = nil;
                [invocation getReturnValue:&value];
                value.sdp_autotrack_header_footer_section = indexPath.section;
                if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
                    value.sdp_autotrack_header_footer_view_type = SDPAutoTrackViewInHeaderView;
                } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
                    value.sdp_autotrack_header_footer_view_type = SDPAutoTrackViewInFooterView;
                }
                SDP_AUTOTRACK_TRY_CATCH_END
            } ];
        }

        SDP_AUTOTRACK_TRY_CATCH_END
    } ];
    [self addAspectToken:token];

    #pragma mark - UITextField 监听 获取焦点 事件
    SEL notifyDidBeginEditingSel = NSSelectorFromString(@"_notifyDidBeginEditing");
    token = [UITextField sdp_aspect_hookSelector:notifyDidBeginEditingSel
                                     withOptions:SDPAspectPositionAfter
                                      usingBlock:^(id<SDPAspectInfo> info) {
        SDP_AUTOTRACK_TRY_CATCH_BEGIN
        UITextField<SDPAutoTrackElementIsIgnoredProtocol> *textField = [info instance];
        SDPReportPolicy reportPolicy;
        if ([textField sdp_autotrack_isIgnored:SDPAutoTrackControlOnFocus reportPolicy:&reportPolicy]) {
            return;
        }
        NSDictionary *trackInfo = [SDPAutoTrackUtils trackInfoWithAutoTrackObject:textField eventType:SDPAutoTrackControlOnFocus];
        [SDPAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:reportPolicy];
        SDP_AUTOTRACK_TRY_CATCH_END
    }];
    [self addAspectToken:token];
    #pragma mark - UITextField 监听 失去焦点 事件
    SEL notifyDidEndEditingSEL = NSSelectorFromString(@"_notifyDidEndEditing");
    token = [UITextField sdp_aspect_hookSelector:notifyDidEndEditingSEL
                                     withOptions:SDPAspectPositionAfter
                                      usingBlock:^(id<SDPAspectInfo> info) {
        SDP_AUTOTRACK_TRY_CATCH_BEGIN
        UITextField<SDPAutoTrackElementIsIgnoredProtocol> *textField = [info instance];
        SDPReportPolicy reportPolicy;
        if ([textField sdp_autotrack_isIgnored:SDPAutoTrackControlOnBlur reportPolicy:&reportPolicy]) {
            return;
        }

        NSDictionary *trackInfo = [SDPAutoTrackUtils trackInfoWithAutoTrackObject:textField eventType:SDPAutoTrackControlOnBlur];
        [SDPAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:reportPolicy];
        SDP_AUTOTRACK_TRY_CATCH_END
    }];
    [self addAspectToken:token];

    #pragma mark - UIAlertController 监听按钮点击
    SEL _invokeHandlersForActionSEL = NSSelectorFromString(@"_invokeHandlersForAction:");
    token = [UIAlertController sdp_aspect_hookSelector:_invokeHandlersForActionSEL withOptions:SDPAspectPositionBefore usingBlock:^(id<SDPAspectInfo> info) {
        UIAlertController<SDPAutoTrackViewProperty> *alertController = [info instance];
        SDPReportPolicy reportPolicy;
        UIAlertAction<SDPAutoTrackUIAlertActionProperty> *action = [[info arguments]firstObject];
        if ([alertController sdp_autotrack_isIgnored:SDPAutoTrackControlClick reportPolicy:&reportPolicy]) {
            return;
        }
        NSDictionary *trackInfo = [SDPAutoTrackUtils trackInfoWithAlertController:alertController action:action];
        [SDPAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:reportPolicy];
    }];
    [self addAspectToken:token];

    SDP_AUTOTRACK_TRY_CATCH_END
}

#pragma mark -  禁用自动打点
+ (void)disableAutoTrack {
    SDPAutoTrack *singleton = [SDPAutoTrack sharedInstance];
    [singleton.aspectTokenArray enumerateObjectsUsingBlock:^(id<SDPAspectToken>  _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [obj remove];
    }];
    [singleton.aspectTokenArray removeAllObjects];
    singleton.isEnableAutoTrack = NO;
}

#pragma mark - 添加 AspectToken
+ (void)addAspectToken:(id<SDPAspectToken>)token {
    if (token) {
        SDPAutoTrack *singleton = [SDPAutoTrack sharedInstance];
        [singleton.aspectTokenArray addObject:token];
    }
}

@end
