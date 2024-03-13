//
//  UIView+NSAutoTrack.m
//  NSAutoTrack
//
//  Created by Neil on 2020/5/18.
//  Copyright © 2020 Neil. All rights reserved.
//

#import "UIView+NSAutoTrack.h"
#import "UIImage+NSAutoTrack.h"
#import "NSAutoTrackUtils.h"
#import "UIView+NSAutoTrackTableHeaderFooterView.h"
#import <objc/runtime.h>
static const int sdp_autotrack_view_elementid_key;
@implementation UIView (NSAutoTrack)
- (BOOL)sdp_autotrack_isIgnored {
    if (self.isHidden) {
        return YES;
    }
    if (self.sdp_autotrack_viewController.sdp_autotrack_isIgnored) {
        return YES;
    }
    /*
    根据配置 看看是否忽略打点
    */
    return NO;
}

- (NSString *)sdp_autotrack_elementType {
    return NSStringFromClass(self.class);
}

- (void)setSdp_autotrack_elementId:(NSString *)sdp_autotrack_elementId {
    objc_setAssociatedObject(self, &sdp_autotrack_view_elementid_key, sdp_autotrack_elementId, OBJC_ASSOCIATION_COPY);
}

- (NSString *)sdp_autotrack_elementId {
    NSString *elementId = objc_getAssociatedObject(self, &sdp_autotrack_view_elementid_key);

    if ([self isKindOfClass: NSClassFromString(@"_UIButtonBarButton")]) {
        UIViewController *currentVC = [NSAutoTrackUtils currentViewController];
        UIView *superView = self.superview;
        return [NSString stringWithFormat:@"%@/%@",NSStringFromClass(currentVC.class),superView.sdp_autotrack_element_itemPath];
    }
    if (elementId == nil) {
        NSString *viewPath = [UIView viewPathForView:self];
        elementId = viewPath;
    }
    return elementId;
}
+ (NSString *)viewPathForView:(UIView<NSAutoTrackViewProperty> *)view {
    NSMutableArray *viewPaths = [[NSMutableArray alloc]init];
    do {
        if (view.sdp_autotrack_element_itemPath) {
            [viewPaths addObject:view.sdp_autotrack_element_itemPath];
        }
    } while ((view = (id)view.nextResponder) && [view isKindOfClass:[UIView class]] && ![view isKindOfClass:[UIWindow class]]);

    viewPaths = [[viewPaths reverseObjectEnumerator]allObjects].copy;
    NSString *viewPath = [viewPaths componentsJoinedByString:@"/"];
    return viewPath;
}

- (NSString *)sdp_autotrack_elementContent {
    NSMutableString *elementContent = [NSMutableString string];
    NSMutableArray<NSString *> *elementContentArray = [NSMutableArray array];
    for (UIView *subview in self.subviews) {
        // 忽略隐藏控件
        if (subview.isHidden || subview.sdp_autotrack_isIgnored) {
            continue;
        }
        NSString *temp = subview.sdp_autotrack_elementContent;
        if (temp.length > 0) {
            [elementContentArray addObject:temp];
        }
    }
    if (elementContentArray.count > 0) {
        [elementContent appendString:[elementContentArray componentsJoinedByString:@"-"]];
    }
    return elementContent.length == 0 ? nil : [elementContent copy];
}

- (NSString *)sdp_autotrack_element_itemPath {
    NSString *className = NSStringFromClass(self.class);
    if ([className isEqualToString:@"UITableViewWrapperView"] || [className isEqualToString:@"UITableViewCellContentView"]) {
        return nil;
    }
    UIView *superView = self.superview;
    if ([superView isKindOfClass:[UITableView class]] || [superView isKindOfClass:[UICollectionView class]]) {
        return className;
    }
    NSInteger index = [NSAutoTrackUtils itemIndexForResponder:self];
    return index < 0 ? className : [NSString stringWithFormat:@"%@[%ld]", className, (long)index];
}

