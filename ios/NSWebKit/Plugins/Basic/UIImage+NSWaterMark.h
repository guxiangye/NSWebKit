//
//  UIImage+NSWaterMark.h
//
//  Created by Neil on 2023/10/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NSWaterMarkPosition) {
    NSWaterMarkLeftTop = 0,//左上
    NSWaterMarkRightTop,//右上
    NSWaterMarkLeftBottom,//左下
    NSWaterMarkRightBottom,//右下
    NSWaterMarkCenter,//居中
};

@interface UIImage (NSWaterMark)

- (UIImage *)addWaterMarkWithText:(NSString *)text position:(NSWaterMarkPosition)position textColor:(nullable UIColor *)textColor backgroudColor:(nullable UIColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius font:(nullable UIFont *)font margin:(CGFloat)margin padding:(CGFloat)padding;
@end

NS_ASSUME_NONNULL_END
