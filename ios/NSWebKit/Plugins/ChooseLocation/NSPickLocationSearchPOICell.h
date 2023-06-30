//
//  NSPickLocationSearchPOICell.h
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPickLocationSearchPOICell : UITableViewCell
@property (nonatomic,copy)NSString *keywords;
@property (nonatomic, assign) CLLocationCoordinate2D currentPOISearchCoordinate;
@property (nonatomic,strong)AMapPOI *poi;
@end

NS_ASSUME_NONNULL_END
