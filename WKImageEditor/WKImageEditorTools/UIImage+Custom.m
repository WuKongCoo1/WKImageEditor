//
//  UIImage+WK.m
//  WuKongWeibo
//
//  Created by wu_kong_coo1 on 14-11-7.
//  Copyright (c) 2014年 myCompany. All rights reserved.
//

#import "UIImage+Custom.h"
#import <Accelerate/Accelerate.h>
#import <float.h>
//#import "qrencode.h"

@implementation UIImage (Custom)
/**
 *  图片适配
 *
 *  @param name 图片名
 *
 *  @return 适配的图片
 */
+ (UIImage *)imageStrechWithImage:(NSString *)name leftRatio:(float)left topRatio:(float)top
{
    //保护公式
    // 1 = width - left - right
    // 1 = height - top - buttom
    // 也就是拉伸 1 × 1 区域
    UIImage *image = [UIImage imageNamed:name];
    float leftStrech = image.size.width * left;
    float topStrech = image.size.height * top;
    
    UIImage *resultImage = [image stretchableImageWithLeftCapWidth:leftStrech topCapHeight:topStrech];
    
    return resultImage;
}

//上下左右参数分别表示需要保护的端盖范围
+ (UIImage *)imageResizableWithImage:(NSString *)name top:(float)top left:(float)left buttom:(float)buttom right:(float)right
{
    UIImage *image = [UIImage imageNamed:name];
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(top, left, buttom, right);
    
    UIImage *resultImage = [image resizableImageWithCapInsets:edgeInsets];
    
    return resultImage;
}

+ (UIImage *)resizeImage:(NSString *)name
{
    return [self imageStrechWithImage:name leftRatio:0.5f topRatio:0.5f];
}

- (UIImage *)bhb_applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
    if (self.size.width < 1 || self.size.height < 1) {
        return nil;
    }
    if (!self.CGImage) {
        return nil;
    }
    if (maskImage && !maskImage.CGImage) {
        return nil;
    }
    
    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        
        
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            unsigned int radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1;
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

#pragma mark - 处理拍照图片方向问题
- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage *)compressWithTargetWidth:(CGFloat)defineWidth
{
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = (targetWidth / width) * height;
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [self drawInRect:CGRectMake(0,0,targetWidth,  targetHeight)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - public

//+ (UIImage *)QRCodeForString:(NSString *)qrString size:(CGFloat)size
//{
//    return [self QRCodeForString:qrString size:size fillColor:[UIColor blackColor]];
//}
//
//+ (UIImage *)QRCodeForString:(NSString *)qrString size:(CGFloat)imageSize fillColor:(UIColor *)fillColor
//{
//    if (0 == [qrString length])
//    {
//        return nil;
//    }
//    
//    QRcode *code = QRcode_encodeString([qrString UTF8String], 0, QR_ECLEVEL_Q, QR_MODE_8, 1);
//    
//    if (!code)
//    {
//        return nil;
//    }
//    
//    CGFloat size = imageSize * [[UIScreen mainScreen] scale];
//    
//    if (code->width > size)
//    {
//        printf("Image size is less than qr code size (%d)\n", code->width);
//        return nil;
//    }
//    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    
//    CGContextRef ctx = CGBitmapContextCreate(0, size, size, 8, size * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
//    
//    // The constants for specifying the alpha channel information are declared with the CGImageAlphaInfo type but can be passed to this parameter safely.
//    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0, -size);
//    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1, -1);
//    CGContextConcatCTM(ctx, CGAffineTransformConcat(translateTransform, scaleTransform));
//    
//    [self drawQRCode:code context:ctx size:size fillColor:fillColor];
//    
//    CGImageRef qrCGImage = CGBitmapContextCreateImage(ctx);
//    UIImage * qrImage = [UIImage imageWithCGImage:qrCGImage];
//    
//    CGContextRelease(ctx);
//    CGImageRelease(qrCGImage);
//    CGColorSpaceRelease(colorSpace);
//    QRcode_free(code);
//    return qrImage;
//}
//
//+ (void)drawQRCode:(QRcode *)code context:(CGContextRef)ctx size:(CGFloat)size fillColor:(UIColor *)fillColor
//{
//    int margin = 0;
//    unsigned char *data = code->data;
//    int width = code->width;
//    int totalWidth = width + margin * 2;
//    int imageSize = (int)floorf(size);
//    
//    // @todo - review float->int stuff
//    int pixelSize = imageSize / totalWidth;
//    
//    if (imageSize % totalWidth)
//    {
//        pixelSize = imageSize / width;
//        margin = (imageSize - width * pixelSize) / 2;
//    }
//    
//    CGRect rectDraw = CGRectMake(0.0f, 0.0f, pixelSize, pixelSize);
//    // draw
//    CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
//    
//    for(int i = 0; i < width; ++i)
//    {
//        for(int j = 0; j < width; ++j)
//        {
//            if(*data & 1)
//            {
//                rectDraw.origin = CGPointMake(margin + j * pixelSize, margin + i * pixelSize);
//                CGContextAddRect(ctx, rectDraw);
//            }
//            
//            ++data;
//        }
//    }
//    
//    CGContextFillPath(ctx);
//}


@end
