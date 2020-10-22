//
//  NSWebWeakScriptMessageHandler.m
//  OUYEEI_FINANCIAL
//
//  Created by 相晔谷 on 2019/7/5.
//  Copyright © 2019 neil. All rights reserved.
//

#import "NSWebWeakScriptMessageHandler.h"

@implementation NSWebWeakScriptMessageHandler

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

@end
