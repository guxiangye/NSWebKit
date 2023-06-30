//
//  NSPickLocationViewController.m
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//

#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <MAMapKit/MAMapKit.h>
#import <MAMapKit/MAMapView.h>
#import "Masonry.h"
#import "NSPickLocationSearchView.h"
#import "NSPickLocationViewController.h"
#import "UIColor+YYAdd.h"
#import "UIImage+YYAdd.h"

@interface NSPickLocationViewController ()< MAMapViewDelegate, NSPickLocationSearchViewDelegate, UIGestureRecognizerDelegate> {
    UIButton *gps_lcoation_btn;
    UIButton *sendBtn;
}

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) NSPickLocationSearchView *searchView;
@property (nonatomic, assign) BOOL isLocated;
@property (nonatomic, strong) UIImageView *centerAnnotationView;
@property (nonatomic, assign) BOOL isMapViewRegionChangedFromTableView;
@property (nonatomic, assign) BOOL handlePOIWhenTouchMap;
@property (nonatomic, strong) MAPointAnnotation *keywordResultTypeAnnotation;

@end

@implementation NSPickLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), self.view.bounds.size.height / 2)];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.showsCompass = NO;
    self.mapView.zoomLevel = 17;
    self.mapView.scrollEnabled = NO;
    [self.view addSubview:self.mapView];

    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(NSPickLocationSearchViewUnExpandTopOffset));
        make.centerY.equalTo(self.view.mas_top).offset(NSPickLocationSearchViewUnExpandTopOffset / 2);
    }];

    self.searchView = [NSPickLocationSearchView new];
    self.searchView.mapSearchTypes = self.searchTypes;
    self.searchView.delegate = self;
    [self.view addSubview:self.searchView];

    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(NSPickLocationSearchViewUnExpandTopOffset);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self searchViewTopOffsetChanged:NSPickLocationSearchViewUnExpandTopOffset animation:NO];
    });



    gps_lcoation_btn = [UIButton new];
    gps_lcoation_btn.backgroundColor = [UIColor whiteColor];
    [gps_lcoation_btn setImage:[UIImage imageNamed:@"btn_gps_normal"] forState:UIControlStateNormal];
    [gps_lcoation_btn setImage:[UIImage imageNamed:@"btn_gps_highlight"] forState:UIControlStateSelected];
    gps_lcoation_btn.layer.masksToBounds = YES;
    [gps_lcoation_btn addTarget:self action:@selector(clickGPSLocationBtn) forControlEvents:UIControlEventTouchUpInside];
    gps_lcoation_btn.layer.cornerRadius = 5;
    [self.view addSubview:gps_lcoation_btn];
    [gps_lcoation_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@40);
        make.centerX.equalTo(self.view.mas_left).offset(40);
        make.bottom.equalTo(self.searchView.mas_top).offset(-40);
    }];

    UIView *topShadowBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)];

    [self.view addSubview:topShadowBg];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = topShadowBg.bounds;
    gradient.colors = @[(id)[[UIColor blackColor]colorWithAlphaComponent:0.7].CGColor, (id)[UIColor clearColor].CGColor];
    gradient.startPoint = CGPointMake(0.5, 0);
    gradient.endPoint = CGPointMake(0.5, 1);
    //    gradient.locations = @[@(0.5f), @(1.0f)];
    [topShadowBg.layer addSublayer:gradient];

    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn addTarget:self action:@selector(clickCancleBtn) forControlEvents:UIControlEventTouchUpInside];
    [cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:cancleBtn];
    [cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@40);
        make.left.equalTo(@20);

        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(0);
        } else {
            make.top.equalTo(@0);
        }
    }];

    sendBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    
    [sendBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#57bf6a"] size:CGSizeMake(50, 50)] forState:UIControlStateNormal];

    [sendBtn setBackgroundImage:[UIImage imageWithColor:[[UIColor colorWithHexString:@"000000"]colorWithAlphaComponent:0.2] size:CGSizeMake(50, 50)] forState:UIControlStateDisabled];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendBtn setTitleColor:[[UIColor colorWithHexString:@"ffffff"]colorWithAlphaComponent:0.53] forState:UIControlStateDisabled];
    sendBtn.enabled = NO;

    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];

    sendBtn.layer.masksToBounds = YES;
    sendBtn.layer.cornerRadius = 5;
    [sendBtn addTarget:self action:@selector(clickSendBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendBtn];
    [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@60);
        make.height.equalTo(@30);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.centerY.equalTo(cancleBtn);
    }];

    self.centerAnnotationView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_map_center_wateRedBlank"]];
    self.centerAnnotationView.center = CGPointMake(self.mapView.center.x, self.mapView.center.y - CGRectGetHeight(self.centerAnnotationView.bounds) / 2);

    [self.mapView addSubview:self.centerAnnotationView];
    [self.centerAnnotationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mapView);
        make.centerY.equalTo(self.mapView).offset(-CGRectGetHeight(self.centerAnnotationView.bounds) / 2);
    }];

    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
    self.keywordResultTypeAnnotation = annotation;
}

