//
//  NSWebWeakScriptMessageHandler.h
//  OUYEEI_FINANCIAL
//
//  Created by 相晔谷 on 2019/7/5.
//  Copyright © 2019 neil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSWebWeakScriptMessageHandler : NSObject
<WKScriptMessageHandler>

@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end

NS_ASSUME_NONNULL_END
