//
//  SDPAutoTrack.h
//  SDPAutoTrack
//
//  Created by 高鹏程 on 2020/5/19.
//  Copyright © 2020 高鹏程. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SDPAutoTrack : NSObject
/// 开启自动打点
+ (void)enableAutoTrack;

/// 禁用自动打点
+ (void)disableAutoTrack;

@end

NS_ASSUME_NONNULL_END
