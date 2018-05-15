//
//  WKImageEditorToolBarButton.m
//  WKImageEditor
//
//  Created by 吴珂 on 2018/5/10.
//  Copyright © 2018年 wukong.company. All rights reserved.
//

#import "WKImageEditorToolBarButton.h"

#define WKUIColorFromRGBA(rgbValue, alphaValue) \
[UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

@implementation WKImageEditorToolBarButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    UIColor *normalBackgroundColor = WKUIColorFromRGBA(0x4a4a4a, 0.85);
    UIColor *highlightedOrSelectedBackgroundColor = WKUIColorFromRGBA(0x4a4a4a, 1);
    
    [self setBackgroundImage:[self imageWithColor:normalBackgroundColor size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [self setBackgroundImage:[self imageWithColor:highlightedOrSelectedBackgroundColor size:CGSizeMake(1, 1)] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[self imageWithColor:highlightedOrSelectedBackgroundColor size:CGSizeMake(1, 1)] forState:UIControlStateSelected];
}

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    [color setFill];

    CGContextFillRect(context, CGRectMake(0, 0, 100, 100));

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return image;
}

- (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
}

@end
