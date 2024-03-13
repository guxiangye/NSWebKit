//
//  SPNetwork.m
//  SPKit
//
//  Created by 高鹏程 on 2023/5/5.
//

#import "SPNetwork.h"
#import "SPHttpManager.h"
@implementation SPNetwork


+(void)registerConfig:(SPNetworkConfig *)config baseURL:(NSString*)baseURL{
    [[SPHttpManager sharedInstance]registerConfig:config baseURL:baseURL];
}


@end
