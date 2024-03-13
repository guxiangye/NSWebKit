//
//  UIGestureRecognizer+NSAutoTrack.h
//  NSAutoTrack
//
//  Created by Neil on 2020/5/19.
//  Copyright © 2020 Neil. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIGestureRecognizer (NSAutoTrack)
- (void)addActionBlock:(void (^)(UIGestureRecognizer *sender))block;
@end

NS_ASSUME_NONNULL_END
