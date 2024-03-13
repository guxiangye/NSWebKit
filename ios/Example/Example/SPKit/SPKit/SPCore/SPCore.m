//
//  SPCore.m
//  SPKit
//
//  Created by 高鹏程 on 2023/3/7.
//

#import "SPCore.h"

@implementation SPCore

+ (SPCore*)sharedInstance {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
@end
