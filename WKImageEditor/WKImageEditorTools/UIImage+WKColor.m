//
//  UIImage+WKColor.m
//  WKImageEditor
//
//  Created by 吴珂 on 2018/5/11.
//  Copyright © 2018年 wukong.company. All rights reserved.
//

#import "UIImage+WKColor.h"

@implementation UIImage (WKColor)

+ (UIImage *)wk_imageWithColor:(UIColor *)color size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [color setFill];
    
    CGContextFillRect(context, CGRectMake(0, 0, 100, 100));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
