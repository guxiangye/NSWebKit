//
//  NSCustomCameraPlugin.m
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//

#import "NSCustomCameraPlugin.h"
#import <Photos/Photos.h>
#import <WebKit/WebKit.h>
#import "LBXPermission.h"
#import "NSString+YYAdd.h"
#import "NSChooseImageUtil.h"
#import "UIImage+YYAdd.h"
#import "UIImage+ZYCompressMoments.h"

@interface NSCustomCameraPlugin ()

@end

@implementation NSCustomCameraPlugin

#pragma mark - 将图片保存到手机相册
- (void)saveImageToPhotosAlbum:(CDVInvokedUrlCommand *)command {
    NSString *base64Image = [command.arguments.firstObject objectForKey:@"base64Image"];

    //去除data:image/*;base64,前缀
    base64Image = [base64Image stringByReplacingRegex:@"data:image/[a-z]+;base64," options:NSRegularExpressionCaseInsensitive withString:@""];

    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64Image options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *image = [UIImage imageWithData:imageData];

    [LBXPermission authorizeWithType:LBXPermissionType_Photos
                          completion:^(BOOL granted, BOOL firstTime) {
        if (granted) {
            [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
                [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            }
                                             completionHandler:^(BOOL success, NSError *_Nullable error) {
                if (error) {
                    CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsDictionary:@{ @"errCode": @(error.code), @"errorMsg": error.description }];
                    dispatch_async(dispatch_get_main_queue(), ^() {
                                       [self.commandDelegate sendPluginResult:plugResult
                                                                   callbackId:command.callbackId];
                                   });
                } else {
                    CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                messageAsDictionary:@{ @"errCode": @0 }];
                    dispatch_async(dispatch_get_main_queue(), ^() {
                                       [self.commandDelegate sendPluginResult:plugResult
                                                                   callbackId:command.callbackId];
                                   });
                }
            }];
        } else if (!firstTime) {
            //不是第一次请求权限，那么可以弹出权限提示，用户选择设置，即跳转到设置界面，设置权限
            [LBXPermissionSetting showAlertToDislayPrivacySettingWithTitle:@"提示"
                                                                       msg:@"没有相册权限，是否前往设置"
                                                                    cancel:@"取消"
                                                                   setting:@"设置"];
        }
    }];
}

#pragma mark - 压缩图片
- (void)compressImage:(CDVInvokedUrlCommand *)command {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *base64Image = [command.arguments.firstObject objectForKey:@"base64Image"];
        //去除data:image/*;base64,前缀
        base64Image = [base64Image stringByReplacingRegex:@"data:image/[a-z]+;base64," options:NSRegularExpressionCaseInsensitive withString:@""];


        NSInteger maxLength = [[command.arguments.firstObject objectForKey:@"maxLength"]integerValue];

        if (maxLength == 0) {
            maxLength = 500 * 1024;
        }

        if (maxLength < 1024 * 50) {
            //最低不能低于50K
            maxLength = 50 * 1024;
        }

        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64Image options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *image = nil;

        if (imageData) {
            image = [UIImage imageWithData:imageData];

            if (image) {
                image = [self compressImageSize:image toByte:maxLength];
            }
        }

        if (image) {
            NSData *data = UIImageJPEGRepresentation(image, 1.0f);
            NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];

            dispatch_async(dispatch_get_main_queue(), ^{
                CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{ @"errCode": @0, @"base64Image": encodedImageStr }];
                [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{ @"errCode": @-1, @"errorMsg": @"图片压缩失败" }];
                [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
            });
        }
    });
}

- (UIImage *)compressImageSize:(UIImage *)image toByte:(NSUInteger)maxLength {
    //先用鲁班算法压一遍
    NSData *data = [image zy_compressForMoments];

    image = [UIImage imageWithData:data];
    NSUInteger lastDataLength = 0;

    while (data.length > maxLength && data.length != lastDataLength) {
        NSLog(@"压缩前:%ld", data.length);
        lastDataLength = data.length;
        //获取处理后的尺寸
        CGFloat ratio = 0.95;
        CGSize size = CGSizeMake((NSUInteger)(image.size.width * sqrtf(ratio)),
                                 (NSUInteger)(image.size.height * sqrtf(ratio)));
        image = [image imageByResizeToSize:size];
        //用鲁班算法压一遍
        data = [image zy_compressForMoments];
        NSLog(@"压缩后:%ld", data.length);
    }

    return image;
}

#pragma mark - 选择图片
- (void)chooseImage:(CDVInvokedUrlCommand *)command {
    NSString *sourceType = [command.arguments.firstObject objectForKey:@"sourceType"];
    NSArray *sizeTypeArray = [command.arguments.firstObject objectForKey:@"sizeType"];

    NSChooseSizeType sizeType = NSChooseSizeTypeCompressed;

    if (sizeTypeArray.count >= 2) {
        sizeType = NSChooseSizeTypeAll;
    } else {
        if ([sizeTypeArray.firstObject isEqualToString:@"original"]) {
            sizeType = NSChooseSizeTypeOriginal;
        } else {
            sizeType = NSChooseSizeTypeCompressed;
        }
    }

    int maxCount = 1;

    if ([command.arguments.firstObject objectForKey:@"count"]) {
        maxCount = [[command.arguments.firstObject objectForKey:@"count"]intValue];
    }

    if ([sourceType isEqualToString:@"camera"]) {
        //相机
        [NSChooseImageUtil chooseImageWithController:self.viewController
                                               count:maxCount
                                            sizeType:sizeType
                                          sourceType:NSChooseSourceCameraType
                                     completionBlock:^(NSArray *_Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                               CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                           messageAsDictionary:@{ @"errCode": @0, @"data": result }];
                               [self.commandDelegate sendPluginResult:plugResult
                                                           callbackId:command.callbackId];
                           });
        }];
    } else {
        //相册选择

        [NSChooseImageUtil chooseImageWithController:self.viewController
                                               count:maxCount
                                            sizeType:sizeType
                                          sourceType:NSChooseSourceAlbumType
                                     completionBlock:^(NSArray *_Nonnull result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                               CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                                           messageAsDictionary:@{ @"errCode": @0, @"data": result }];
                               [self.commandDelegate sendPluginResult:plugResult
                                                           callbackId:command.callbackId];
                           });
        }];
    }
}

@end
