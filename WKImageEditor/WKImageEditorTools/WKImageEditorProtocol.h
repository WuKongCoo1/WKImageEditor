//
//  WKImageEditorProtocol.h
//  WKImageEditor
//
//  Created by 吴珂 on 2018/4/11.
//  Copyright © 2018年 wukong.company. All rights reserved.
//  子编辑图片控制器需要实现的功能

#import <Foundation/Foundation.h>
#import "WKImageEditor.h"

@protocol WKImageEditorOperatorProtocol <NSObject>

- (void)rollback;
- (void)clear;

@end

//编辑操作回调协议
@protocol WKImageEditorOperateDelegate  <NSObject>

- (void)editOperator:(id<WKImageEditorOperatorProtocol>)editOperator type:(WKImageEditorEditOperationType)type;

@end