/* 移动窗口弹一下的动画 */
- (void)centerAnnotationAnimimate
{
    [self.centerAnnotationView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mapView);
        make.centerY.equalTo(self.mapView).offset(-CGRectGetHeight(self.centerAnnotationView.bounds) / 2 - 20);
    }];

    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        [self.mapView layoutSubviews];
    }
                     completion:^(BOOL finished) {
        if (finished) {
            [self.centerAnnotationView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.mapView);
                make.centerY.equalTo(self.mapView).offset(-CGRectGetHeight(self.centerAnnotationView.bounds) / 2);
            }];
            [UIView animateWithDuration:0.45
                                  delay:0.
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                [self.mapView layoutSubviews];
            }
                             completion:nil];
        }
    }];
}

- (void)clickCancleBtn {
    [self dismissViewControllerAnimated:YES completion:nil];

    if (self.completionBlock) {
        self.completionBlock(@{ @"errCode": @(-3), @"errorMsg": @"用户取消了" });
    }
}

- (void)clickSendBtn {
    [self dismissViewControllerAnimated:YES completion:nil];

    if (self.completionBlock) {
        AMapPOI *currentPOI = [self.searchView getCurrentSelectedPOI];

        if (currentPOI) {
            NSMutableDictionary *result = @{
                    @"errCode": @(0),
                    @"address": currentPOI.address ? : @"",
                    @"name": currentPOI.name ? : @"",
                    @"province": currentPOI.province ? : @"",
                    @"city": currentPOI.city ? : @"",
                    @"district": currentPOI.district ? : @"",
                    @"businessArea": currentPOI.businessArea ? : @"",
                    @"latitude": @(currentPOI.location.latitude),
                    @"longitude": @(currentPOI.location.longitude)
                }.copy;
            self.completionBlock(result);
        }
    }
}

- (void)clickGPSLocationBtn {
    if (self.mapView.userTrackingMode == MAUserTrackingModeFollow) {
        [self.mapView setUserTrackingMode:MAUserTrackingModeNone animated:YES];
    } else {
        [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            // 因为下面这句的动画有bug，所以要延迟0.5s执行，动画由上一句产生
            [self.mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
        });
    }
}

#pragma mark - MapViewDelegate

- (void)mapViewRequireLocationAuth:(CLLocationManager *)locationManager {
    [locationManager requestAlwaysAuthorization];
}

/// 地图区域改变完成后会调用此接口
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self centerAnnotationAnimimate];

    if (!self.isMapViewRegionChangedFromTableView && self.mapView.userTrackingMode == MAUserTrackingModeNone && self.searchView.resultDataType == NSPickLocationSearchViewResultNormalType && self.mapView.scrollEnabled == YES) {
        [self.searchView searchPoiWithCenterCoordinate:self.mapView.centerCoordinate];
    }

    self.isMapViewRegionChangedFromTableView = NO;
    
    MAMapPoint point1 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(self.mapView.centerCoordinate.latitude,self.mapView.centerCoordinate.longitude));
    MAMapPoint point2 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(self.searchView.currentGPSCoordinate.latitude,self.searchView.currentGPSCoordinate.longitude));
    //2.计算距离
    CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
    if(distance < 5){
        gps_lcoation_btn.selected = YES;
    }
    else{
        gps_lcoation_btn.selected = NO;
    }
    
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"error = %@", error);
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    if (annotation == self.keywordResultTypeAnnotation) {
        static NSString *customReuseIdentifier = @"customReuseIdentifier";

        MAAnnotationView *annotationView = (MAAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIdentifier];

        if (annotationView == nil) {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"customReuseIdentifier"];

            annotationView.image = [UIImage imageNamed:@"img_map_center_wateRedBlank"];
            annotationView.centerOffset = CGPointMake(0, -(annotationView.image.size.height / 2.0));
        }

        return annotationView;
    }

    return nil;
}

