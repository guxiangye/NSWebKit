//
//  NSSingleHttpToolBox.m
//  NSKit
//
//  Created by Neil on 2023/5/6.
//

#import "NSSingleHttpToolBox.h"



@interface NSSingleHttpToolBox ()

@end

@implementation NSSingleHttpToolBox
-(instancetype)initWithConfig:(NSNetworkConfig *)config baseURL:(NSString *)baseURL{
    if (self = [super init]) {
        self.config = config;
        self.session = [[NSNetworkSessionManager alloc]initWithBaseURL:[NSURL URLWithString:baseURL] interpectors:config.interceptors];
        self.session.timeoutSeconds = config.timeoutSeconds;
    }
    return self;
}


@end
