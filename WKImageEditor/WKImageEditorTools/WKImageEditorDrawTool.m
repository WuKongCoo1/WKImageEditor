//
//  WKImageEditorDrawTool.m
//  WKImageEditor
//
//  Created by 吴珂 on 2018/4/3.
//  Copyright © 2018年 wukong.company. All rights reserved.
//

#import "WKImageEditorDrawTool.h"


@implementation WKImageEditorDrawTool
{
    UIImage *_editedImage;
}
@synthesize lineWidth= _lineWidth;

+ (instancetype)imageEditorDrawTool:(CGSize)drawSize originalImage:(UIImage *)originalImage
{
    WKImageEditorDrawTool *tool = [[WKImageEditorDrawTool alloc] init];
    tool.drawSize = drawSize;
    tool.originalImage = originalImage;
    
    return tool;
}

+ (UIImage *)drawImage:(WKImageEditorDrawToolDrawType)type size:(CGSize)drawSize originalImage:(UIImage *)originalImage from:(CGPoint)from endPoint:(CGPoint)to drawColor:(UIColor *)color  lineWidth:(CGFloat)lineWidth
{
    CGSize size = drawSize;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    switch (type) {
        case WKImageEditorDrawToolDrawTypeLine:{
            [self drawLine:context from:from to:to drawColor:color lineWidth:lineWidth];
        }
            break;
            
        default:
            break;
    }
    
    [originalImage drawAtPoint:CGPointZero];
    
    CGFloat strokeWidth = lineWidth;
    
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);
    CGContextStrokePath(context);
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    
    UIGraphicsEndImageContext();
    return resultImage;
}

+ (UIImage *)drawLine:(CGContextRef)context from:(CGPoint)from to:(CGPoint)to drawColor:(UIColor *)color lineWidth:(CGFloat)lineWidth
{
    CGFloat strokeWidth = lineWidth;
    
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context, to.x, to.y);
    CGContextStrokePath(context);
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return resultImage;
}

+ (UIImage *)drawRect:(CGContextRef)context from:(CGPoint)from to:(CGPoint)to drawColor:(UIColor *)color lineWidth:(CGFloat)lineWidth
{
    CGRect rect = [self rectWithPoint:from to:to];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    
    CGFloat strokeWidth = lineWidth;
    
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    CGContextAddPath(context, path.CGPath);
    CGContextStrokePath(context);
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return resultImage;
}

+ (UIImage *)drawCircle:(CGContextRef)context from:(CGPoint)from to:(CGPoint)to drawColor:(UIColor *)color lineWidth:(CGFloat)lineWidth
{
    CGRect rect = [self rectWithPoint:from to:to];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    CGFloat strokeWidth = lineWidth;
    
    
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    CGContextAddPath(context, path.CGPath);
    CGContextStrokePath(context);
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return resultImage;
}



+ (UIImage *)drawPath:(CGContextRef)context path:(CGPathRef)path  drawColor:(UIColor *)color lineWidth:(CGFloat)lineWidth
{
    CGContextAddPath(context, path);
    CGFloat strokeWidth = lineWidth;
    
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextStrokePath(context);
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return resultImage;
}

#pragma mark - 处理逻辑
- (void)redraw
{
    if (self.dataSource == nil) {
        return;
    }
    
    if ([self.dataSource respondsToSelector:@selector(numberOfDrawTaskInImageEditorDrawTool:)]) {//有数据源
        NSInteger numberOfDrawTask = [self.dataSource numberOfDrawTaskInImageEditorDrawTool:self];
        NSAssert(numberOfDrawTask >= 0, @"绘制任务不能小于0");
        
        CGSize size = self.drawSize;
        CGFloat lineWidth = self.lineWidth;
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        UIImage *resultImage;
        CGContextRef context = UIGraphicsGetCurrentContext();
        _editedImage = self.originalImage;
        [self.originalImage drawAtPoint:CGPointZero];
        
        if (numberOfDrawTask == 0) {
            resultImage = self.originalImage;
        }
        
        for (NSInteger index = 0; index < numberOfDrawTask; index++) {
            WKImageEditorDrawToolDrawType drawType;
            NSDictionary *drawInfo;

            NSAssert([self.dataSource respondsToSelector:@selector(imageEditorDrawTool:drawInfoAtIndex:)], @"请实现imageEditorDrawTool:drawInfoAtIndex:方法", index);
            drawInfo = [self.dataSource imageEditorDrawTool:self drawInfoAtIndex:index];
            drawType = [drawInfo[WKImageEditorDrawToolInfoKeyDrawType] integerValue];
            UIColor *drawColor = drawInfo[WKImageEditorDrawToolInfoKeyDrawColor];
            CGPoint from = [drawInfo[WKImageEditorDrawToolInfoKeyFromPoint] CGPointValue];
            CGPoint to = [drawInfo[WKImageEditorDrawToolInfoKeyToPoint] CGPointValue];
            
            switch (drawType) {
                case WKImageEditorDrawToolDrawTypeLine:
                   resultImage = [WKImageEditorDrawTool drawLine:context from:from to:to drawColor:drawColor lineWidth:lineWidth];
                    break;
                case WKImageEditorDrawToolDrawTypeBezier:{
                    UIBezierPath *bezierPath = drawInfo[WKImageEditorDrawToolInfoKeyBezier];
                    resultImage = [WKImageEditorDrawTool drawPath:context path:bezierPath.CGPath drawColor:drawColor lineWidth:lineWidth];
                }
                    break;
                case WKImageEditorDrawToolDrawTypeRect:
                    resultImage = [WKImageEditorDrawTool drawRect:context from:from to:to drawColor:drawColor lineWidth:lineWidth];
                    break;
                case WKImageEditorDrawToolDrawTypeCircle:
                    resultImage = [WKImageEditorDrawTool drawCircle:context from:from to:to drawColor:drawColor lineWidth:lineWidth];
                    break;
                default:
                    break;
            }
            _editedImage = resultImage;
        }
        
  
        
        if (resultImage != nil) {
            if ([self.delegate respondsToSelector:@selector(imageEditorDrawToolDidDrawImage:drawImage:)]) {

                    [self.delegate imageEditorDrawToolDidDrawImage:self drawImage:resultImage];
                
            }
        }
        UIGraphicsEndImageContext();
    }
}

+ (CGRect)rectWithPoint:(CGPoint)from to:(CGPoint)to
{
    CGFloat maxX = MAX(from.x, to.x);
    CGFloat minX = MIN(from.x, to.x);
    CGFloat minY = MIN(from.y, to.y);
    CGFloat maxY = MAX(from.y, to.y);
    CGFloat width = maxX - minX;
    CGFloat heigth = maxY - minY;
    
    return CGRectMake(minX, minY, width, heigth);
}

- (CGFloat)lineWidth
{
    if (_lineWidth <= 0) {
        _lineWidth = 1.f;
    }
    return _lineWidth;
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    [self redraw];
}


@end
