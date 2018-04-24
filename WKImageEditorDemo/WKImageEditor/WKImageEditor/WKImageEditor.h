//
//  WKImageEditor.h
//  WKImageEditor
//
//  Created by 吴珂 on 2018/4/4.
//  Copyright © 2018年 wukong.company. All rights reserved.
//

#ifndef WKImageEditor_h
#define WKImageEditor_h


/**
 编辑类型，用于指定编辑是针对原始图片还是针对整个编辑视图

 - WKImageEditorOperateType: <#WKImageEditExpectResultTypeBaseOnOriginalImage description#>
 */
typedef NS_ENUM(NSInteger, WKImageEditorOperateType) {
    WKImageEditOperateTypeBaseOnOriginalImage,//基于原始图片编辑
    WKImageEditOperateTypeCaptureFromContainerView//基于编辑视图
};


/**
 具体编辑类型

 - WKImageEditTypeLine: 直线
 - WKImageEditTypeBezier: 曲线
 - WKImageEditTypeRect: 方框
 - WKImageEditTypeCircle: 内切圆
 - WKImageEditTypeText: 文本
 */
typedef NS_ENUM(NSInteger, WKImageEditType) {
    WKImageEditTypeLine,
    WKImageEditTypeBezier,
    WKImageEditTypeRect,
    WKImageEditTypeCircle,
    WKImageEditTypeText
};

typedef NS_ENUM(NSInteger, WKImageEditorScrollViewDrawType) {
    WKImageEditorScrollViewDrawTypeLine = WKImageEditTypeLine,
    WKImageEditorScrollViewDrawTypeBezier = WKImageEditTypeBezier,
    WKImageEditorScrollViewDrawTypeRect = WKImageEditTypeRect,
    WKImageEditorScrollViewDrawTypeCircle = WKImageEditTypeCircle,
    WKImageEditorScrollViewDrawTypeText  = WKImageEditTypeText
};

typedef NS_ENUM(NSInteger, WKImageEditorDrawToolDrawType) {
    WKImageEditorDrawToolDrawTypeLine = WKImageEditorScrollViewDrawTypeLine,
    WKImageEditorDrawToolDrawTypeBezier = WKImageEditorScrollViewDrawTypeBezier,
    WKImageEditorDrawToolDrawTypeRect = WKImageEditorScrollViewDrawTypeRect,
    WKImageEditorDrawToolDrawTypeCircle  = WKImageEditorScrollViewDrawTypeCircle
};


/**
 操作类型、图形或者文字

 - WKImageEditorEditOperationTypeGraph: 图形
 */
typedef NS_ENUM(NSInteger, WKImageEditorEditOperationType) {
    WKImageEditorEditOperationTypeGraph,//图形
    WKImageEditorEditOperationTypeText
};

#endif /* WKImageEditor_h */
