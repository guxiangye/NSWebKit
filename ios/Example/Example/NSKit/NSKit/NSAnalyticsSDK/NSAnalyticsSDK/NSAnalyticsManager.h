//
//  NSAnalyticsSingleton.h
//  NSAutoTrack
//
//  Created by Neil on 2020/5/25.
//  Copyright © 2020 Neil. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAnalyticsManager : NSObject
+ (NSAnalyticsManager *)sharedInstance;

/// appid
@property (nonatomic, copy) NSString *appid;
/// 仅仅只追踪 这个类的子类的控制器
@property (nonatomic, copy) Class trackViewControlerClass;

@property (nonatomic, copy) NSDictionary * (^ fetchCommonInfoBlock)(void);

/// 指每次进入时分配的一次全局会话id，退出时本次会话结束
@property (nonatomic, copy) NSString *sessionId;



/// 生成 全局 sessionid
+(void)generateSessionId;
@end

NS_ASSUME_NONNULL_END
