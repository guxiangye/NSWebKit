//
//  NSLocationPlugin.h
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//

#import "CDV.h"

@interface NSLocationPlugin : CDVPlugin

/// 获取定位
- (void)getLocationInfo:(CDVInvokedUrlCommand *)command;

@end
