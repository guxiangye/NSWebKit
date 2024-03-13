//
//  UIView+SDPNSAutoTrack.h
//  SDPNSAutoTrack
//
//  Created by Neil on 2020/5/18.
//  Copyright © 2020 Neil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSAutoTrackProperty.h"
NS_ASSUME_NONNULL_BEGIN

#pragma mark - UIView

@interface UIView (NSAutoTrack) <NSAutoTrackViewProperty>
@end

@interface UILabel (NSAutoTrack) <NSAutoTrackViewProperty>
@end

@interface UIImageView (NSAutoTrack) <NSAutoTrackViewProperty>
@end

@interface UITextView (NSAutoTrack) <NSAutoTrackViewProperty>
@end

#pragma mark - UIControl

@interface UIControl (NSAutoTrack) <NSAutoTrackViewProperty>
@end

@interface UIButton (NSAutoTrack) <NSAutoTrackViewProperty>
@end

@interface UITextField (NSAutoTrack) <NSAutoTrackViewProperty>
@end



#pragma mark - Cell
@interface UITableViewCell (NSAutoTrack) <NSAutoTrackViewProperty, NSAutoTrackCellProperty>
@end

@interface UICollectionViewCell (NSAutoTrack) <NSAutoTrackViewProperty, NSAutoTrackCellProperty>
@end

@interface UITableViewHeaderFooterView (NSAutoTrack)<NSAutoTrackViewProperty, NSAutoTrackCellProperty>
@end

@interface UICollectionReusableView (NSAutoTrack)<NSAutoTrackViewProperty, NSAutoTrackCellProperty>
@end


NS_ASSUME_NONNULL_END
