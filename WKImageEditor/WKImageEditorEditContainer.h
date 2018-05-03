//
//  WKImageEditorEditContainer.h
//  WKImageEditor
//
//  Created by 吴珂 on 2018/4/11.
//  Copyright © 2018年 wukong.company. All rights reserved.
//  编辑容器

#import <UIKit/UIKit.h>
#import "WKImageEditor.h"
#import "WKImageEditorProtocol.h"

@interface WKImageEditorEditContainer : UIView
<
WKImageEditorOperatorProtocol
>

@property (assign, nonatomic) WKImageEditorOperateType OperateType;//操作类型，用于指定编辑结果是基于图片还是视图直接截图
@property (assign, nonatomic) WKImageEditType type;//编辑子类型，表示当前具体的编辑类型是划线还是文字等
@property (strong, nonatomic) UIColor *drawColor;


+ (instancetype)imageEditorEditContainerWithUrl:(NSString *)url;
+ (instancetype)imageEditorEditContainerWithImage:(UIImage *)image;


- (void)beginEditing;
- (void)beginEditing:(WKImageEditType)type;
- (void)endEditing;

- (void)resultImage:(void (^)(UIImage *image))complete;

@end
