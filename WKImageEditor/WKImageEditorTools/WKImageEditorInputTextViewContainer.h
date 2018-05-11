//
//  WKImageEditorInputTextViewContainer.h
//  WKImageEditor
//
//  Created by 吴珂 on 2018/4/8.
//  Copyright © 2018年 wukong.company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKImageEditorProtocol.h"

@interface WKImageEditorInputTextViewContainer : UIView
<
WKImageEditorOperatorProtocol
>

@property (nonatomic, weak) id<WKImageEditorOperateDelegate> operateDelegate;
@property (assign, nonatomic) WKImageEditorOperateType OperateType;//操作类型，用于指定编辑结果是基于图片还是视图直接截图
@property (nonatomic, strong ) UIColor *drawColor;

@property (strong, nonatomic) UIFont *drawFont;
- (void)beginInputText;
- (void)endInputText;

@end
