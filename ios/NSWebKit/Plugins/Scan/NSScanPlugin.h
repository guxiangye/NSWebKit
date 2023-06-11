//
//  NSScanPlugin.h
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//


#import "CDV.h"

@interface NSScanPlugin : CDVPlugin

/// 扫码
- (void)scanCode:(CDVInvokedUrlCommand *)command;

@end
