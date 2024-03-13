//
//  UIGestureRecognizer+SDPAutoTrack.h
//  SDPAutoTrack
//
//  Created by 高鹏程 on 2020/5/19.
//  Copyright © 2020 高鹏程. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIGestureRecognizer (SDPAutoTrack)
- (void)addActionBlock:(void (^)(UIGestureRecognizer *sender))block;
@end

NS_ASSUME_NONNULL_END
