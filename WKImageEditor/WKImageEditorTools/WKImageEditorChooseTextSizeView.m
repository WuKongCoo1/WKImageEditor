//
//  WKImageEditorChooseTextSizeView.m
//  WKImageEditor
//
//  Created by 吴珂 on 2018/5/11.
//  Copyright © 2018年 wukong.company. All rights reserved.
//

#import "WKImageEditorChooseTextSizeView.h"
#import <OAStackView/OAStackView.h>
#import <Masonry/Masonry.h>
#import "UIButton+WKBlock.h"
#import "UIImage+WKColor.h"
@interface WKImageEditorChooseTextSizeView()

@property (nonatomic, strong) OAStackView *stackView;

@end

@implementation WKImageEditorChooseTextSizeView

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
    self.backgroundColor = [self colorWithRed:219 green:219 blue:219];
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
            make.width.equalTo(self);
            make.height.equalTo(self);
            make.center.equalTo(self);
        }];
        
        self.stackView = ({
            OAStackView *sv = [[OAStackView alloc] init];
            sv.alignment = OAStackViewAlignmentFill;
            sv.distribution = OAStackViewDistributionFillEqually;
            sv.spacing = 0.f;
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
    NSArray *fontSizes = @[@14, @18, @22, @26, @30, @34, @38, @42, @46, @60];
    
    UIColor *normalBackgroundColor = [self colorWithRed:219 green:219 blue:219];
    UIColor *highlightedOrSelectedBackgroundColor = [self colorWithRed:188 green:188 blue:188];
    UIImage *normalImage = [UIImage wk_imageWithColor:normalBackgroundColor size:CGSizeMake(100, 100)];
    UIImage *selectedOrHighlightedImage = [UIImage wk_imageWithColor:highlightedOrSelectedBackgroundColor size:CGSizeMake(100, 100)];
    [fontSizes enumerateObjectsUsingBlock:^(NSNumber *  _Nonnull fontSize, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button  = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.stackView addArrangedSubview:button];
        [button setTitle:[NSString stringWithFormat:@"%@", fontSize] forState:UIControlStateNormal];
        [button setBackgroundImage:normalImage forState:UIControlStateNormal];
        [button setBackgroundImage:selectedOrHighlightedImage forState:UIControlStateSelected];
        [button setBackgroundImage:selectedOrHighlightedImage forState:UIControlStateHighlighted];
        __weak typeof(self)weakSelf = self;
        [button wk_addActionHandler:^(NSInteger tag) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.didChooseFontSize) {
                strongSelf.didChooseFontSize([fontSize integerValue]);
                strongSelf.fontSizeIndex = idx;
            }
        }];
    }];
    
    //初始化当前选中颜色
    self.fontSizeIndex = 0;
}

- (void)setFontSizeIndex:(NSInteger)fontSizeIndex
{
    if (fontSizeIndex >= self.stackView.arrangedSubviews.count) {
        return;
    }
    UIButton *preSelectedButton = self.stackView.arrangedSubviews[_fontSizeIndex];
    UIButton *selectedButton = self.stackView.arrangedSubviews[fontSizeIndex];
    preSelectedButton.selected = NO;
    selectedButton.selected = YES;
    
    _fontSizeIndex = fontSizeIndex;
}

- (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
}

@end