- (NSString *)sdp_autotrack_element_position {
    //找出 UITableView 或者 UICollectionView 的headerView 或者 footerView 上元素的位置
    if (self.sdp_autotrack_header_footer_view_position) {
        return self.sdp_autotrack_header_footer_view_position;
    }
    //判断当前元素 是否在UITableVIew 或者 UICollectionView 上
    UIView<NSAutoTrackCellProperty> *cell = (id)self;
    do {
        if ([cell conformsToProtocol:@protocol(NSAutoTrackCellProperty)]) {
            break;
        }
        cell = (id)cell.superview;
    } while (cell);

    if ([cell conformsToProtocol:@protocol(NSAutoTrackCellProperty)]) {
        return [cell sdp_autotrack_elementPositionWithIndexPath:cell.sdp_autotrack_IndexPath];
    }

    return nil;
}

- (UIViewController<NSAutoTrackViewControllerProperty> *)sdp_autotrack_viewController {
//    for (UIView *view = self; view; view = view.superview) {
//        UIResponder *nextResponder = [view nextResponder];
//        if ([nextResponder isKindOfClass:[UIViewController class]]) {
//            return (UIViewController <NSAutoTrackViewControllerProperty> *)nextResponder;
//        }
//    }
    return [NSAutoTrackUtils currentViewController];
}

@end

@implementation UILabel (NSAutoTrack)
- (NSString *)sdp_autotrack_elementContent {
    NSString *content =  self.text ? : @"empty";
    return [NSString stringWithFormat:@"[%@<%@>]", NSStringFromClass([self class]), content];
}

@end

@implementation UIImageView (NSAutoTrack)
- (NSString *)sdp_autotrack_elementContent {
    NSString *filename = self.sdp_autotrack_filename;
    return [NSString stringWithFormat:@"[%@<%@>]", NSStringFromClass([self class]), filename];
}

- (NSString *)sdp_autotrack_element_itemPath {
    NSString *className = NSStringFromClass(self.class);
    NSString *filename = self.image.sdp_autotrack_filename;
    if (filename) {
        return [NSString stringWithFormat:@"%@(%@)", className, filename];
    }
    NSInteger index = [NSAutoTrackUtils itemIndexForResponder:self];
    return index < 0 ? className : [NSString stringWithFormat:@"%@[%ld]", className, (long)index];
}

@end

@implementation UITextView (NSAutoTrack)
- (NSString *)sdp_autotrack_elementContent {
    NSString *content =  self.text ? : @"empty";
    return [NSString stringWithFormat:@"[%@<%@>]", NSStringFromClass([self class]), content];
}

@end

#pragma mark - UIControl

@implementation UIControl (NSAutoTrack)
@end

@implementation UIButton (NSAutoTrack)
- (NSString *)sdp_autotrack_element_itemPath {
    NSString *className = NSStringFromClass(self.class);
    NSString *filename = self.sdp_autotrack_filename;
    if (filename) {
        return [NSString stringWithFormat:@"%@(%@)", className, filename];
    }
    NSString *title = [self titleForState:UIControlStateNormal];
    if (title) {
        return [NSString stringWithFormat:@"%@(%@)", className, title];
    }
    NSInteger index = [NSAutoTrackUtils itemIndexForResponder:self];
    return index < 0 ? className : [NSString stringWithFormat:@"%@[%ld]", className, (long)index];
}

@end

@implementation UITextField (NSAutoTrack)
- (NSString *)sdp_autotrack_element_itemPath {
    NSString *className = NSStringFromClass(self.class);
    NSString *placeholder = self.placeholder;
    if (placeholder) {
        return [NSString stringWithFormat:@"%@(%@)", className, placeholder];
    }
    NSInteger index = [NSAutoTrackUtils itemIndexForResponder:self];
    return index < 0 ? className : [NSString stringWithFormat:@"%@[%ld]", className, (long)index];
}

- (NSString *)sdp_autotrack_elementContent {
    NSString *content =  self.text ? : @"empty";
    return [NSString stringWithFormat:@"[%@<%@>]", NSStringFromClass([self class]), content];
}

@end

#pragma mark - Cell
@implementation UITableViewCell (NSAutoTrack)
- (NSString *)sdp_autotrack_element_itemPath {
    NSString *className = NSStringFromClass(self.class);
    return className;
}

- (NSString *)sdp_autotrack_elementPositionWithIndexPath:(NSIndexPath *)indexPath {
    return [NSString stringWithFormat:@"[%ld][%ld]", (long)indexPath.section, (long)indexPath.item];
}

