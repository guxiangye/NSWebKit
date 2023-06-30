//
//  NSPickLocationViewController.h
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPickLocationViewController : UIViewController

/// 查询POI类型 详见:https://lbs.amap.com/api/webservice/guide/api/search
@property(nonatomic,copy)NSString *searchTypes;
@property(nonatomic,copy)void(^completionBlock)(NSDictionary *info);

@end

NS_ASSUME_NONNULL_END
