//
//  UIViewController+SDPAutoTrack.h
//  SDPAutoTrack
//
//  Created by 高鹏程 on 2020/5/25.
//  Copyright © 2020 高鹏程. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDPAutoTrackProperty.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - UIViewController
@interface UIViewController (SDPAutoTrack) <SDPAutoTrackViewControllerProperty>

@end

@interface UIAlertController (SDPAutoTrack) <SDPAutoTrackUIAlertControllerProperty>

@end

@interface UIAlertAction (SDPAutoTrack) <SDPAutoTrackUIAlertActionProperty>

@end

NS_ASSUME_NONNULL_END