- (NSIndexPath *)sdp_autotrack_IndexPath {
    UITableView *tableView = (UITableView *)[self superview];
    do {
        if ([tableView isKindOfClass:UITableView.class]) {
            NSIndexPath *indexPath = [tableView indexPathForCell:self];
            return indexPath;
        }
    } while ((tableView = (UITableView *)[tableView superview]));
    return nil;
}

@end

@implementation UICollectionViewCell (NSAutoTrack)
- (NSString *)sdp_autotrack_element_itemPath {
    NSString *className = NSStringFromClass(self.class);
    return className;
}

- (NSIndexPath *)sdp_autotrack_IndexPath {
    UICollectionView *collectionView = (UICollectionView *)[self superview];
    if ([collectionView isKindOfClass:UICollectionView.class]) {
        NSIndexPath *indexPath = [collectionView indexPathForCell:self];
        return indexPath;
    }
    return nil;
}

- (NSString *)sdp_autotrack_elementPositionWithIndexPath:(NSIndexPath *)indexPath {
    return [NSString stringWithFormat:@"[%ld][%ld]", (long)indexPath.section, (long)indexPath.item];
}

@end

@implementation UITableViewHeaderFooterView (NSAutoTrack)
- (NSString *)sdp_autotrack_element_itemPath {
    NSString *className = NSStringFromClass(self.class);
    return className;
}

- (NSIndexPath *)sdp_autotrack_IndexPath {
    UITableView *tableView = (UITableView *)self.superview;

    while (![tableView isKindOfClass:UITableView.class]) {
        tableView = (UITableView *)tableView.superview;
        if (!tableView) {
            return nil;
        }
    }
    for (NSInteger i = 0; i < tableView.numberOfSections; i++) {
        if (self == [tableView headerViewForSection:i]) {
            return [NSIndexPath indexPathForRow:0 inSection:i];
        }
        if (self == [tableView footerViewForSection:i]) {
            return [NSIndexPath indexPathForRow:1 inSection:i];
        }
    }
    return nil;
}

- (NSString *)sdp_autotrack_elementPositionWithIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row == 0) {
        return [NSString stringWithFormat:@"[SectionHeader][%ld]", (long)indexPath.section];
    }
    return [NSString stringWithFormat:@"[SectionFooter][%ld]", (long)indexPath.section];
}

@end

@implementation UICollectionReusableView (NSAutoTrack)

- (NSString *)sdp_autotrack_element_itemPath {
    NSString *className = NSStringFromClass(self.class);
    return className;
}

- (NSIndexPath *)sdp_autotrack_IndexPath {
    UICollectionView *collectionView = (UICollectionView *)self.superview;

    while (![collectionView isKindOfClass:UICollectionView.class]) {
        collectionView = (UICollectionView *)collectionView.superview;
        if (!collectionView) {
            return nil;
        }
    }
    for (NSInteger i = 0; i < collectionView.numberOfSections; i++) {
        if (self == [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:self.reuseIdentifier forIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]]) {
            return [NSIndexPath indexPathForRow:0 inSection:i];
        }
        if (self == [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:self.reuseIdentifier forIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]]) {
            return [NSIndexPath indexPathForRow:1 inSection:i];
        }
    }
    return nil;
}

- (NSString *)sdp_autotrack_elementPositionWithIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row == 0) {
        return [NSString stringWithFormat:@"[SectionHeader][%ld]", (long)indexPath.section];
    }
    return [NSString stringWithFormat:@"[SectionFooter][%ld]", (long)indexPath.section];
}

//-(void)k{
//    UICollectionView *collectionView = nil;
//
//    for (NSInteger i = 0; i < collectionView.numberOfSections; i++) {
//
//        NSPortalCollectionFooterView *cell = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kNSPortalFooterCellIdentifier forIndexPath:indexPath];
//
//        if (self == [tableView headerViewForSection:i]) {
//            return [NSIndexPath indexPathForRow:0 inSection:i];
//        }
//        if (self == [tableView footerViewForSection:i]) {
//            return [NSIndexPath indexPathForRow:1 inSection:i];
//        }
//    }
//}

@end
