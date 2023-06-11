//
//  NSChooseImageUtil.h
//  NSWebKit
//
//  Created by Gao Neil on 2022/12/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NSChooseSourceType) {
    NSChooseSourceAlbumType,//相册
    NSChooseSourceCameraType,//相机
};
typedef NS_ENUM(NSInteger, NSChooseSizeType) {
    
    NSChooseSizeTypeOriginal = 1 << 0,//原图
    NSChooseSizeTypeCompressed = 1 << 1,//压缩图
    NSChooseSizeTypeAll = (NSChooseSizeTypeOriginal | NSChooseSizeTypeCompressed),
};

typedef void (^NSChooseImageResultBlock)(NSArray *result);

@interface NSChooseImageUtil : NSObject


@property(nonatomic,assign)NSChooseSizeType sizeType;
@property(nonatomic,assign)NSChooseSourceType sourceType;


+(void)chooseImageWithController:(UIViewController *)controller count:(int)count sizeType:(NSChooseSizeType)sizeType sourceType:(NSChooseSourceType)sourceType completionBlock:(NSChooseImageResultBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
