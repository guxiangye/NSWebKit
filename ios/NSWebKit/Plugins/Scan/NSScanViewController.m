//
//  NSScanViewController.m
//  NSWebKit
//
//  Created by Neil on 23-5-26.
//  Copyright (c) 2023年 nswebkit. All rights reserved.
//

#import "NSScanViewController.h"
#import "LBXScanViewStyle.h"
#import "UIImage+YYAdd.h"
#import "Masonry.h"
#import "LBXPermission.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface NSScanViewController ()
{
    UIButton *albumBtn;
    UILabel *titleLable;
}
@end

@implementation NSScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    self.view.backgroundColor = [UIColor blackColor];

    self.title = self.navigationTitle ? : @"扫一扫";

    //设置扫码区域参数
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
//    扫码框中心位置与View中心位置上移偏移像素(一般扫码框在视图中心位置上方一点)
    style.centerUpOffset = 44;
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Inner;
    //扫码框周围4个角绘制线段宽度
    style.photoframeLineW = 2;
    //扫码框周围4个角水平长度
    style.photoframeAngleW = 18;
    //扫码框周围4个角垂直高度
    style.photoframeAngleH = 18;

    //是否显示扫码框
    style.isNeedShowRetangle = YES;
    style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
    style.colorAngle = [UIColor colorWithRed:0. / 255 green:200. / 255. blue:20. / 255. alpha:1.0];

    //qq里面的线条图片
    UIImage *imgLine = [UIImage imageNamed:@"sdp_ic_scan_line"];
    style.animationImage = imgLine;

    style.notRecoginitonArea = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];

    self.style = style;

    //返回按钮
    NSMutableArray *leftBarButtomItems = @[].mutableCopy;
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIColor *titleColor = nil;
    if (@available(iOS 15.0, *)) {
        titleColor = [self.navigationController.navigationBar.scrollEdgeAppearance.titleTextAttributes objectForKey:NSForegroundColorAttributeName];
    } else {
        titleColor = self.navigationController.navigationBar.tintColor;
    }
    [backBtn setImage:[[UIImage imageNamed:@"sdp_back_btn"]imageByTintColor:titleColor] forState:UIControlStateNormal];
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backBtn addTarget:self action:@selector(clickBackBtn) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(0, 0, 25, 44);
    [leftBarButtomItems addObject:[[UIBarButtonItem alloc]initWithCustomView:backBtn]];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];

    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self drawScanView];

    [LBXPermission authorizeWithType:LBXPermissionType_Camera completion:^(BOOL granted, BOOL firstTime) {
        if (granted) {
            //不延时，可能会导致界面黑屏并卡住一会
            [self performSelector:@selector(startScan) withObject:nil afterDelay:0.3];
        } else if (!firstTime) {
            //不是第一次请求权限，那么可以弹出权限提示，用户选择设置，即跳转到设置界面，设置权限
            [LBXPermissionSetting showAlertToDislayPrivacySettingWithTitle:@"提示" msg:@"没有相机权限，是否前往设置" cancel:@"取消" setting:@"设置"];
        } else {
            [self.qRScanView stopDeviceReadying];
        }
    }];

    //相册按钮
    if (albumBtn == nil && self.hideAlbum == NO) {
        UIImage *album = [UIImage imageNamed:@"sdp_ic_album"];
        UIButton *albumBtn = [UIButton new];
        [albumBtn setImage:album forState:UIControlStateNormal];
        [self.view addSubview:albumBtn];

        [albumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).multipliedBy(0.8);
        }];
        [albumBtn addTarget:self action:@selector(clickAlbum) forControlEvents:UIControlEventTouchUpInside];
//        UILabel *title = [UILabel new];
//        title.textColor = [UIColor whiteColor];
//        title.text = @"相册";
//        [self.view addSubview:title];
//        [title mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.centerX.equalTo(self.view);
//                    make.top.equalTo(albumBtn.mas_bottom).offset(5);
//        }];
    }

    if (self.navigationController.navigationBarHidden == YES &&  titleLable== nil) {
        titleLable = [UILabel new];
        titleLable.textColor = [UIColor whiteColor];
        titleLable.text = self.title;
        [self.view addSubview:titleLable];
        [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuideBottom);
        }];

        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];

        [backBtn setImage:[[UIImage imageNamed:@"sdp_back_btn"]imageByTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(clickBackBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:backBtn];
        [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(titleLable);
                    make.left.equalTo(@10);
                    make.width.height.equalTo(@40);
        }];
    }
}

//绘制扫描区域
- (void)drawScanView
{
#ifdef LBXScan_Define_UI

    if (!_qRScanView) {
        CGRect rect = self.view.frame;
        rect.origin = CGPointMake(0, 0);

        self.qRScanView = [[LBXScanView alloc]initWithFrame:rect style:_style];

        [self.view addSubview:_qRScanView];
    }

    if (!_cameraInvokeMsg) {
//        _cameraInvokeMsg = NSLocalizedString(@"wating...", nil);
    }

    [_qRScanView startDeviceReadyingWithText:_cameraInvokeMsg];
#endif
}

- (void)reStartDevice
{
    [_scanObj startScan];
}

