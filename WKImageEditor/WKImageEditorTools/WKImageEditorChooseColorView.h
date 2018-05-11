//
//  WKImageEditorChooseColorView.h
//  WKImageEditor
//
//  Created by 吴珂 on 2018/5/10.
//  Copyright © 2018年 wukong.company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WKImageEditorChooseColorView : UIView

@property (copy, nonatomic) void (^didChooseColor)(UIColor *color);
@property (assign, nonatomic) NSInteger colorIndex;

@end
