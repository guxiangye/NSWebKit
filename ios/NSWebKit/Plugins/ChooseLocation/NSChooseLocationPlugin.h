//
//  NSChooseLocationPlugin.h
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//

#import "CDV.h"

@interface NSChooseLocationPlugin : CDVPlugin

/// 获取定位
- (void)getLocationInfo:(CDVInvokedUrlCommand *)command;

/// 地图点选
- (void)chooseLocation:(CDVInvokedUrlCommand *)command;

@end
