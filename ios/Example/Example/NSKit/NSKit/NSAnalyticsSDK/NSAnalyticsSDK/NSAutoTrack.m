//
//  NSAutoTrack.m
//  NSAutoTrack
//
//  Created by Neil on 2020/5/19.
//  Copyright © 2020 Neil. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "NSAutoTrack.h"
#import "NSAspects.h"
#import "UIGestureRecognizer+NSAutoTrack.h"
#import "UIView+NSAutoTrack.h"
#import "NSAnalyticsManager.h"
#import "NSAutoTrackUtils.h"
#import "UIView+NSAutoTrackTableHeaderFooterView.h"
#import "NSAnalyticsSDK.h"
#import "NSAnalyticsSDK+AutoTrack.h"
#import "NSAutoTrackConstants.h"
#import <objc/runtime.h>
#import "UIImage+NSAutoTrack.h"
#import "NSReportManager.h"

@interface NSAutoTrack ()

/// 存储 所有 自动埋点的 NSAspectToken 方便以后移除
@property (nonatomic, strong) NSMutableArray<id<NSAspectToken> > *aspectTokenArray;

/// 是否开启自动埋点
@property (nonatomic, assign) BOOL isEnableAutoTrack;
@end

@implementation NSAutoTrack

+ (NSAutoTrack *)sharedInstance {
    static NSAutoTrack *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        _instance.aspectTokenArray = [[NSMutableArray alloc]init];
    });
    return _instance;
}

#pragma mark - 开启自动埋点
+ (void)enableAutoTrack {
    NS_AUTOTRACK_TRY_CATCH_BEGIN
    NSAutoTrack *singleton = [NSAutoTrack sharedInstance];
    if (singleton.isEnableAutoTrack) {
        return;
    }
    //延迟10秒发起上报
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSReportManager sharedInstance] dispatch:0];
        [[NSReportManager sharedInstance] dispatch:1];
        [[NSReportManager sharedInstance] dispatch:2];
        [[NSReportManager sharedInstance] dispatch:3];
    });
    singleton.isEnableAutoTrack = YES;
    #pragma mark - 生成全局sessionId
    [NSAnalyticsManager generateSessionId];
    #pragma mark - 从UIImage 里 获取从 bundle 读取图片的文件名
    Class classMetal = object_getClass([UIImage class]);
    id<NSAspectToken>token = [classMetal sdp_aspect_hookSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:) withOptions:NSAspectPositionAfter usingBlock:^(id<NSAspectInfo>info) {
        NS_AUTOTRACK_TRY_CATCH_BEGIN
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
        NS_AUTOTRACK_TRY_CATCH_END
    }];
    [self addAspectToken:token];

    #pragma mark - 从UImageView 获取 网络图片地址

    if (NSClassFromString(@"NSAnimatedImageView")) {
        SEL sdp_setImageWithURLSEL = NSSelectorFromString(@"sdp_setImageWithURL:placeholder:options:manager:progress:transform:completion:");
        token = [UIImageView sdp_aspect_hookSelector:sdp_setImageWithURLSEL withOptions:NSAspectPositionBefore usingBlock:^(id<NSAspectInfo>info) {
            NS_AUTOTRACK_TRY_CATCH_BEGIN
            UIImageView *imageView = info.instance;
            NSURL *url = [[info arguments]firstObject];
            [imageView setSdp_autotrack_filename:[url.absoluteString lastPathComponent]];
            NS_AUTOTRACK_TRY_CATCH_END
        }];
        [self addAspectToken:token];

        sdp_setImageWithURLSEL = NSSelectorFromString(@"sdp_setImageWithURL:forState:placeholder:options:manager:progress:transform:completion:");
        token = [UIButton sdp_aspect_hookSelector:sdp_setImageWithURLSEL withOptions:NSAspectPositionBefore usingBlock:^(id<NSAspectInfo>info) {
            NS_AUTOTRACK_TRY_CATCH_BEGIN

            UIControlState state = [[info arguments][1]integerValue];
            if (state == UIControlStateNormal) {
                UIButton *button = info.instance;
                NSURL *url = [[info arguments]firstObject];
                [button setSdp_autotrack_filename:[url.absoluteString lastPathComponent]];
            }

            NS_AUTOTRACK_TRY_CATCH_END
        }];
        [self addAspectToken:token];
    }
    //取消页面创建时上送的 上下文信息 2023.3.31
