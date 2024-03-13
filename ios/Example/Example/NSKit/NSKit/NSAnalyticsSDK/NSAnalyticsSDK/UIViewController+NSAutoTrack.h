//
//  UIViewController+NSAutoTrack.h
//  NSAutoTrack
//
//  Created by Neil on 2020/5/25.
//  Copyright © 2020 Neil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSAutoTrackProperty.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - UIViewController
@interface UIViewController (NSAutoTrack) <NSAutoTrackViewControllerProperty>

@end

@interface UIAlertController (NSAutoTrack) <NSAutoTrackUIAlertControllerProperty>

@end

@interface UIAlertAction (NSAutoTrack) <NSAutoTrackUIAlertActionProperty>

@end

NS_ASSUME_NONNULL_END
