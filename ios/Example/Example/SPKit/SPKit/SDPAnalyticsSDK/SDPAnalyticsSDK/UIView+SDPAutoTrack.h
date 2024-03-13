//
//  UIView+SDPSDPAutoTrack.h
//  SDPSDPAutoTrack
//
//  Created by 高鹏程 on 2020/5/18.
//  Copyright © 2020 高鹏程. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDPAutoTrackProperty.h"
NS_ASSUME_NONNULL_BEGIN

#pragma mark - UIView

@interface UIView (SDPAutoTrack) <SDPAutoTrackViewProperty>
@end

@interface UILabel (SDPAutoTrack) <SDPAutoTrackViewProperty>
@end

@interface UIImageView (SDPAutoTrack) <SDPAutoTrackViewProperty>
@end

@interface UITextView (SDPAutoTrack) <SDPAutoTrackViewProperty>
@end

#pragma mark - UIControl

@interface UIControl (SDPAutoTrack) <SDPAutoTrackViewProperty>
@end

@interface UIButton (SDPAutoTrack) <SDPAutoTrackViewProperty>
@end

@interface UITextField (SDPAutoTrack) <SDPAutoTrackViewProperty>
@end



#pragma mark - Cell
@interface UITableViewCell (SDPAutoTrack) <SDPAutoTrackViewProperty, SDPAutoTrackCellProperty>
@end

@interface UICollectionViewCell (SDPAutoTrack) <SDPAutoTrackViewProperty, SDPAutoTrackCellProperty>
@end

@interface UITableViewHeaderFooterView (SDPAutoTrack)<SDPAutoTrackViewProperty, SDPAutoTrackCellProperty>
@end

@interface UICollectionReusableView (SDPAutoTrack)<SDPAutoTrackViewProperty, SDPAutoTrackCellProperty>
@end


NS_ASSUME_NONNULL_END
