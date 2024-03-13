//
//  NSAutoTrackProperty.h
//  NSAutoTrack
//
//  Created by Neil on 2020/5/18.
//  Copyright © 2020 Neil. All rights reserved.
//

#import <Foundation/Foundation.h>
#pragma mark -
@protocol NSAutoTrackIsIgnoredProtocol <NSObject>
/// 是否忽略打点
@property (nonatomic, assign) BOOL sdp_autotrack_isIgnored;
@end


@protocol NSAutoTrackElementIdProtocol <NSObject>
/// 确定元素唯一性的id
@property (nonatomic, copy) NSString *sdp_autotrack_elementId;
@end
