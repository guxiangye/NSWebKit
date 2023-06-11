//
//  NSWXManager.h
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "NSObject+YYModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^NSWXAuthCompletion)(int errCode,NSString *authCode);
typedef void(^NSWXShareCompletion)(int errCode);
typedef void(^NSLaunchWXMiniprogramCompletion)(int errCode,NSString *extMsg);


@interface NSShareToWXParam : NSObject
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *webpageUrl;
@property(nonatomic,copy)NSString *descript;
@property(nonatomic,copy)NSData *thumbImage;

@end


@interface NSLaunchMiniprogramParam : NSObject

@property(nonatomic,copy)NSString *userName;
@property(nonatomic,copy)NSString *path;
@property(nonatomic,assign)WXMiniProgramType miniProgramType;
@end

@interface NSShareToWXMiniprogramParam : NSObject
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *userName;
@property(nonatomic,copy)NSString *path;
@property(nonatomic,strong)NSData *hdImageData;
@property(nonatomic,copy)NSString *webpageUrl;
@property(nonatomic,copy)NSString *descript;
@property(nonatomic,copy)NSData *thumbImage;
@property(nonatomic,assign)BOOL withShareTicket;
@property(nonatomic,assign)WXMiniProgramType miniProgramType;
@end



@interface NSWXManager : NSObject<WXApiDelegate>
+ (instancetype)sharedManager;



/// 微信授权
/// @param completion 回调
+(void)sendWXAuthRequest:(NSWXAuthCompletion)completion;


/// 打开小程序
/// @param completion 回调
+(void)launchWXMiniprogram:(NSLaunchMiniprogramParam*)param completion:(NSLaunchWXMiniprogramCompletion)completion;

/// 分享到小程序
/// @param completion 回到
+(void)shareToWXMiniprogram:(NSShareToWXMiniprogramParam*)param completion:(NSWXShareCompletion)completion;

@end

NS_ASSUME_NONNULL_END
