//
//  UIImage+SDPAutoTrack.h
//  SDPAutoTrack
//
//  Created by 高鹏程 on 2020/5/18.
//  Copyright © 2020 高鹏程. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (SDPGetImageFileName)
@property (nonatomic,copy)NSString *sdp_autotrack_filename;
@end
@interface UIImageView (SDPGetImageFileName)
@property (nonatomic,copy)NSString *sdp_autotrack_filename;
@end
@interface UIButton (SDPGetImageFileName)
@property (nonatomic,copy)NSString *sdp_autotrack_filename;
@end

NS_ASSUME_NONNULL_END
