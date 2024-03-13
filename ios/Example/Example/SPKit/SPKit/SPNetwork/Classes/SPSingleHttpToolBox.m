//
//  SPSingleHttpToolBox.m
//  SPKit
//
//  Created by 高鹏程 on 2023/5/6.
//

#import "SPSingleHttpToolBox.h"



@interface SPSingleHttpToolBox ()

@end

@implementation SPSingleHttpToolBox
-(instancetype)initWithConfig:(SPNetworkConfig *)config baseURL:(NSString *)baseURL{
    if (self = [super init]) {
        self.config = config;
        self.session = [[SDPNetworkSessionManager alloc]initWithBaseURL:[NSURL URLWithString:baseURL] interpectors:config.interceptors];
        self.session.timeoutSeconds = config.timeoutSeconds;
    }
    return self;
}


@end