//    #pragma mark - 控制器的加载 获取页面上下文
//    token = [UIViewController sdp_aspect_hookSelector:@selector(viewDidLoad)
//                                          withOptions:NSAspectPositionAfter
//                                           usingBlock:^(id<NSAspectInfo> info) {
//        NS_AUTOTRACK_TRY_CATCH_BEGIN
//        UIViewController<NSAutoTrackElementIsIgnoredProtocol> *viewController = [info instance];
//
//        if (viewController.sdp_autotrack_isIgnored) {
//            return;
//        }
//        NSReportPolicy reportPolicy;
//        if ([viewController sdp_autotrack_isIgnored:NSAutoTrackControlShow reportPolicy:&reportPolicy]) {
//            return;
//        }
//        NS_AUTOTRACK_TRY_CATCH_END
//    }];
//    [self addAspectToken:token];
    #pragma mark - 控制器的显示
    token = [UIViewController sdp_aspect_hookSelector:@selector(viewDidAppear:)
                                          withOptions:NSAspectPositionBefore
                                           usingBlock:^(id<NSAspectInfo>info) {
        NS_AUTOTRACK_TRY_CATCH_BEGIN
        UIViewController<NSAutoTrackElementIsIgnoredProtocol> *viewController = [info instance];

        if (viewController.sdp_autotrack_isIgnored) {
            return;
        }
        NSReportPolicy reportPolicy;
        if ([viewController sdp_autotrack_isIgnored:NSAutoTrackControlShow reportPolicy:&reportPolicy]) {
            return;
        }
        NSDictionary *trackInfo = nil;
        if ([viewController isKindOfClass:[UIAlertController class]]) {
            //弹出框 属于 ControlShow

            trackInfo = [NSAutoTrackUtils trackInfoWithAlertController:(id)viewController eventType:NSAutoTrackControlShow];
        } else {
            //VC 属于 PageAppear

            trackInfo = [NSAutoTrackUtils trackInfoWithViewController:viewController eventType:NSAutoTrackPageAppear];
        }

        [NSAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:reportPolicy];
        NS_AUTOTRACK_TRY_CATCH_END
    } ];
    [self addAspectToken:token];
