//
//  WKImageEditorToolBar.m
//  WKImageEditor
//
//  Created by 吴珂 on 2018/5/10.
//  Copyright © 2018年 wukong.company. All rights reserved.
//

#import "WKImageEditorToolBar.h"
#import "UIImage+WKColor.h"


@interface WKImageEditorToolBar()

@property (assign, nonatomic) BOOL hiddenItemStatus;

@end

@implementation WKImageEditorToolBar

+ (instancetype)imageEditorToolBar
{
    WKImageEditorToolBar *toolBar = [[[NSBundle mainBundle] loadNibNamed:@"WKImageEditorToolBar" owner:nil options:nil] firstObject];
    [toolBar setDrawColor:[UIColor blackColor]];
    return toolBar;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.layer.cornerRadius = 5.f;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setDrawColor:(UIColor *)drawColor
{
    _drawColor = drawColor;
    CGSize imgSize = [self.chooseColorButton imageForState:UIControlStateNormal].size;
    UIImage *newImage = [UIImage wk_imageWithColor:drawColor size:imgSize];
    [self.chooseColorButton setImage:newImage forState:UIControlStateNormal];
}

- (void)setFontSize:(CGFloat)fontSize
{
    self.textSizeLabel.text = [NSString stringWithFormat:@"%.0f", fontSize];
}

- (IBAction)chooseColorAction:(id)sender {
    [self safeHandleOepreate:sender type:WKImageEditorToolBarOperateTypeChooseColor];
}

- (IBAction)drawRectShape:(id)sender {
    [self safeHandleOepreate:sender type:WKImageEditorToolBarOperateTypeDrawRect];
}

- (IBAction)drawCircleAction:(UIButton *)sender {
    [self safeHandleOepreate:sender type:WKImageEditorToolBarOperateTypeDrawCircle];

}

- (IBAction)drawLineAction:(UIButton *)sender{
    [self safeHandleOepreate:sender type:WKImageEditorToolBarOperateTypeDrawLine];
    
    
}
- (IBAction)drawBezierAction:(UIButton *)sender{
    [self safeHandleOepreate:sender type:WKImageEditorToolBarOperateTypeDrawBezier];
}
- (IBAction)drawTextAction:(UIButton *)sender{
    [self safeHandleOepreate:sender type:WKImageEditorToolBarOperateTypeDrawText];
}
- (IBAction)backspaceAction:(UIButton *)sender{
    [self safeHandleOepreate:sender type:WKImageEditorToolBarOperateTypeBackspace];
}
- (IBAction)clearAction:(UIButton *)sender{
    [self safeHandleOepreate:sender type:WKImageEditorToolBarOperateTypeClear];
}
- (IBAction)saveAction:(UIButton *)sender{
    [self safeHandleOepreate:sender type:WKImageEditorToolBarOperateTypeSave];
}
- (IBAction)packUpAction:(UIButton *)sender
{
    CAShapeLayer *maskLayer = [CAShapeLayer new];
    UIBezierPath *startPath = [UIBezierPath bezierPathWithRect:self.bounds];

    UIBezierPath *endPath = [UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetMinX(sender.superview.frame), 0, CGRectGetWidth(sender.superview.frame), self.bounds.size.height)];
    self.hiddenItemStatus = !self.hiddenItemStatus;
    if (self.hiddenItemStatus) {//隐藏
        startPath = [UIBezierPath bezierPathWithRect:self.bounds];
        endPath = [UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetMinX(sender.superview.frame), 0, CGRectGetWidth(sender.superview.frame), self.bounds.size.height)];
    }else{//显示
        endPath = [UIBezierPath bezierPathWithRect:self.bounds];
        startPath = [UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetMinX(sender.superview.frame), 0, CGRectGetWidth(sender.superview.frame), self.bounds.size.height)];
    }
    self.layer.mask = maskLayer;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.fromValue = (__bridge id _Nullable)(startPath.CGPath);
    animation.toValue = (__bridge id)endPath.CGPath;
    animation.duration = 0.2f;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    [maskLayer addAnimation:animation forKey:@"hideAnimation"];
    
    [self safeHandleOepreate:sender type:WKImageEditorToolBarOperateTypePackUp];
}
- (IBAction)unpackAction:(UIButton *)sender
{
    [self safeHandleOepreate:sender type:WKImageEditorToolBarOperateTypeUnpack];
}
- (IBAction)chooseTextSizeAction:(id)sender
{
    [self safeHandleOepreate:sender type:WKImageEditorToolBarOperateTypeChooseTextSize];
}

- (void)safeHandleOepreate:(UIButton *)sender type:(WKImageEditorToolBarOperateType)type
{
    if (self.operateBlock) {
        self.operateBlock(type);
    }

    switch (type) {
        case WKImageEditorToolBarOperateTypeDrawLine:
            case WKImageEditorToolBarOperateTypeChooseColor:
            case WKImageEditorToolBarOperateTypeDrawRect:
            case WKImageEditorToolBarOperateTypeDrawCircle:
            case WKImageEditorToolBarOperateTypeDrawBezier:
            case WKImageEditorToolBarOperateTypeDrawText:
            [self commonHanldeOperate:sender];
            break;
            
        default:
            break;
    }
}

- (void)commonHanldeOperate:(UIButton *)sender
{
    ((UIButton *)self.selectedOperateView).selected = NO;
    sender.selected = YES;
    self.selectedOperateView = sender;
}

@end
