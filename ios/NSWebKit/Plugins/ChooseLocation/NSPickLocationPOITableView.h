//
//  NSPickLocationPOITableView.h
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NSPickLocationPOITableViewGestureRecognizerDelegate <NSObject>

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
@end


@interface NSPickLocationPOITableView : UITableView
@property(nonatomic,assign)id<NSPickLocationPOITableViewGestureRecognizerDelegate>gestureRecoginzerDelegate;
@end

NS_ASSUME_NONNULL_END