//    #pragma mark 控制器的消失
//    token = [UIViewController sdp_aspect_hookSelector:@selector(viewDidDisappear:)
//                                          withOptions:NSAspectPositionBefore
//                                           usingBlock:^(id<NSAspectInfo>info) {
//        NS_AUTOTRACK_TRY_CATCH_BEGIN
//        UIViewController<NSAutoTrackViewControllerProperty> *viewController = [info instance];
//
//        NSReportPolicy reportPolicy;
//        if ([viewController sdp_autotrack_isIgnored:NSAutoTrackPageDisappear reportPolicy:&reportPolicy]) {
//            return;
//        }
//        NSDictionary *trackInfo = [NSAutoTrackUtils trackInfoWithViewController:viewController eventType:NSAutoTrackPageDisappear];
//        [NSAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:reportPolicy];
//        NS_AUTOTRACK_TRY_CATCH_END
//    } ];
//    [self addAspectToken:token];

    #pragma mark - 响应链点击事件
    token = [UIApplication sdp_aspect_hookSelector:@selector(sendAction:to:from:forEvent:)
                                       withOptions:NSAspectPositionBefore
                                        usingBlock:^(id<NSAspectInfo>info) {
        NS_AUTOTRACK_TRY_CATCH_BEGIN
        NSReportPolicy reportPolicy;
        NSArray *arguments = [info arguments];
        UIView<NSAutoTrackViewProperty> *sender = arguments[2];
        //UITextFile 和 UITextVIew  不响应
        if ([sender isKindOfClass:UITextField.class] || [sender isKindOfClass:UITextView.class]) {
            return;
        }
        if (![sender conformsToProtocol:@protocol(NSAutoTrackViewProperty)] || [sender sdp_autotrack_isIgnored:NSAutoTrackControlClick reportPolicy:&reportPolicy]) {
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
        NSDictionary *trackInfo = [NSAutoTrackUtils trackInfoWithAutoTrackObject:sender eventType:NSAutoTrackControlClick];
        [NSAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:reportPolicy];
        NS_AUTOTRACK_TRY_CATCH_END
    }];
    [self addAspectToken:token];

    #pragma mark - 手势事件
    token = [UITapGestureRecognizer sdp_aspect_hookSelector:@selector(initWithTarget:action:)
                                                withOptions:NSAspectPositionAfter
                                                 usingBlock:^(id<NSAspectInfo>info) {
        NS_AUTOTRACK_TRY_CATCH_BEGIN
        UITapGestureRecognizer *gesture = [info instance];
        NSReportPolicy reportPolicy;
        [gesture addActionBlock:^(UIGestureRecognizer *_Nonnull sender) {
            UIView<NSAutoTrackViewProperty> *view = (id)sender.view;
            if ([view sdp_autotrack_isIgnored:NSAutoTrackControlClick reportPolicy:&reportPolicy]) {
                return;
            }
            NSDictionary *trackInfo = [NSAutoTrackUtils trackInfoWithAutoTrackObject:view eventType:NSAutoTrackControlClick];
            [NSAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:reportPolicy];
        }];
        NS_AUTOTRACK_TRY_CATCH_END
    } ];
    [self addAspectToken:token];

    #pragma mark  UITableView
    token = [UITableView sdp_aspect_hookSelector:@selector(setDelegate:)
                                     withOptions:NSAspectPositionAfter
                                      usingBlock:^(id<NSAspectInfo>info) {
        NS_AUTOTRACK_TRY_CATCH_BEGIN
        id delegate = [[info arguments]firstObject];
        if ([NSAutoTrackUtils isNull:delegate]) {
            return;
        }
        id<NSAutoTrackIsIgnoredProtocol> instance = [info instance];
        if ([instance conformsToProtocol:@protocol(NSAutoTrackIsIgnoredProtocol)] && instance.sdp_autotrack_isIgnored) {
            return;
        }

        #pragma mark UITableView Cell的点击事件
        SEL didSelectRowAtIndexPathSEL = @selector(tableView:didSelectRowAtIndexPath:);
        if ([delegate respondsToSelector:didSelectRowAtIndexPathSEL]) {
            [delegate sdp_aspect_hookSelector:didSelectRowAtIndexPathSEL
                                  withOptions:NSAspectPositionBefore
                                   usingBlock:^(id<NSAspectInfo> info)
            {
                NS_AUTOTRACK_TRY_CATCH_BEGIN
                NSReportPolicy reportPolicy;
                UITableView<NSAutoTrackElementIsIgnoredProtocol> *table = [info.arguments firstObject];
                if ([table sdp_autotrack_isIgnored:NSAutoTrackControlClick reportPolicy:&reportPolicy]) {
                    return;
                }
                NSIndexPath *indexPath = [info.arguments lastObject];
                UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
                NSDictionary *trackInfo = [NSAutoTrackUtils trackInfoWithAutoTrackObject:cell eventType:NSAutoTrackControlClick];
                [NSAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:reportPolicy];
                NS_AUTOTRACK_TRY_CATCH_END
            }];
        }

        #pragma mark 标记 tableview headerview 的位置
        SEL viewForHeaderInSectionSEL = @selector(tableView:viewForHeaderInSection:);
        if ([delegate respondsToSelector:viewForHeaderInSectionSEL]) {
            [delegate sdp_aspect_hookSelector:viewForHeaderInSectionSEL
                                  withOptions:NSAspectPositionAfter
                                   usingBlock:^(id<NSAspectInfo> info) {
                NS_AUTOTRACK_TRY_CATCH_BEGIN
                NSInteger section = [[info.arguments lastObject]integerValue];
                NSInvocation *invocation = info.originalInvocation;
                __unsafe_unretained UIView *value = nil;
                [invocation getReturnValue:&value];
                value.sdp_autotrack_header_footer_view_type = NSAutoTrackViewInHeaderView;
                value.sdp_autotrack_header_footer_section = section;
                NS_AUTOTRACK_TRY_CATCH_END
            } ];
        }

        #pragma mark 标记 tableview footerview 的位置
        SEL viewForFooterInSectionSEL = @selector(tableView:viewForFooterInSection:);
        if ([delegate respondsToSelector:viewForFooterInSectionSEL]) {
            [delegate sdp_aspect_hookSelector:viewForFooterInSectionSEL
                                  withOptions:NSAspectPositionAfter
                                   usingBlock:^(id<NSAspectInfo> info) {
                NS_AUTOTRACK_TRY_CATCH_BEGIN
                NSInteger section = [[info.arguments lastObject]integerValue];
                NSInvocation *invocation = info.originalInvocation;
                __unsafe_unretained UIView *value = nil;
                [invocation getReturnValue:&value];
                value.sdp_autotrack_header_footer_view_type = NSAutoTrackViewInFooterView;
                value.sdp_autotrack_header_footer_section = section;
                NS_AUTOTRACK_TRY_CATCH_END
            } ];
        }

        NS_AUTOTRACK_TRY_CATCH_END
    } ];
    [self addAspectToken:token];

    #pragma mark - UICollectionView setDelegate:
    token = [UICollectionView sdp_aspect_hookSelector:@selector(setDelegate:)
                                          withOptions:NSAspectPositionAfter
                                           usingBlock:^(id<NSAspectInfo> info) {
        NS_AUTOTRACK_TRY_CATCH_BEGIN
        id delegate = [[info arguments]firstObject];
        if ([NSAutoTrackUtils isNull:delegate]) {
            return;
        }
        id<NSAutoTrackIsIgnoredProtocol> instance = [info instance];
        if ([instance conformsToProtocol:@protocol(NSAutoTrackIsIgnoredProtocol)] && instance.sdp_autotrack_isIgnored) {
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
                                  withOptions:NSAspectPositionBefore
                                   usingBlock:^(id<NSAspectInfo> info) {
                NS_AUTOTRACK_TRY_CATCH_BEGIN
                NSReportPolicy reportPolicy;
                UICollectionView<NSAutoTrackElementIsIgnoredProtocol> *collection = [info.arguments firstObject];
                if ([collection sdp_autotrack_isIgnored:NSAutoTrackControlClick reportPolicy:&reportPolicy]) {
                    return;
                }
                NSIndexPath *indexPath = [info.arguments lastObject];
                UICollectionViewCell *cell = [collection cellForItemAtIndexPath:indexPath];
                UIView<NSAutoTrackViewProperty> *view = cell;
                NSDictionary *trackInfo = [NSAutoTrackUtils trackInfoWithAutoTrackObject:view eventType:NSAutoTrackControlClick];
                [NSAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:reportPolicy];
                NS_AUTOTRACK_TRY_CATCH_END
            }];
        }

        NS_AUTOTRACK_TRY_CATCH_END
    } ];
    [self addAspectToken:token];

    #pragma mark - UICollectionView setDataSource:
    token = [UICollectionView sdp_aspect_hookSelector:@selector(setDataSource:)
                                          withOptions:NSAspectPositionAfter
                                           usingBlock:^(id<NSAspectInfo> info) {
        NS_AUTOTRACK_TRY_CATCH_BEGIN
        id datasouce = [[info arguments]firstObject];
        if ([NSAutoTrackUtils isNull:datasouce]) {
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
        id<NSAutoTrackIsIgnoredProtocol> instance = [info instance];
        if ([instance conformsToProtocol:@protocol(NSAutoTrackIsIgnoredProtocol)] && instance.sdp_autotrack_isIgnored) {
            return;
        }
        #pragma mark 标记 tableview headerview footerview 的位置
        SEL viewForSupplementaryElementOfKindSEL = @selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:);
        if ([datasouce respondsToSelector:viewForSupplementaryElementOfKindSEL]) {
            [datasouce sdp_aspect_hookSelector:viewForSupplementaryElementOfKindSEL
                                   withOptions:NSAspectPositionAfter
                                    usingBlock: ^(id<NSAspectInfo> info) {
                NS_AUTOTRACK_TRY_CATCH_BEGIN
                NSString *kind = info.arguments[1];
                NSIndexPath *indexPath = [info.arguments lastObject];
                NSInvocation *invocation = info.originalInvocation;
                __unsafe_unretained UIView *value = nil;
                [invocation getReturnValue:&value];
                value.sdp_autotrack_header_footer_section = indexPath.section;
                if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
                    value.sdp_autotrack_header_footer_view_type = NSAutoTrackViewInHeaderView;
                } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
                    value.sdp_autotrack_header_footer_view_type = NSAutoTrackViewInFooterView;
                }
                NS_AUTOTRACK_TRY_CATCH_END
            } ];
        }

        NS_AUTOTRACK_TRY_CATCH_END
    } ];
    [self addAspectToken:token];

    #pragma mark - UITextField 监听 获取焦点 事件
    SEL notifyDidBeginEditingSel = NSSelectorFromString(@"_notifyDidBeginEditing");
    token = [UITextField sdp_aspect_hookSelector:notifyDidBeginEditingSel
                                     withOptions:NSAspectPositionAfter
                                      usingBlock:^(id<NSAspectInfo> info) {
        NS_AUTOTRACK_TRY_CATCH_BEGIN
        UITextField<NSAutoTrackElementIsIgnoredProtocol> *textField = [info instance];
        NSReportPolicy reportPolicy;
        if ([textField sdp_autotrack_isIgnored:NSAutoTrackControlOnFocus reportPolicy:&reportPolicy]) {
            return;
        }
        NSDictionary *trackInfo = [NSAutoTrackUtils trackInfoWithAutoTrackObject:textField eventType:NSAutoTrackControlOnFocus];
        [NSAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:reportPolicy];
        NS_AUTOTRACK_TRY_CATCH_END
    }];
    [self addAspectToken:token];
    #pragma mark - UITextField 监听 失去焦点 事件
    SEL notifyDidEndEditingSEL = NSSelectorFromString(@"_notifyDidEndEditing");
    token = [UITextField sdp_aspect_hookSelector:notifyDidEndEditingSEL
                                     withOptions:NSAspectPositionAfter
                                      usingBlock:^(id<NSAspectInfo> info) {
        NS_AUTOTRACK_TRY_CATCH_BEGIN
        UITextField<NSAutoTrackElementIsIgnoredProtocol> *textField = [info instance];
        NSReportPolicy reportPolicy;
        if ([textField sdp_autotrack_isIgnored:NSAutoTrackControlOnBlur reportPolicy:&reportPolicy]) {
            return;
        }

        NSDictionary *trackInfo = [NSAutoTrackUtils trackInfoWithAutoTrackObject:textField eventType:NSAutoTrackControlOnBlur];
        [NSAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:reportPolicy];
        NS_AUTOTRACK_TRY_CATCH_END
    }];
    [self addAspectToken:token];

    #pragma mark - UIAlertController 监听按钮点击
    SEL _invokeHandlersForActionSEL = NSSelectorFromString(@"_invokeHandlersForAction:");
    token = [UIAlertController sdp_aspect_hookSelector:_invokeHandlersForActionSEL withOptions:NSAspectPositionBefore usingBlock:^(id<NSAspectInfo> info) {
        UIAlertController<NSAutoTrackViewProperty> *alertController = [info instance];
        NSReportPolicy reportPolicy;
        UIAlertAction<NSAutoTrackUIAlertActionProperty> *action = [[info arguments]firstObject];
        if ([alertController sdp_autotrack_isIgnored:NSAutoTrackControlClick reportPolicy:&reportPolicy]) {
            return;
        }
        NSDictionary *trackInfo = [NSAutoTrackUtils trackInfoWithAlertController:alertController action:action];
        [NSAnalyticsSDK autoTrackWithTrackInfo:trackInfo reportPolicy:reportPolicy];
    }];
    [self addAspectToken:token];

    NS_AUTOTRACK_TRY_CATCH_END
}

#pragma mark -  禁用自动打点
+ (void)disableAutoTrack {
    NSAutoTrack *singleton = [NSAutoTrack sharedInstance];
    [singleton.aspectTokenArray enumerateObjectsUsingBlock:^(id<NSAspectToken>  _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [obj remove];
    }];
    [singleton.aspectTokenArray removeAllObjects];
    singleton.isEnableAutoTrack = NO;
}

#pragma mark - 添加 AspectToken
+ (void)addAspectToken:(id<NSAspectToken>)token {
    if (token) {
        NSAutoTrack *singleton = [NSAutoTrack sharedInstance];
        [singleton.aspectTokenArray addObject:token];
    }
}

@end
