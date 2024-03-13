//
//  SDPAutoTrackProperty.h
//  SDPAutoTrack
//
//  Created by 高鹏程 on 2020/5/18.
//  Copyright © 2020 高鹏程. All rights reserved.
//

#import <Foundation/Foundation.h>
#pragma mark -
@protocol SDPAutoTrackIsIgnoredProtocol <NSObject>
/// 是否忽略打点
@property (nonatomic, assign) BOOL sdp_autotrack_isIgnored;
@end


@protocol SDPAutoTrackElementIdProtocol <NSObject>
/// 确定元素唯一性的id
@property (nonatomic, copy) NSString *sdp_autotrack_elementId;
@end
