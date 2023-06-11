//
//  NSCustomCameraPlugin.h
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//

#import "CDV.h"

@interface NSCustomCameraPlugin : CDVPlugin

/// 将图片保存到手机相册
- (void)saveImageToPhotosAlbum:(CDVInvokedUrlCommand *)command;

/// 压缩图片
- (void)compressImage:(CDVInvokedUrlCommand *)command;

/// 选择图片
- (void)chooseImage:(CDVInvokedUrlCommand *)command;

@end
