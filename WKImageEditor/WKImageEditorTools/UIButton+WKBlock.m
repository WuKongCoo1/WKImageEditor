//
//  UIButton+WKBlock.m
//  iOS-Categories (https://github.com/shaojiankui/iOS-Categories)
//
//  Created by Jakey on 14/12/30.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import "UIButton+WKBlock.h"
#import <objc/runtime.h>
static const void *WKUIButtonBlockKey = &WKUIButtonBlockKey;

@implementation UIButton (WKBlock)
-(void)wk_addActionHandler:(WKTouchedBlock)touchHandler{
    objc_setAssociatedObject(self, WKUIButtonBlockKey, touchHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(wk_actionTouched:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)wk_actionTouched:(UIButton *)btn{
    WKTouchedBlock block = objc_getAssociatedObject(self, WKUIButtonBlockKey);
    if (block) {
        block(btn.tag);
    }
}
@end

