//
//  WKImageEditorEditContainer.m
//  WKImageEditor
//
//  Created by 吴珂 on 2018/4/11.
//  Copyright © 2018年 wukong.company. All rights reserved.
//

#import "WKImageEditorEditContainer.h"
#import "WKImageEditorScrollView.h"
#import "WKImageEditorInputTextViewContainer.h"
#import <Masonry/Masonry.h>
#import "UIImage+Resize.h"


const NSString static * WKImageEditorOperatorKey = @"WKImageEditorOperatorKey";
const NSString static * WKImageEditorOperateTypeKey = @"WKImageEditorOperateTypeKey";


@interface WKImageEditorEditContainer ()
<
WKImageEditorOperateDelegate
>

@property (strong, nonatomic) WKImageEditorScrollView *scorllView;
@property (strong, nonatomic) WKImageEditorInputTextViewContainer *inputTextViewContainer;

@property (copy, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) NSMutableArray *operations;

@end

@implementation WKImageEditorEditContainer
{
    BOOL _isEditing;
}

+ (instancetype)imageEditorEditContainerWithUrl:(NSString *)url
{
    WKImageEditorEditContainer *container = [[WKImageEditorEditContainer alloc] init];
    container.imageUrl = url;
    [container reload];
    return container;
}
+ (instancetype)imageEditorEditContainerWithImage:(UIImage *)image
{
    WKImageEditorEditContainer *container = [[WKImageEditorEditContainer alloc] init];
    container.image = image;
    [container reload];
    
    return container;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonSetup];
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (void)commonSetup
{
    self.scorllView = ({
        WKImageEditorScrollView *sv = [[WKImageEditorScrollView alloc] init];
        [self addSubview:sv];
        [sv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        sv;
    });
    
    self.scorllView.operateDelegate = self;
    self.scorllView.OperateType = self.OperateType;
    
    self.inputTextViewContainer = ({
        WKImageEditorInputTextViewContainer *c = [[WKImageEditorInputTextViewContainer alloc] init];
        
        c.backgroundColor = [UIColor clearColor];
        [self addSubview:c];
        
        [c mas_makeConstraints:^(MASConstraintMaker *make) {
            switch (self.OperateType) {
                case WKImageEditOperateTypeBaseOnOriginalImage:
                    make.edges.equalTo(self.scorllView.imageView);
                    break;
                case WKImageEditOperateTypeCaptureFromContainerView:
                default:{
                    make.edges.equalTo(self);
                }
                    break;
            }
            
        }];
        
        c;
    });
    self.inputTextViewContainer.operateDelegate = self;
    self.inputTextViewContainer.OperateType = self.OperateType;
    self.operations = [NSMutableArray array];
}

- (void)reload
{
    if (self.imageUrl) {
        [self.scorllView setImageURL:self.imageUrl thumb:self.imageUrl completeBlock:^(UIImage * _Nonnull image) {
            
        }];
    }else if (self.image){
        [self.scorllView setImage:self.image];
    }
}

//- (void)layoutSubviews
//{
//
//}

#pragma mark - 初始化
- (void)beginEditing
{
    switch (self.type) {
        case WKImageEditTypeText:
            [self.inputTextViewContainer beginInputText];
            [self.scorllView endEditImage];
            break;
        case WKImageEditTypeCircle:
        case WKImageEditTypeRect:
        case WKImageEditTypeBezier:
        case WKImageEditTypeLine:
            [self.scorllView beginEditImage];
            self.scorllView.drawType = (WKImageEditorScrollViewDrawType)self.type;
            [self.inputTextViewContainer endInputText];
            break;
            
        default:
            break;
    }
}

- (void)beginEditing:(WKImageEditType)type
{
    self.type = type;
    [self beginEditing];
}

- (void)endEditing
{
    [self.inputTextViewContainer endInputText];
    [self.scorllView endEditImage];
}

- (void)resultImage:(void (^)(UIImage *image))complete
{
    __block UIImage *image;
    [self.scorllView displayImage];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        switch (self.OperateType) {
            case WKImageEditOperateTypeBaseOnOriginalImage:{
                NSLog(@"%@", NSStringFromCGRect(self.scorllView.imageView.frame));
                CGRect snapRect = [self convertRect:self.scorllView.imageView.frame fromView:self.scorllView];
                UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 1);
                [self.layer renderInContext:UIGraphicsGetCurrentContext()];
                image = UIGraphicsGetImageFromCurrentImageContext();
                
                complete([image croppedImage:snapRect]);
                
                UIGraphicsEndImageContext();
                
                
                
            }
                break;
            case WKImageEditOperateTypeCaptureFromContainerView:
            default:{
                UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 1);
                [self.layer renderInContext:UIGraphicsGetCurrentContext()];
                image = UIGraphicsGetImageFromCurrentImageContext();
                
                UIGraphicsEndImageContext();
                
                
                if (complete) {
                    complete(image);
                }
                
            }
                break;
        }
    });
}

- (UIImage *)croppedImage:(CGRect)bounds image:(UIImage *)image {
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

#pragma mark - WKImageEditorOperateDelegate
- (void)editOperator:(id<WKImageEditorOperatorProtocol>)editOperator type:(WKImageEditorEditOperationType)type
{
    NSDictionary *operateInfo = @{
                                 WKImageEditorOperatorKey : editOperator,
                                 WKImageEditorOperateTypeKey : @(type)
                                 };
    [self.operations addObject:operateInfo];
}

#pragma mark - WKImageEditorOperatorProtocol
- (void)rollback
{
    NSDictionary *operateInfo = [self.operations lastObject];
    id<WKImageEditorOperatorProtocol> operator = operateInfo[WKImageEditorOperatorKey];
//    WKImageEditorEditOperationType operationType = [operateInfo[WKImageEditorOperateTypeKey] integerValue];
    [operator rollback];
    
    [self.operations removeLastObject];
    
}
- (void)clear
{
    [self.operations enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull operateInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        id<WKImageEditorOperatorProtocol> operator = operateInfo[WKImageEditorOperatorKey];
//        WKImageEditorEditOperationType operationType = [operateInfo[WKImageEditorOperateTypeKey] integerValue];
        [operator clear];
    }];
    
    [self.operations removeAllObjects];
}

#pragma mark - getter && setter
- (void)setOperateType:(WKImageEditorOperateType)OperateType
{
    _OperateType = OperateType;
    self.scorllView.OperateType = OperateType;
    self.inputTextViewContainer.OperateType = OperateType;
}

- (void)setDrawColor:(UIColor *)drawColor
{
    _drawColor = drawColor;
    self.scorllView.drawColor = drawColor;
    self.inputTextViewContainer.drawColor = drawColor;
}
@end
