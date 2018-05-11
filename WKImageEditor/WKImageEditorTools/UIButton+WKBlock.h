//
//  UIButton+WKBlock.h
//  iOS-Categories (https://github.com/shaojiankui/iOS-Categories)
//
//  Created by Jakey on 14/12/30.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^WKTouchedBlock)(NSInteger tag);

@interface UIButton (WKBlock)
-(void)wk_addActionHandler:(WKTouchedBlock)touchHandler;
@end