#pragma mark - userLocation
/// 位置或者设备方向更新后，会调用此函数
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if (!updatingLocation) {
        return;
    }

    if (userLocation.location.horizontalAccuracy < 0) {
        return;
    }

    // only the first locate used.
    if (!self.isLocated) {
        self.isLocated = YES;
        self.searchView.currentGPSCoordinate = CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);

        [self.mapView setCenterCoordinate:self.searchView.currentGPSCoordinate];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.mapView.userTrackingMode = MAUserTrackingModeFollow;
            self.mapView.scrollEnabled = YES;
            [self.searchView searchPoiWithCenterCoordinate:self.mapView.centerCoordinate];
            
        });
    }
}

/// 当userTrackingMode改变时，调用此接口
- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated {
    if (mode == MAUserTrackingModeNone) {
        [gps_lcoation_btn setSelected:NO];
    } else {
        [gps_lcoation_btn setSelected:YES];
    }
}

- (void)mapView:(MAMapView *)mapView didTouchPois:(NSArray *)pois {
    MATouchPoi *poi = pois.firstObject;

    if (poi) {
        self.handlePOIWhenTouchMap = YES;
        [self.searchView searchPoiWithCenterCoordinate:poi.coordinate];
        [self.mapView setCenterCoordinate:poi.coordinate animated:YES];
    }
}

- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.handlePOIWhenTouchMap == NO) {
            if (self.searchView.expandState == NSPickLocationSearchViewExpand) {
                [self.searchView changeExpandState:NSPickLocationSearchViewUnExpand];
            }
        }

        self.handlePOIWhenTouchMap = NO;
    });
}

#pragma mark - NSPickLocationSearchViewDelegate

- (void)searchBarSearchButtonClicked {
}

- (void)searchViewTopOffsetChanged:(CGFloat)topOffset {
    [self searchViewTopOffsetChanged:topOffset animation:YES];
}

- (void)searchViewTopOffsetChanged:(CGFloat)topOffset animation:(BOOL)animation {
    [self.mapView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(NSPickLocationSearchViewUnExpandTopOffset));
        make.centerY.equalTo(self.view.mas_top).offset(topOffset / 2);
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (animation) {
            [UIView animateWithDuration:0.3
                             animations:^{
                self.mapView.logoCenter = CGPointMake(self.view.frame.size.width - self.mapView.logoSize.width / 2 - 20, topOffset  - 20 - self.mapView.frame.origin.y);
                self.mapView.scaleOrigin = CGPointMake(10, self.mapView.logoCenter.y - self.mapView.scaleSize.height / 2);
                [self.view layoutSubviews];
            }];
        } else {
            self.mapView.logoCenter = CGPointMake(self.view.frame.size.width - self.mapView.logoSize.width / 2 - 20, topOffset  - 20 - self.mapView.frame.origin.y);
            self.mapView.scaleOrigin = CGPointMake(10, self.mapView.logoCenter.y - self.mapView.scaleSize.height / 2);
        }
    });
}

- (void)searchViewSelectedPOIChanged:(AMapPOI *)selectedPoi isFirstPOI:(BOOL)isFirstPOI {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(selectedPoi.location.latitude, selectedPoi.location.longitude);

    if (isFirstPOI) {
        coordinate = self.searchView.currentPOISearchCoordinate;
    }

    self.mapView.scrollEnabled = NO;

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setMapViewScrollEnable) object:nil];
    [self performSelector:@selector(setMapViewScrollEnable) withObject:nil afterDelay:0.5];

    self.isMapViewRegionChangedFromTableView = YES;
    [self.mapView setCenterCoordinate:coordinate animated:YES];

    if (self.searchView.resultDataType == NSPickLocationSearchViewResultKeywordType) {
        [self.mapView removeAnnotation:self.keywordResultTypeAnnotation];
        self.keywordResultTypeAnnotation.coordinate = coordinate;
        [self.mapView addAnnotation:self.keywordResultTypeAnnotation];
    }
}

- (void)setMapViewScrollEnable {
    self.mapView.scrollEnabled = YES;
}

- (void)searchViewResultDataTypeChanged:(NSPickLocationSearchViewResultDataType)resutlDataType {
    if (resutlDataType == NSPickLocationSearchViewResultKeywordType) {
        self.centerAnnotationView.hidden = YES;
    } else {
        self.centerAnnotationView.hidden = NO;
        [self.mapView removeAnnotation:self.keywordResultTypeAnnotation];
    }
}
-(void)searchViewCurrentSelectedPOIChanged:(AMapPOI *)selectdPoi{
    if(selectdPoi == nil){
        sendBtn.enabled = NO;
    }
    else{
        sendBtn.enabled = YES;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
