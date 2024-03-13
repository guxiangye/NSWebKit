//
//  SPHttpManager.m
//  SPKit
//
//  Created by 高鹏程 on 2023/5/5.
//

#import "SPHttpManager.h"
#import "SDPNetworkSessionManager.h"

@interface SPHttpManager ()
@property (nonatomic, strong) NSMutableDictionary<NSString *,SPSingleHttpToolBox*> *mBaseURLAndToolBoxMap;
@end
@implementation SPHttpManager
+ (SPHttpManager *)sharedInstance {
    static SPHttpManager * _instance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        _instance.mBaseURLAndToolBoxMap = @{}.mutableCopy;
    });
    return _instance;
}

- (void)registerConfig:(SPNetworkConfig *)config baseURL:(NSString *)baseURL {
    
    SPSingleHttpToolBox *toolBox = [self.mBaseURLAndToolBoxMap objectForKey:baseURL];
    if (toolBox == nil) {
        toolBox = [[SPSingleHttpToolBox alloc]initWithConfig:config baseURL:baseURL];
        self.mBaseURLAndToolBoxMap[baseURL] = toolBox;
    }
    
}
-(nullable SPSingleHttpToolBox *  )getHttpToolBox:(NSString *)baseURL{
    return [self.mBaseURLAndToolBoxMap objectForKey:baseURL];
}

@end
