//
//  WKImageEditorDrawTool.h
//  WKImageEditor
//
//  Created by 吴珂 on 2018/4/3.
//  Copyright © 2018年 wukong.company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WKImageEditor.h"

typedef NS_STRING_ENUM NSString * WKImageEditorDrawToolInfoKey;
static WKImageEditorDrawToolInfoKey WKImageEditorDrawToolInfoKeyFromPoint = @"WKImageEditorDrawToolInfoKeyFromPoint";//起始点
static WKImageEditorDrawToolInfoKey WKImageEditorDrawToolInfoKeyToPoint = @"WKImageEditorDrawToolInfoKeyToPoint";//终止点
static WKImageEditorDrawToolInfoKey WKImageEditorDrawToolInfoKeyDrawType = @"WKImageEditorDrawToolInfoKeyDrawType";//绘制类型
static WKImageEditorDrawToolInfoKey WKImageEditorDrawToolInfoKeyDrawID = @"WKImageEditorDrawToolInfoKeyDrawID";//绘制id
static WKImageEditorDrawToolInfoKey WKImageEditorDrawToolInfoKeyBezier = @"WKImageEditorDrawToolInfoKeyBezier";//绘制曲线的beizerPath

@class WKImageEditorDrawTool;



@protocol WKImageEditorDrawToolDataSource <NSObject>

- (NSInteger)numberOfDrawTaskInImageEditorDrawTool:(WKImageEditorDrawTool *)tool;
- (NSDictionary *)imageEditorDrawTool:(WKImageEditorDrawTool *)drawTool drawInfoAtIndex:(NSInteger)index;

@end

@protocol WKImageEditorDrawToolDelegate <NSObject>

- (void)imageEditorDrawToolDidDrawImage:(WKImageEditorDrawTool *)drawTool drawImage:(UIImage *)drawImage;

@end

@interface WKImageEditorDrawTool : NSObject

@property (nonatomic, weak) id<WKImageEditorDrawToolDataSource> dataSource;
@property (nonatomic, weak) id<WKImageEditorDrawToolDelegate> delegate;

@property (nonatomic, assign) WKImageEditorDrawToolDrawType currentDrawType;
@property (assign, nonatomic) WKImageEditorOperateType OperateType;//操作类型，用于指定编辑结果是基于图片还是视图直接截图

@property (nonatomic, copy) UIImage *originalImage;
@property (nonatomic, assign) CGSize drawSize;//绘制size
@property (copy, nonatomic) UIColor *drawColor;//绘制颜色

+ (UIImage *)drawImage:(WKImageEditorDrawToolDrawType)type size:(CGSize)drawSize originalImage:(UIImage *)originalImage from:(CGPoint)from endPoint:(CGPoint)to drawColor:(UIColor *)color;
+ (instancetype)imageEditorDrawTool:(CGSize)drawSize originalImage:(UIImage *)originalImage;

/**
 重新绘制图片
 */
- (void)redraw;
@end
