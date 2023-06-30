//
//  NSPickLocationSearchView.h
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//

#import <AMapSearchKit/AMapSearchKit.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    NSPickLocationSearchViewUnExpand = 0,//未展开
    NSPickLocationSearchViewExpand = 1 //展开
} NSPickLocationSearchViewExpandState;


typedef enum : NSUInteger {
    NSPickLocationSearchViewResultNormalType = 0,//经纬度poi搜索结果
    NSPickLocationSearchViewResultKeywordType = 1 //关键字poi搜索结果
} NSPickLocationSearchViewResultDataType;

#define NSSCREEN_HEIGHT                           ([UIScreen mainScreen].bounds.size.height)

#define NSPickLocationSearchViewUnExpandTopOffset NSSCREEN_HEIGHT * 0.65
#define NSPickLocationSearchViewExpandTopOffset   NSSCREEN_HEIGHT * 0.25

@protocol NSPickLocationSearchViewDelegate <NSObject>

- (void)searchBarSearchButtonClicked;

- (void)searchViewTopOffsetChanged:(CGFloat)topOffset;
- (void)searchViewSelectedPOIChanged:(AMapPOI *)selectedPoi isFirstPOI:(BOOL)isFirstPOI;
- (void)searchViewResultDataTypeChanged:(NSPickLocationSearchViewResultDataType)resutlDataType;

-(void)searchViewCurrentSelectedPOIChanged:(AMapPOI * )selectdPoi;

@end


@interface NSPlaceAroundTableView : UIView

@end

@interface NSPickLocationSearchView : UIView<AMapSearchDelegate>

/// 搜索周边POI 需要的types
@property (nonatomic, copy) NSString *mapSearchTypes;
@property (nonatomic, assign) id <NSPickLocationSearchViewDelegate>delegate;


@property (nonatomic, assign) NSPickLocationSearchViewExpandState expandState;
@property (nonatomic, assign) NSPickLocationSearchViewResultDataType resultDataType;

@property (nonatomic, assign) CLLocationCoordinate2D currentGPSCoordinate;//当前GPS定位经纬度
@property (nonatomic, assign) CLLocationCoordinate2D currentPOISearchCoordinate;//当前POI搜索经纬度

- (void)changeExpandState:(NSPickLocationSearchViewExpandState)state;
- (void)searchPoiWithCenterCoordinate:(CLLocationCoordinate2D)coordinate;
/// 获取当前选中的POI
- (AMapPOI *)getCurrentSelectedPOI;

@end

NS_ASSUME_NONNULL_END
