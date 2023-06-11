/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CDVWKWebViewUIDelegate.h"
#import "CDVJSON_private.h"
#import "CDVInvokedUrlCommand.h"
#import "CDVAvailability.h"
#import "CDVPlugin.h"
#include <objc/message.h>
@implementation CDVWKWebViewUIDelegate

- (instancetype)initWithTitle:(NSString*)title
{
    self = [super init];
    if (self) {
        self.title = title;
    }

    return self;
}

- (void)     webView:(WKWebView*)webView runJavaScriptAlertPanelWithMessage:(NSString*)message
    initiatedByFrame:(WKFrameInfo*)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:self.title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction* action)
        {
            completionHandler();
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];

    [alert addAction:ok];

    UIViewController* rootController = [UIApplication sharedApplication].delegate.window.rootViewController;

    [rootController presentViewController:alert animated:YES completion:nil];
}

- (void)     webView:(WKWebView*)webView runJavaScriptConfirmPanelWithMessage:(NSString*)message
    initiatedByFrame:(WKFrameInfo*)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:self.title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction* action)
        {
            completionHandler(YES);
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];

    [alert addAction:ok];

    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction* action)
        {
            completionHandler(NO);
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
    [alert addAction:cancel];

    UIViewController* rootController = [UIApplication sharedApplication].delegate.window.rootViewController;

    [rootController presentViewController:alert animated:YES completion:nil];
}

- (void)      webView:(WKWebView*)webView runJavaScriptTextInputPanelWithPrompt:(NSString*)prompt
          defaultText:(NSString*)defaultText initiatedByFrame:(WKFrameInfo*)frame
    completionHandler:(void (^)(NSString* result))completionHandler
{
    NSString * prefix=@"NSExecSync=";
    if ([prompt hasPrefix:prefix]) {
        NSArray *result = [prompt componentsSeparatedByString:prefix];
        NSArray *jsonEntry = [[result lastObject] cdv_JSONObject];

        BOOL (^validationCommandArguments)(NSArray* arguments) = ^(NSArray *arr){
        
            if (arr.count < 2) {
                return NO;
            }
            NSString* _className = arr[0];
            NSString* _methodName = arr[1];
            NSArray* _arguments = arr[2];
            if (![_className isKindOfClass:[NSString class]] || ![_methodName isKindOfClass:[NSString class]] ) {
                return NO;
            }
            if (_arguments != nil && ![_arguments isKindOfClass:[NSArray class]]) {
                return NO;
            }
            
            return YES;
        };
        

        if(validationCommandArguments(jsonEntry) == NO) {
            NSDictionary *result = @{@"errcode":@"1",@"errorMsg":@"数据格式不正确"};
            completionHandler([result cdv_JSONString]);
            return ;
        }
        else{
            NSString* _className = jsonEntry[0];
            NSString* _methodName = jsonEntry[1];
            NSArray* _arguments = jsonEntry[2];
            CDVInvokedUrlCommand *command = [[CDVInvokedUrlCommand alloc]initWithArguments:_arguments callbackId:nil className:_className methodName:_methodName];
            CDV_EXEC_LOG(@"ExecSync(%@): Calling %@.%@", command.callbackId, command.className, command.methodName);
            CDVPlugin* obj = [self.viewController.commandDelegate getCommandInstance:command.className];

            if (!([obj isKindOfClass:[CDVPlugin class]])) {
                NSLog(@"ERROR: Plugin '%@' not found, or is not a CDVPlugin. Check your plugin mapping in config.xml.", command.className);
                NSDictionary *result = @{@"errcode":@"1",@"errorMsg":@"ERROR: Plugin '%@' not found, or is not a CDVPlugin. Check your plugin mapping in config.xml"};
                completionHandler([result cdv_JSONString]);
                return ;
            }

            double started = [[NSDate date] timeIntervalSince1970] * 1000.0;
            // Find the proper selector to call.
            NSString* methodName = [NSString stringWithFormat:@"%@:", command.methodName];
            SEL normalSelector = NSSelectorFromString(methodName);
            if ([obj respondsToSelector:normalSelector]) {
                // [obj performSelector:normalSelector withObject:command];
                NSDictionary *result = ((id (*)(id, SEL, id))objc_msgSend)(obj, normalSelector, command);
                completionHandler([result cdv_JSONString]);
            } else {
                // There's no method to call, so throw an error.
                NSString *errMessage = [NSString stringWithFormat:@"ERROR: Method '%@' not defined in Plugin '%@'", methodName, command.className];
                NSLog(@"%@",errMessage);
                NSDictionary *result = @{@"errcode":@"1",@"errorMsg":errMessage};
                completionHandler([result cdv_JSONString]);
                return ;
            }
            double elapsed = [[NSDate date] timeIntervalSince1970] * 1000.0 - started;
            if (elapsed > 10) {
                NSLog(@"THREAD WARNING: ['%@'] took '%f' ms. Plugin should use a background thread.", command.className, elapsed);
            }

        }

        
    }
    else{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:self.title
                                                                       message:prompt
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction* action)
            {
                completionHandler(((UITextField*)alert.textFields[0]).text);
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];

        [alert addAction:ok];

        UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction* action)
            {
                completionHandler(nil);
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
        [alert addAction:cancel];

        [alert addTextFieldWithConfigurationHandler:^(UITextField* textField) {
            textField.text = defaultText;
        }];

        UIViewController* rootController = [UIApplication sharedApplication].delegate.window.rootViewController;

        [rootController presentViewController:alert animated:YES completion:nil];
    }
    

}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    // 修复_blank的bug
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}


@end
