//
//  UIImage+NSWaterMark.m
//
//  Created by Neil on 2023/10/27.
//

#import "UIImage+NSWaterMark.h"
#import "UIView+YYAdd.h"
#import "YYLabel.h"
@implementation UIImage (NSWaterMark)

#pragma mark - 给图片添加文字水印：
- (UIImage *)addWaterMarkWithText:(NSString *)text position:(NSWaterMarkPosition)position textColor:(UIColor *)textColor backgroudColor:(UIColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius font:(UIFont *)font margin:(CGFloat)margin padding:(CGFloat)padding {
    CGFloat imageWidth = self.size.width;
    CGFloat imageHeight = self.size.height;

    YYLabel *label = [YYLabel new];
    label.textContainerInset = UIEdgeInsetsMake(padding, padding, padding, padding);
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = cornerRadius;
    label.preferredMaxLayoutWidth = imageWidth - 2 * margin;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.text = text;
    label.textColor = textColor ? : [UIColor blackColor];
    label.backgroundColor = backgroundColor ? : [UIColor clearColor];
    label.font = font ? : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    CGSize size = [label sizeThatFits:CGSizeMake(imageWidth - 2 * margin, 0)];
    label.width =size.width;
    label.height =size.height;

    CGFloat textLabelWidth = label.width;
    CGFloat textLabelHeight = label.height;
    CGPoint point = CGPointZero;

    switch (position) {
        case NSWaterMarkLeftTop:
            label.textAlignment = NSTextAlignmentLeft;
            point = CGPointMake(margin, margin);
            break;

        case NSWaterMarkRightTop:
            label.textAlignment = NSTextAlignmentRight;
            point = CGPointMake(imageWidth - textLabelWidth  - margin, margin);
            break;

        case NSWaterMarkLeftBottom:
            label.textAlignment = NSTextAlignmentLeft;
            point = CGPointMake(margin, imageHeight - textLabelHeight - margin);
            break;

        case NSWaterMarkRightBottom:
            label.textAlignment = NSTextAlignmentRight;
            point = CGPointMake(imageWidth - textLabelWidth  - margin, imageHeight - textLabelHeight - margin);
            break;

        case NSWaterMarkCenter:
            label.textAlignment = NSTextAlignmentCenter;
            point = CGPointMake(imageWidth / 2 - textLabelWidth / 2, imageHeight / 2 - textLabelHeight / 2);

        default:
            break;
    }

    UIImageView *containerView = [[UIImageView alloc]initWithImage:self];
    [containerView addSubview:label];
    label.left = point.x;
    label.top = point.y;

    UIGraphicsBeginImageContextWithOptions(containerView.bounds.size, containerView.opaque, 1);
    [containerView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //返回图片
    return newImage;
}

@end
