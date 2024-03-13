//
//  NSNetwork.m
//  NSKit
//
//  Created by Neil on 2023/5/5.
//

#import "NSNetwork.h"
#import "NSHttpManager.h"
@implementation NSNetwork


+(void)registerConfig:(NSNetworkConfig *)config baseURL:(NSString*)baseURL{
    [[NSHttpManager sharedInstance]registerConfig:config baseURL:baseURL];
}


@end
