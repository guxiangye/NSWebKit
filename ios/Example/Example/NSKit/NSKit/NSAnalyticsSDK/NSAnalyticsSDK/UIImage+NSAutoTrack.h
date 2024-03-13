//
//  UIImage+NSAutoTrack.h
//  NSAutoTrack
//
//  Created by Neil on 2020/5/18.
//  Copyright © 2020 Neil. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (NSGetImageFileName)
@property (nonatomic,copy)NSString *sdp_autotrack_filename;
@end
@interface UIImageView (NSGetImageFileName)
@property (nonatomic,copy)NSString *sdp_autotrack_filename;
@end
@interface UIButton (NSGetImageFileName)
@property (nonatomic,copy)NSString *sdp_autotrack_filename;
@end

NS_ASSUME_NONNULL_END
