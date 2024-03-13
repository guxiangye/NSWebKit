//
//  UIView+SDPAutoTrackTableHeaderFooterView.m
//  SDPAutoTrack
//
//  Created by 高鹏程 on 2020/5/29.
//  Copyright © 2020 高鹏程. All rights reserved.
//

#import "UIView+SDPAutoTrackTableHeaderFooterView.h"
#import <objc/runtime.h>
static const int sdp_table_header_footer_view_type_key;
static const int sdp_table_header_footer_view_section_key;

@implementation UIView (SDPAutoTrackTableHeaderFooterView)
- (SDPAutoTrackHeaderFooterViewType)sdp_autotrack_header_footer_view_type {
    SDPAutoTrackHeaderFooterViewType viewType = [objc_getAssociatedObject(self, &sdp_table_header_footer_view_type_key)integerValue];

    UIView *view = self;
    while (viewType == SDPAutoTrackViewNormal && view) {
        view = view.superview;
        viewType = [objc_getAssociatedObject(view, &sdp_table_header_footer_view_type_key)integerValue];
        self.sdp_autotrack_header_footer_section = [objc_getAssociatedObject(view, &sdp_table_header_footer_view_section_key)integerValue];
    }

    return viewType;
}

- (void)setSdp_autotrack_header_footer_view_type:(SDPAutoTrackHeaderFooterViewType)sdp_autotrack_header_footer_view_type {
    objc_setAssociatedObject(self, &sdp_table_header_footer_view_type_key, [NSNumber numberWithInteger:sdp_autotrack_header_footer_view_type], OBJC_ASSOCIATION_ASSIGN);
}

- (NSUInteger)sdp_autotrack_header_footer_section {
    NSUInteger section =  [objc_getAssociatedObject(self, &sdp_table_header_footer_view_section_key)integerValue];

    return section;
}

- (void)setSdp_autotrack_header_footer_section:(NSUInteger)sdp_autotrack_header_footer_section {
    objc_setAssociatedObject(self, &sdp_table_header_footer_view_section_key, [NSNumber numberWithInteger:sdp_autotrack_header_footer_section], OBJC_ASSOCIATION_ASSIGN);
}

- (NSString *)sdp_autotrack_header_footer_view_position {
    switch (self.sdp_autotrack_header_footer_view_type) {
        case SDPAutoTrackViewNormal:
            return nil;
            break;
        case SDPAutoTrackViewInHeaderView:
            return [NSString stringWithFormat:@"[SectionHeader][%ld]", (long)self.sdp_autotrack_header_footer_section];
        case SDPAutoTrackViewInFooterView:
            return [NSString stringWithFormat:@"[SectionFooter][%ld]", (long)self.sdp_autotrack_header_footer_section];
        default:
            break;
    }
}

@end
