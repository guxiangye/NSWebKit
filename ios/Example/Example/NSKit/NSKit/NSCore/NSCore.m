//
//  NSCore.m
//  NSKit
//
//  Created by Neil on 2023/3/7.
//

#import "NSCore.h"

@implementation NSCore

+ (NSCore*)sharedInstance {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
@end