- (void)requestCameraPemissionWithResult:(void (^)(BOOL granted))completion
{
    [LBXPermission authorizeWithType:LBXPermissionType_Camera completion:^(BOOL granted, BOOL firstTime) {
        if (granted) {
        } else if (!firstTime) {
            //不是第一次请求权限，那么可以弹出权限提示，用户选择设置，即跳转到设置界面，设置权限
            [LBXPermissionSetting showAlertToDislayPrivacySettingWithTitle:@"提示" msg:@"没有相册权限，是否前往设置" cancel:@"取消" setting:@"设置"];
        }
    }];

    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
        AVAuthorizationStatus permission =
            [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

        switch (permission) {
            case AVAuthorizationStatusAuthorized:
                completion(YES);
                break;
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
                completion(NO);
                break;
            case AVAuthorizationStatusNotDetermined:{
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                         completionHandler:^(BOOL granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                                       if (granted) {
                                           completion(true);
                                       } else {
                                           completion(false);
                                       }
                                   });
                }];
            }
            break;
        }
    }
}

//启动设备
- (void)startScan
{
    UIView *videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    videoView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:videoView atIndex:0];
    __weak __typeof(self) weakSelf = self;

    if (!_scanObj) {
        CGRect cropRect = CGRectZero;

        if (_isOpenInterestRect) {
            //设置只识别框内区域
            cropRect = [LBXScanView getScanRectWithPreView:self.view style:_style];
        }

        NSArray *objType = nil;
        //AVMetadataObjectTypeITF14Code 扫码效果不行,另外只能输入一个码制，虽然接口是可以输入多个码制
        if (self.supportScanTypeArray == nil) {
            objType = @[AVMetadataObjectTypeQRCode,//二维码
                        //以下为条形码，如果项目只需要扫描二维码，下面都不要写
                        AVMetadataObjectTypeEAN13Code,
                        AVMetadataObjectTypeEAN8Code,
                        AVMetadataObjectTypeUPCECode,
                        AVMetadataObjectTypeCode39Code,
                        AVMetadataObjectTypeCode39Mod43Code,
                        AVMetadataObjectTypeCode93Code,
                        AVMetadataObjectTypeCode128Code,
                        AVMetadataObjectTypePDF417Code];
        } else {
            NSMutableArray *array = @[].mutableCopy;
            if ([self.supportScanTypeArray containsObject:@"qrCode"]) {
                [array addObject:AVMetadataObjectTypeQRCode];
            }
            if ([self.supportScanTypeArray containsObject:@"barCode"]) {
                [array addObjectsFromArray:@[
                     AVMetadataObjectTypeEAN13Code,
                     AVMetadataObjectTypeEAN8Code,
                     AVMetadataObjectTypeUPCECode,
                     AVMetadataObjectTypeCode39Code,
                     AVMetadataObjectTypeCode39Mod43Code,
                     AVMetadataObjectTypeCode93Code,
                     AVMetadataObjectTypeCode128Code,
                     AVMetadataObjectTypePDF417Code]];
            }
            objType = array.copy;
        }

        self.scanObj = [[LBXScanNative alloc]initWithPreView:videoView ObjectType:objType cropRect:cropRect success:^(NSArray<LBXScanResult *> *array) {
            [weakSelf scanResultWithArray:array];
        }];
        [_scanObj setNeedCaptureImage:_isNeedScanImage];
    }
    [_scanObj startScan];

#ifdef LBXScan_Define_UI
    [_qRScanView stopDeviceReadying];
    [_qRScanView startScanAnimation];
#endif

    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    [self stopScan];

#ifdef LBXScan_Define_UI
    [_qRScanView stopScanAnimation];
#endif
}

- (void)stopScan
{
    [_scanObj stopScan];
}

- (void)clickBackBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickAlbum {
    [self openLocalPhoto:NO];
}

#pragma mark -扫码结果处理

- (void)scanResultWithArray:(NSArray<LBXScanResult *> *)array
{
    if (array.count > 0) {
        LBXScanResult *obj = array.firstObject;

        NSDictionary *result = @{ @"code": obj.strScanned, @"scanType": [self getScanCodeType:obj.strBarCodeType] };
        if (self.scanResultBlock) {
            self.scanResultBlock(result);
        }
        [self clickBackBtn];
    }

//    CIDetectorTypeQRCode
}

- (NSString *)getScanCodeType:(NSString *)codeType {
    if ([codeType containsString:@"QR"]) {
        return @"qrCode";
    } else {
        return @"barCode";
    }
}

//开关闪光灯
- (void)openOrCloseFlash
{
    [_scanObj changeTorch];
    self.isOpenFlash = !self.isOpenFlash;
}

#pragma mark --打开相册并识别图片

/*!
 *  打开本地照片，选择图片识别
 */
- (void)openLocalPhoto:(BOOL)allowsEditing
{
    [LBXPermission authorizeWithType:LBXPermissionType_Photos completion:^(BOOL granted, BOOL firstTime) {
        if (granted) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];

            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

            picker.delegate = self;

            //部分机型有问题
            picker.allowsEditing = allowsEditing;

            [self presentViewController:picker animated:YES completion:nil];
        } else if (!firstTime) {
            //不是第一次请求权限，那么可以弹出权限提示，用户选择设置，即跳转到设置界面，设置权限
            [LBXPermissionSetting showAlertToDislayPrivacySettingWithTitle:@"提示" msg:@"没有相册权限，是否前往设置" cancel:@"取消" setting:@"设置"];
        }
    }];
}

//当选择一张图片后进入这里

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];

    __block UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];

    if (!image) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }

    __weak __typeof(self) weakSelf = self;

    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 8.0) {
        [LBXScanNative recognizeImage:image success:^(NSArray<LBXScanResult *> *array) {
            [weakSelf scanResultWithArray:array];
        }];
    } else {
        [self showError:@"native低于ios8.0系统不支持识别图片条码"];
    }
}

- (void)showError:(NSString *)str
{
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"cancel");

    [picker dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
