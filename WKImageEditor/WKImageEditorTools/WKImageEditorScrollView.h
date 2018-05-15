//
//  WKImageEditorScrollView.h
//  WKImageEditor
//
//  Created by 吴珂 on 2018/4/3.
//  Copyright © 2018年 wukong.company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKImageEditor.h"
#import "WKImageEditorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

//@class WKImageEditorScrollView;
//@protocol WKImageEditorScrollViewDelegate <NSObject>
//
//- (void)takeNotesScrollView:(WKImageEditorScrollView *)scrollView didEndEditImage:(UIImage *)image;
//
//@end

@interface WKImageEditorScrollView : UIScrollView
<
WKImageEditorOperatorProtocol
>

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (weak, nonatomic) id<WKImageEditorOperateDelegate> operateDelegate;//用于通知别人做了一次编辑操作
@property (nonatomic, assign, readonly) BOOL isEditing;//是否处于编辑状态
@property (assign, nonatomic) WKImageEditorScrollViewDrawType drawType;//绘制类型
@property (assign, nonatomic) WKImageEditorOperateType OperateType;//操作类型，用于指定编辑结果是基于图片还是视图直接截图
@property (copy, nonatomic) UIColor *drawColor;//绘制颜色
@property (assign, nonatomic) CGFloat lineWidth;//绘制线条宽度

- (void)setImageURL:(NSString *)imageUrlString thumb:(NSString *)thumbImageUrlString completeBlock:(void(^ _Nullable )(UIImage *))completeBlock;
- (void)setImage:(UIImage *)image;
- (UIImage *)originalImage;
- (void)reset;
- (void)displayImage;

#pragma mark - 编辑
- (void)beginEditImage;//开始编辑图片
- (void)endEditImage;
- (void)rollback;

@end
NS_ASSUME_NONNULL_END
