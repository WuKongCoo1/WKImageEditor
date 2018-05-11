//
//  WKImageEditorToolBar.h
//  WKImageEditor
//
//  Created by 吴珂 on 2018/5/10.
//  Copyright © 2018年 wukong.company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKImageEditorToolBarButton.h"

typedef NS_ENUM(NSInteger, WKImageEditorToolBarOperateType) {
    WKImageEditorToolBarOperateTypeChooseColor,
    WKImageEditorToolBarOperateTypeDrawRect,
    WKImageEditorToolBarOperateTypeDrawCircle,
    WKImageEditorToolBarOperateTypeDrawLine,
    WKImageEditorToolBarOperateTypeDrawBezier,
    WKImageEditorToolBarOperateTypeDrawText,
    WKImageEditorToolBarOperateTypeBackspace,//回退
    WKImageEditorToolBarOperateTypeClear,
    WKImageEditorToolBarOperateTypeSave,
    WKImageEditorToolBarOperateTypePackUp,
    WKImageEditorToolBarOperateTypeChooseTextSize,
    WKImageEditorToolBarOperateTypeUnpack
};

@interface WKImageEditorToolBar : UIView

+ (instancetype)imageEditorToolBar;

@property (weak, nonatomic) IBOutlet UILabel *textSizeLabel;

@property (copy, nonatomic) void (^operateBlock)(WKImageEditorToolBarOperateType type);
@property (strong, nonatomic) UIView *selectedOperateView;
@property (strong, nonatomic) UIColor *drawColor;
@property (assign, nonatomic) CGFloat fontSize;
@property (weak, nonatomic) IBOutlet WKImageEditorToolBarButton *chooseColorButton;

- (IBAction)chooseColorAction:(id)sender;
- (IBAction)drawRectShape:(id)sender;
- (IBAction)drawCircleAction:(UIButton *)sender;
- (IBAction)drawLineAction:(UIButton *)sender;
- (IBAction)drawBezierAction:(UIButton *)sender;
- (IBAction)drawTextAction:(UIButton *)sender;
- (IBAction)backspaceAction:(UIButton *)sender;
- (IBAction)clearAction:(UIButton *)sender;
- (IBAction)saveAction:(UIButton *)sender;
- (IBAction)packUpAction:(UIButton *)sender;
- (IBAction)unpackAction:(UIButton *)sender;
- (IBAction)chooseTextSizeAction:(id)sender;


@end
