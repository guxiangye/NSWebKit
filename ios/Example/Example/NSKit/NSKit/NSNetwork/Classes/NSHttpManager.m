//
//  NSHttpManager.m
//  NSKit
//
//  Created by Neil on 2023/5/5.
//

#import "NSHttpManager.h"
#import "NSNetworkSessionManager.h"

@interface NSHttpManager ()
@property (nonatomic, strong) NSMutableDictionary<NSString *,NSSingleHttpToolBox*> *mBaseURLAndToolBoxMap;
@end
@implementation NSHttpManager
+ (NSHttpManager *)sharedInstance {
    static NSHttpManager * _instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        _instance.mBaseURLAndToolBoxMap = @{}.mutableCopy;
    });
    return _instance;
}

- (void)registerConfig:(NSNetworkConfig *)config baseURL:(NSString *)baseURL {
    
    NSSingleHttpToolBox *toolBox = [self.mBaseURLAndToolBoxMap objectForKey:baseURL];
    if (toolBox == nil) {
        toolBox = [[NSSingleHttpToolBox alloc]initWithConfig:config baseURL:baseURL];
        self.mBaseURLAndToolBoxMap[baseURL] = toolBox;
    }
    
}
-(nullable NSSingleHttpToolBox *  )getHttpToolBox:(NSString *)baseURL{
    return [self.mBaseURLAndToolBoxMap objectForKey:baseURL];
}

@end
