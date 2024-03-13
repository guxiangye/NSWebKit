//
//  UIImage+SDPAutoTrack.m
//  SDPAutoTrack
//
//  Created by 高鹏程 on 2020/5/18.
//  Copyright © 2020 高鹏程. All rights reserved.
//

#import "SDPAspects.h"
#import "UIImage+SDPAutoTrack.h"
#import <objc/runtime.h>

static const int sdp_autotrack_image_filename_key;
@implementation UIImage (SDPGetImageFileName)

- (NSString *)sdp_autotrack_filename {
    return objc_getAssociatedObject(self, &sdp_autotrack_image_filename_key);
}

- (void)setSdp_autotrack_filename:(NSString *_Nonnull)sdp_autotrack_filename {
    objc_setAssociatedObject(self, &sdp_autotrack_image_filename_key, sdp_autotrack_filename, OBJC_ASSOCIATION_COPY);
}

@end
@implementation UIImageView (SDPGetImageFileName)

- (NSString *)sdp_autotrack_filename {
    return self.image.sdp_autotrack_filename ? : objc_getAssociatedObject(self, &sdp_autotrack_image_filename_key);
}

- (void)setSdp_autotrack_filename:(NSString *_Nonnull)sdp_autotrack_filename {
    objc_setAssociatedObject(self, &sdp_autotrack_image_filename_key, sdp_autotrack_filename, OBJC_ASSOCIATION_COPY);
}

@end
@implementation UIButton (SDPGetImageFileName)

- (NSString *)sdp_autotrack_filename {
    UIImage *image = [self imageForState:UIControlStateNormal];
    return image.sdp_autotrack_filename ? : objc_getAssociatedObject(self, &sdp_autotrack_image_filename_key);
}

- (void)setSdp_autotrack_filename:(NSString *_Nonnull)sdp_autotrack_filename {
    objc_setAssociatedObject(self, &sdp_autotrack_image_filename_key, sdp_autotrack_filename, OBJC_ASSOCIATION_COPY);
}

@end
