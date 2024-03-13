//
//  SDPAutoTrackProperty.h
//  SDPAutoTrack
//
//  Created by 高鹏程 on 2020/5/18.
//  Copyright © 2020 高鹏程. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDPAutoTrackElementIsIgnoredProtocol.h"
#pragma mark -
@protocol SDPAutoTrackViewControllerProperty <SDPAutoTrackElementIsIgnoredProtocol>

/// 类名
@property (nonatomic, copy, readonly) NSString *sdp_autotrack_page_id;

/// 标题
@property (nonatomic, copy, readonly) NSString *sdp_autotrack_page_title;

/// sessionid
@property (nonatomic, copy, readonly) NSString *sdp_autotrack_page_sessionId;

@end

#pragma mark -
@protocol SDPAutoTrackViewProperty <SDPAutoTrackElementIsIgnoredProtocol, SDPAutoTrackElementIdProtocol>

/// 元素类型 UIVIiew UIButton ..
@property (nonatomic, copy, readonly) NSString *sdp_autotrack_elementType;

/// 元素内容
@property (nonatomic, copy, readonly) NSString *sdp_autotrack_elementContent;

///// 元素在父级的相对路径
@property (nonatomic, copy, readonly) NSString *sdp_autotrack_element_itemPath;

/// 获取元素在 UITableVIew 或者 UICollectionView 上的 IndexPath 信息
@property (nonatomic, copy, readonly) NSString *sdp_autotrack_element_position;

//获取view 当前所在的 控制器
@property (nonatomic, readonly) UIViewController<SDPAutoTrackViewControllerProperty> *sdp_autotrack_viewController;

@end

#pragma mark -
@protocol SDPAutoTrackUIAlertControllerProperty <SDPAutoTrackIsIgnoredProtocol, SDPAutoTrackElementIsIgnoredProtocol, SDPAutoTrackElementIdProtocol>
/// 元素类型 UIVIiew UIButton ..
@property (nonatomic, copy, readonly) NSString *sdp_autotrack_elementType;
/// 元素内容
@property (nonatomic, copy, readonly) NSString *sdp_autotrack_elementContent;
//获取view 当前所在的 控制器
@property (nonatomic, readonly) UIViewController<SDPAutoTrackViewControllerProperty> *sdp_autotrack_viewController;

@end

#pragma mark -
@protocol SDPAutoTrackUIAlertActionProperty <NSObject>

/// 元素类型 UIVIiew UIButton ..
@property (nonatomic, copy, readonly) NSString *sdp_autotrack_elementType;

/// 元素内容
@property (nonatomic, copy, readonly) NSString *sdp_autotrack_elementContent;

@end

#pragma mark -
@protocol SDPAutoTrackCellProperty <NSObject>

/// 根据IndexPath 获取 cell的位置信息
/// @param indexPath indexPath
- (NSString *)sdp_autotrack_elementPositionWithIndexPath:(NSIndexPath *)indexPath;

/// 遍历查找 cell 所在的 indexPath
@property (nonatomic, strong, readonly) NSIndexPath *sdp_autotrack_IndexPath;
@end

typedef enum : NSUInteger {
    SDPAutoTrackViewNormal = 0,//视图不在 tabliew 或者 collection 的 headerview 或 footerview 里
    SDPAutoTrackViewInHeaderView = 1,//视图 在 tabliew 或者 collection 的 headerview 里
    SDPAutoTrackViewInFooterView = 2,//视图 在 tabliew 或者 collection 的 footerview 里
} SDPAutoTrackHeaderFooterViewType;
/// 为了找出 UITableView 或者 UICollectionView 的headerView 或者 footerView 上元素的位置
@protocol SDPAutoTrackHeaderFooterViewProperty <NSObject>

@property (nonatomic, assign) SDPAutoTrackHeaderFooterViewType sdp_autotrack_header_footer_view_type;

@property (nonatomic, assign) NSUInteger sdp_autotrack_header_footer_section;

/// UITableView 或者 UICollectionView 的headerView 或者 footerView 上元素的位置
@property (nonatomic, readonly) NSString *sdp_autotrack_header_footer_view_position;

@end
