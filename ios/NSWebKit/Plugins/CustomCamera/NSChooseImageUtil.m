//
//  NSChooseImageUtil.m
//  NSWebKit
//
//  Created by Gao Neil on 2022/12/23.
//

#import "NSChooseImageUtil.h"
#import "TZImagePickerController.h"
#import "UIImage+ZYCompressMoments.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "YYKitMacro.h"
#import "NSImageURLProtocol.h"
#import "NSString+YYAdd.h"

@interface NSChooseImageUtil ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic,weak)UIViewController *viewController;
@property(nonatomic,copy)NSChooseImageResultBlock completionBlock;

@end

@implementation NSChooseImageUtil

- (void)dealloc{
    
}

+ (NSChooseImageUtil*)sharedManager
{
    //Singleton instance
    static NSChooseImageUtil *manager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[self alloc] init];
    });
    
    return manager;
}


+(void)chooseImageWithController:(UIViewController *)controller count:(int)count sizeType:(NSChooseSizeType)sizeType sourceType:(NSChooseSourceType)sourceType completionBlock:(NSChooseImageResultBlock)completionBlock{
    if (sourceType == NSChooseSourceAlbumType) {
        
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:count delegate:nil];
        imagePickerVc.allowPreview = NO;
        imagePickerVc.allowPickingVideo = NO;
        imagePickerVc.allowCameraLocation = NO;
        
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            NSMutableArray *data = @[].mutableCopy;
            //photos 是缩略图
            if (photos.count > 0) {
                
                UIButton *_progressHUD = [self getProgressHUD:controller];
                
                UIWindow *applicationWindow;
                if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(window)]) {
                    applicationWindow = [[[UIApplication sharedApplication] delegate] window];
                } else {
                    applicationWindow = [[UIApplication sharedApplication] keyWindow];
                }
                [applicationWindow addSubview:_progressHUD];
                [controller.view setNeedsLayout];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    for(PHAsset *asset in assets){
                        
                        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                        NSMutableDictionary *dic = @{}.mutableCopy;
                        
                        //        如下两个方法completion一般会调多次，一般会先返回缩略图，再返回原图(详见方法内部使用的系统API的说明)，如果info[PHImageResultIsDegradedKey] 为 YES，则表明当前返回的是缩略图，否则是原图。
                        [[TZImageManager manager] getOriginalPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {
                            
                            if ([info[PHImageResultIsDegradedKey]boolValue] == NO) {
                                
                                if (sizeType & NSChooseSizeTypeOriginal) {
                                    //原图
                                    NSData *data = UIImageJPEGRepresentation(photo, 1.0f);
                                    NSString *tmpDir =  NSTemporaryDirectory();
                                    
                               
                                    NSString *picFileName = [NSString stringWithFormat:@"%@%u.png", [[NSString stringWithFormat:@"%ld",data.hash] md5String],arc4random_uniform(10000000)];
                                    NSString *tempPath = [tmpDir stringByAppendingPathComponent:picFileName];
                                    BOOL result =  [data writeToFile:tempPath atomically:YES];
                                    if (result) {
                                        dic[@"original"] = [NSString stringWithFormat:@"%@://%@",NSSchemeKey,picFileName];
                                    }
                                    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                                    dic[@"originalBase64"] = encodedImageStr?:@"";
                                }
                                if (sizeType & NSChooseSizeTypeCompressed) {
                                    //压缩图
                                    NSData *data = [photo zy_compressForMoments];
                                    
                                    NSString *tmpDir =  NSTemporaryDirectory();
                                    NSString *picFileName = [NSString stringWithFormat:@"%@%u.png", [[NSString stringWithFormat:@"%ld",data.hash] md5String],arc4random_uniform(10000000)];
                                    NSString *tempPath = [tmpDir stringByAppendingPathComponent:picFileName];
                                    BOOL result =  [data writeToFile:tempPath atomically:YES];
                                    if (result) {
                                        dic[@"compressed"] = [NSString stringWithFormat:@"%@://%@",NSSchemeKey,picFileName];
                                    }
                                    
                                    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                                    dic[@"compressBase64"] = encodedImageStr?:@"";
                                }
                                dispatch_semaphore_signal(semaphore);
                                
                                
                            }
                            
                        }];
                        
                        [data addObject:dic];
                        
                        
                        
                        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                        
                    }
                    
                    if (completionBlock) {
                        completionBlock(data);
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_progressHUD removeFromSuperview];
                    });
                    
                    
                });
                
                
            }
            
            
        }];
        [controller presentViewController:imagePickerVc animated:YES completion:nil];
        
    }
    else if(sourceType == NSChooseSourceCameraType){
        
        NSChooseImageUtil *util = [NSChooseImageUtil sharedManager];
        util.viewController = controller;

        util.completionBlock = completionBlock;
        util.sizeType = sizeType;
        [util takePhoto];
        
    }
}


