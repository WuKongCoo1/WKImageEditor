//
//  WKImageEditorTextView.m
//  WKImageEditor
//
//  Created by 吴珂 on 2018/4/8.
//  Copyright © 2018年 wukong.company. All rights reserved.
//

#import "WKImageEditorTextView.h"
#import <Masonry/Masonry.h>

@implementation WKImageEditorTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonSetup];
    }
    return self;
}

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
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
//    [self addGestureRecognizer:pan];
}

//- (void)pan:(UIPanGestureRecognizer *)sender
//{
//    CGPoint point = [sender translationInView:self];
//
//    CGFloat targetX = self.frame.origin.x + point.x;
//    CGFloat targetY = self.frame.origin.y + point.y;
//
//    UIView *superView = self.superview;
//    [self removeFromSuperview];
//
//    [superView addSubview:self];
//
//    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.superview).offset(targetY);
//        make.left.equalTo(self.superview).offset(targetX);
//        make.right.equalTo(self.superview);
//        make.height.greaterThanOrEqualTo(@50);
//    }];
//}

@end
