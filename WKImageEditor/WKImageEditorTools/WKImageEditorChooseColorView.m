//
//  WKImageEditorChooseColorView.m
//  WKImageEditor
//
//  Created by 吴珂 on 2018/5/10.
//  Copyright © 2018年 wukong.company. All rights reserved.
// 选择颜色控制器

#import "WKImageEditorChooseColorView.h"
#import <OAStackView/OAStackView.h>
#import <Masonry/Masonry.h>
#import "UIButton+WKBlock.h"

#define WKUIColorFromRGBA(rgbValue) \
[UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:1]

#define WKUIColorFromRGBAWithAlpha(rgbValue, alphaValue) \
[UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

@interface WKImageEditorChooseColorView()

@property (nonatomic, strong) OAStackView *stackView;

@end

@implementation WKImageEditorChooseColorView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (void)commonSetup
{
    //背景色
    self.backgroundColor = WKUIColorFromRGBAWithAlpha(0x4a4a4a, 0.85);
    void (^handleLayer)(CALayer *layer) = ^(CALayer *layer){
        layer.cornerRadius = 3.f;
        layer.masksToBounds = YES;
    };
    handleLayer(self.layer);
    
    //设置stackView
    if (self.stackView == nil) {
        UIView *realBgView = [UIView new];
        realBgView.backgroundColor = self.backgroundColor;
        [self addSubview:realBgView];
        [realBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self).offset(-20);
            make.height.equalTo(self).offset(-10);
            make.center.equalTo(self);
        }];
        
        self.stackView = ({
            OAStackView *sv = [[OAStackView alloc] init];
            sv.alignment = OAStackViewAlignmentFill;
            sv.distribution = OAStackViewDistributionFillEqually;
            sv.spacing = 5.f;
            sv;
        });
        
        [realBgView addSubview:self.stackView];
        [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(realBgView);
        }];
    }
    
//    return;
    
    //颜色设置
//    黑：#000000，白#ffffff，深红：#ab0006，大红：#ff0404，橘黄：#fe6200，亮黄：#f8f700，绿：#00bb35，湖蓝：#00e1ef，群青：#0000ff，紫罗兰：#e010ff
    NSArray *colors = @[WKUIColorFromRGBA(0x000000), WKUIColorFromRGBA(0xffffff), WKUIColorFromRGBA(0xab0006), WKUIColorFromRGBA(0xff0404), WKUIColorFromRGBA(0xfe6200), WKUIColorFromRGBA(0xf8f700), WKUIColorFromRGBA(0x00bb35), WKUIColorFromRGBA(0x00e1ef), WKUIColorFromRGBA(0x0000ff), WKUIColorFromRGBA(0xe010ff)];
    
    __block UIButton *preButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    [preButton setBackgroundImage:[self imageWithColor:[colors firstObject] size:CGSizeMake(10, 10)] forState:UIControlStateNormal];
    preButton.backgroundColor = [UIColor blueColor];
    [self.stackView addArrangedSubview:preButton];
    __weak typeof(self)weakSelf = self;
    [preButton wk_addActionHandler:^(NSInteger tag) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.didChooseColor) {
            strongSelf.didChooseColor([colors firstObject]);
            strongSelf.colorIndex = 0;
        }
    }];
    [colors enumerateObjectsUsingBlock:^(UIColor *  _Nonnull color, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx != 0) {
            
           
            
            UIButton *button  = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.stackView addArrangedSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(preButton);
            }];
            [button setBackgroundImage:[self imageWithColor:color size:CGSizeMake(10, 10)] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor blueColor];
            __weak typeof(self)weakSelf = self;
            [button wk_addActionHandler:^(NSInteger tag) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf.didChooseColor) {
                    strongSelf.didChooseColor(color);
                    strongSelf.colorIndex = idx;
                }
            }];
            
            void (^handleLayer)(CALayer *layer, CGFloat borderWidth) = ^(CALayer *layer, CGFloat borderWidth){
                layer.cornerRadius = 3.f;
                layer.borderWidth = borderWidth;
                layer.borderColor = [UIColor whiteColor].CGColor;
                layer.masksToBounds = YES;
            };
            handleLayer(button.layer, 0);
            
            preButton = button;
        }
    }];
    
    //初始化当前选中颜色
    self.colorIndex = 0;
}

- (void)setColorIndex:(NSInteger)colorIndex
{
    if (colorIndex >= self.stackView.arrangedSubviews.count) {
        return;
    }
    UIButton *preSelectedButton = self.stackView.arrangedSubviews[_colorIndex];
    UIButton *selectedButton = self.stackView.arrangedSubviews[colorIndex];
    void (^handleLayer)(CALayer *layer, CGFloat borderWidth) = ^(CALayer *layer, CGFloat borderWidth){
        layer.cornerRadius = 3.f;
        layer.borderWidth = borderWidth;
        layer.borderColor = [UIColor whiteColor].CGColor;
        layer.masksToBounds = YES;
    };
    
    handleLayer(preSelectedButton.layer, 0);
    handleLayer(selectedButton.layer, 1.f);
    
    _colorIndex = colorIndex;
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