-(void)takePhoto{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        // 无相机权限 做一个友好的提示
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }]];
        [self.viewController presentViewController:alertController animated:YES completion:nil];
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self takePhoto];
                });
            }
        }];
        // 拍照之前还需要检查相册权限
    } else if ([PHPhotoLibrary authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }]];
        [self.viewController presentViewController:alertController animated:YES completion:nil];
    } else if ([PHPhotoLibrary authorizationStatus] == 0) { // 未请求过相册权限
        [[TZImageManager manager] requestAuthorizationWithCompletion:^{
            [self takePhoto];
        }];
    } else {
        [self pushImagePickerController];
    }
}
// 调用相机
- (void)pushImagePickerController {
    
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *_imagePickerVc = [self imagePickerVc];
            _imagePickerVc.sourceType = sourceType;
            NSMutableArray *mediaTypes = [NSMutableArray array];
            [mediaTypes addObject:(NSString *)kUTTypeImage];
    
            if (mediaTypes.count) {
                _imagePickerVc.mediaTypes = mediaTypes;
            }
            [self.viewController presentViewController:_imagePickerVc animated:YES completion:nil];
        } else {
            NSLog(@"模拟器中无法打开照相机,请在真机中使用");
        }
}
- (UIImagePickerController *)imagePickerVc {
    UIImagePickerController *_imagePickerVc = nil;
    
    _imagePickerVc = [[UIImagePickerController alloc] init];
    _imagePickerVc.delegate = self;
    // set appearance / 改变相册选择页的导航栏外观
    _imagePickerVc.navigationBar.barTintColor = self.viewController.navigationController.navigationBar.barTintColor;
    _imagePickerVc.navigationBar.tintColor = self.viewController.navigationController.navigationBar.tintColor;
    UIBarButtonItem *tzBarItem, *BarItem;
    if (@available(iOS 9, *)) {
        tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
        BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
    } else {
        tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
        BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
    }
    NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
    [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    
    
    return _imagePickerVc;
}


+(UIButton *)getProgressHUD:(UIViewController *)controller{
    
    UIButton* _progressHUD = [UIButton buttonWithType:UIButtonTypeCustom];
    [_progressHUD setBackgroundColor:[UIColor clearColor]];
    
    UIView* _HUDContainer = [[UIView alloc] init];
    _HUDContainer.layer.cornerRadius = 8;
    _HUDContainer.clipsToBounds = YES;
    _HUDContainer.backgroundColor = [UIColor darkGrayColor];
    _HUDContainer.alpha = 0.7;
    
    UIActivityIndicatorView* _HUDIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    UILabel *_HUDLabel = [[UILabel alloc] init];
    _HUDLabel.textAlignment = NSTextAlignmentCenter;
    _HUDLabel.text = @"正在处理";
    _HUDLabel.font = [UIFont systemFontOfSize:15];
    _HUDLabel.textColor = [UIColor whiteColor];
    
    [_HUDContainer addSubview:_HUDLabel];
    [_HUDContainer addSubview:_HUDIndicatorView];
    [_progressHUD addSubview:_HUDContainer];
    
    [_HUDIndicatorView startAnimating];
    
    CGFloat progressHUDY = CGRectGetMaxY(controller.navigationController.navigationBar.frame);
    _progressHUD.frame = CGRectMake(0, progressHUDY, controller.view.frame.size.width, controller.view.frame.size.height - progressHUDY);
    _HUDContainer.frame = CGRectMake((controller.view.frame.size.width - 120) / 2, (_progressHUD.frame.size.height - 90 - progressHUDY) / 2, 120, 90);
    _HUDIndicatorView.frame = CGRectMake(45, 15, 30, 30);
    _HUDLabel.frame = CGRectMake(0,40, 120, 50);

    
    return _progressHUD;
}
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        
        UIImage *photo = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        NSMutableDictionary *dic = @{}.mutableCopy;
        if (self.sizeType & NSChooseSizeTypeOriginal) {
            //原图
            NSData *data = UIImageJPEGRepresentation(photo, 1.0f);
            NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            dic[@"originalBase64"] = encodedImageStr?:@"";
        }
        if (self.sizeType & NSChooseSizeTypeCompressed) {
            //压缩图
            NSData *data = [photo zy_compressForMoments];
            NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            dic[@"compressedBase64"] = encodedImageStr?:@"";
        }
        
        if(self.completionBlock){
            self.completionBlock(@[dic]);
            self.completionBlock = nil;
        }
        self.viewController = nil;

    }
}

@end
