//
//  NSScanPlugin.m
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//

#import "NSScanPlugin.h"
#import "LBXPermission.h"
#import "NSScanViewController.h"

@interface NSScanPlugin ()

@end

@implementation NSScanPlugin

#pragma mark - 扫码
- (void)scanCode:(CDVInvokedUrlCommand *)command {
    NSScanViewController *vc = [NSScanViewController new];

    NSDictionary *param = command.arguments.firstObject;

    if (param && ![param isKindOfClass:[NSNull class]]) {
        BOOL hideAlbum = [[param objectForKey:@"hideAlbum"]boolValue];
        NSArray *scanType =  [param objectForKey:@"scanType"];

        if (scanType && [scanType isKindOfClass:[NSArray class]]) {
            vc.supportScanTypeArray = scanType;
        }
        vc.hideAlbum = hideAlbum;
    }

    vc.scanResultBlock = ^(NSDictionary *result) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:result];
        dic[@"errCode"] = @0;
        CDVPluginResult *plugResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic.copy];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.commandDelegate sendPluginResult:plugResult callbackId:command.callbackId];
        });
    };
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

@end
