//
//  WKImageEditorChooseTextSizeView.h
//  WKImageEditor
//
//  Created by 吴珂 on 2018/5/11.
//  Copyright © 2018年 wukong.company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WKImageEditorChooseTextSizeView : UIView
@property (copy, nonatomic) void (^didChooseFontSize)(CGFloat fontSize);
@property (assign, nonatomic) NSInteger fontSizeIndex;
@end
