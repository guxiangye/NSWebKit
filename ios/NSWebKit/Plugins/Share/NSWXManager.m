//
//  NSWXManager.m
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//


#import "NSWXManager.h"

@interface NSWXManager ()

@property (nonatomic, copy) NSWXAuthCompletion authCompletion;
@property (nonatomic, copy) NSLaunchWXMiniprogramCompletion launchWXMiniprogramCompletion;
@property (nonatomic, copy) NSWXShareCompletion shareCompletion;

@end

@implementation NSShareToWXParam
@end


@implementation NSLaunchMiniprogramParam

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic{
    
    NSString *miniprogramType = dic[@"miniProgramType"];
    
    if ([miniprogramType isEqualToString:@"WXMiniProgramTypeRelease"]) {
        _miniProgramType = WXMiniProgramTypeRelease;
    }
    else if ([miniprogramType isEqualToString:@"WXMiniProgramTypeTest"]) {
        _miniProgramType = WXMiniProgramTypeTest;
    }
    else if ([miniprogramType isEqualToString:@"WXMiniProgramTypePreview"]) {
        _miniProgramType = WXMiniProgramTypePreview;
    }
    return YES;
}

@end

@implementation NSShareToWXMiniprogramParam
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"descript" : @"description"};
}
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic{
    
    NSString *miniprogramType = dic[@"miniProgramType"];
    
    if ([miniprogramType isEqualToString:@"WXMiniProgramTypeRelease"]) {
        _miniProgramType = WXMiniProgramTypeRelease;
    }
    else if ([miniprogramType isEqualToString:@"WXMiniProgramTypeTest"]) {
        _miniProgramType = WXMiniProgramTypeTest;
    }
    else if ([miniprogramType isEqualToString:@"WXMiniProgramTypePreview"]) {
        _miniProgramType = WXMiniProgramTypePreview;
    }

    NSString *hdImageData = dic[@"hdImageData"];
    if (hdImageData.length != 0) {
        if ([hdImageData hasPrefix:@"data:image/png;base64,"]) {
            hdImageData = [hdImageData stringByReplacingOccurrencesOfString:@"data:image/png;base64," withString:@""];
        }
        if ([hdImageData hasPrefix:@"data:image/jpeg;base64,"]) {
            hdImageData = [hdImageData stringByReplacingOccurrencesOfString:@"data:image/jpeg;base64," withString:@""];
        }
        _hdImageData = [[NSData alloc] initWithBase64EncodedString:hdImageData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    }

    

    return YES;
}


@end


@implementation NSWXManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static NSWXManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[NSWXManager alloc] init];
    });
    return instance;
}
#pragma mark - 微信授权
+ (void)sendWXAuthRequest:(NSWXAuthCompletion)completion {
    NSWXManager *manager = [NSWXManager sharedManager];
    manager.authCompletion = completion;
    //构造 SendAuthReq 结构体
    SendAuthReq *req = [[SendAuthReq alloc]init];
    req.scope = @"snsapi_userinfo";
    //第三方向微信终端发送一个 SendAuthReq 消息结构
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success == NO) {
            if (manager.authCompletion != nil) {
                manager.authCompletion(-1, nil);
            }
        }
    }];
}
#pragma mark - 打开小程序
+(void)launchWXMiniprogram:(NSLaunchMiniprogramParam*)param completion:(NSLaunchWXMiniprogramCompletion)completion{
    NSWXManager *manager = [NSWXManager sharedManager];
    manager.launchWXMiniprogramCompletion = completion;
    WXLaunchMiniProgramReq *launchMiniProgramReq = [WXLaunchMiniProgramReq object];
    launchMiniProgramReq.userName = param.userName;  //拉起的小程序的username
    launchMiniProgramReq.path = param.path;    ////拉起小程序页面的可带参路径，不填默认拉起小程序首页，对于小游戏，可以只传入 query 部分，来实现传参效果，如：传入 "?foo=bar"。
    launchMiniProgramReq.miniProgramType = param.miniProgramType; //拉起小程序的类型
    [WXApi sendReq:launchMiniProgramReq completion:^(BOOL success) {
        if (success == NO) {
            if (manager.launchWXMiniprogramCompletion != nil) {
                manager.launchWXMiniprogramCompletion(-1, nil);
            }
        }
        
    }];
}
#pragma mark - 分享到小程序
+(void)shareToWXMiniprogram:(NSShareToWXMiniprogramParam*)param completion:(NSWXShareCompletion)completion{
    NSWXManager *manager = [NSWXManager sharedManager];
    manager.shareCompletion = completion;
    
    WXMiniProgramObject *object = [WXMiniProgramObject object];
    object.webpageUrl = param.webpageUrl;
    object.userName = param.userName;
    object.path = param.path;
    object.hdImageData = param.hdImageData;
    object.withShareTicket = param.withShareTicket;
    object.miniProgramType = param.miniProgramType;
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = param.title;
    message.description = param.descript;
    message.thumbData = nil;  //兼容旧版本节点的图片，小于32KB，新版本优先
                              //使用 WXMiniProgramObject 的hdImageData属性
    message.mediaObject = object;
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;  //目前只支持会话
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success == NO) {
            if (manager.shareCompletion != nil) {
                manager.shareCompletion(-1);
            }
        }
        
    }];
    
    
}
#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        if (self.authCompletion) {
            self.authCompletion(resp.errCode, authResp.code);
            self.authCompletion = nil;
        }
    }
    else if ([resp isKindOfClass:[WXLaunchMiniProgramResp class]]) {
        WXLaunchMiniProgramResp *launchResp = (WXLaunchMiniProgramResp*)resp;
        if (self.launchWXMiniprogramCompletion) {
            self.launchWXMiniprogramCompletion(resp.errCode, launchResp.extMsg);
            self.launchWXMiniprogramCompletion = nil;
        }
        
    }
}

@end
