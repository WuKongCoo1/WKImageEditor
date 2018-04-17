//
//  UIImage+WK.h
//  WuKongWeibo
//
//  Created by wu_kong_coo1 on 14-11-7.
//  Copyright (c) 2014年 myCompany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Custom)

//根据传入的比例对图片进行拉伸
+ (UIImage *)imageStrechWithImage:(NSString *)name leftRatio:(float)left topRatio:(float)top;

//上下左右参数分别表示需要保护的端盖范围
+ (UIImage *)imageResizableWithImage: (NSString *)name top: (float)top left:(float)left buttom:(float) buttom right: (float) right;

+ (UIImage *)resizeImage:(NSString *)name;

- (UIImage *)bhb_applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;


/**
 *  解决拍照图片方向问题
 *
 *  @return 返回修正后的图片
 */
- (UIImage *)fixOrientation;

///**
// *  生成二维码
// */
//+ (UIImage *)QRCodeForString:(NSString *)qrString size:(CGFloat)size;
//+ (UIImage *)QRCodeForString:(NSString *)qrString size:(CGFloat)size fillColor:(UIColor *)fillColor;

/**
 *  压缩图片
 *
 *  @param defineWidth 目标大小
 *
 *  @return 压缩后的图片
 */
- (UIImage *)compressWithTargetWidth:(CGFloat)defineWidth;

@end
