//
//  WKImageEditorScrollView.m
//  WKImageEditor
//
//  Created by 吴珂 on 2018/4/3.
//  Copyright © 2018年 wukong.company. All rights reserved.
//  思路：撤销的时候使用数据源绘制，其他情况下直接在原始图片上进行绘制

#import "WKImageEditorScrollView.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "WKImageEditorDrawTool.h"
#import "WKImageEditorTextView.h"


@interface WKImageEditorOperation : NSObject<SDWebImageOperation>

@property (assign, nonatomic, getter = isCancelled) BOOL cancelled;

@end

@implementation WKImageEditorOperation

- (void)cancel
{
    self.cancelled = YES;
}

@end

@interface WKImageEditorScrollView()
<
UIScrollViewDelegate,
WKImageEditorDrawToolDelegate,
WKImageEditorDrawToolDataSource
>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, copy) NSString *imageUrlString;//原图url
@property (nonatomic, copy) NSString *thumbImageUrlString;//缩略图url
@property (nonatomic, strong) id<SDWebImageOperation> imageOperation;
@property (nonatomic, strong) id<SDWebImageOperation> thumbImageOperation;
@property (nonatomic, assign) BOOL loadedOriginalImage;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, copy) void (^completeBlock)(UIImage *);

//绘制工具
@property (strong, nonatomic) WKImageEditorDrawTool *drawTool;
@property (strong, nonatomic) WKImageEditorTextView *currentInputTextView;

@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;

//绘制属性
@property (strong, nonatomic) NSMutableArray *drawDataSource;
@property (assign, nonatomic) NSInteger operateID;

@end

@implementation WKImageEditorScrollView

{
    CGPoint _prevDraggingPosition;
    CGPoint _startDraggingPosition;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
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

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        [self commonSetup];
//    }
//    return self;
//}

- (void)commonSetup
{
    [self imageView];
    self.maximumZoomScale = 3;
    self.minimumZoomScale = 1;
    self.delegate = self;
    
    [self addTapGesture];
    
    self.operateID = 1;
}

- (void)addTapGesture
{
    UITapGestureRecognizer *doubleTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    doubleTapGes.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapGes];
    
    UITapGestureRecognizer *singleTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    singleTapGes.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTapGes];
    
    
    [singleTapGes requireGestureRecognizerToFail:doubleTapGes];
    
    //draw手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawingViewDidPan:)];
    panGesture.maximumNumberOfTouches = 1;
    
    [self addGestureRecognizer:panGesture];
    self.panGesture = panGesture;
}

#pragma mark - UIScrollViewDelegate
//缩放时调用
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
//    return self.isEditing ? nil : self.imageView;
}

//开始缩放的时候调用
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    scrollView.scrollEnabled = NO;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale
{
    NSLog(@"%@", NSStringFromCGSize(scrollView.contentSize));
    scrollView.scrollEnabled = !self.isEditing;
}

#pragma mark - 缩放与点击
- (void)handleTap:(UITapGestureRecognizer *)ges
{
    CGPoint point =  [ges locationInView:self];
    
    NSInteger touches = ges.numberOfTapsRequired;
    if (touches == 1) {//重新加载
//        if ([self leql_loadFail]) {
//            [self setImageURL:self.imageUrlString thumb:self.thumbImageUrlString completeBlock:self.completeBlock];
//        }
        if (self.isEditing && self.currentInputTextView.isFirstResponder) {//当前在编辑
            if (!CGRectContainsPoint(self.currentInputTextView.frame, point)) {//关闭编辑
                [self endEditing:YES];
                self.currentInputTextView.editable = NO;
                self.currentInputTextView.selectable = NO;
                
                self.currentInputTextView = nil;
            }
        }else if(self.isEditing){
            if (self.drawType == WKImageEditorScrollViewDrawTypeText) {//输入文字
                [self addInputTextView:point];
            }
        }
        
        
    }else if(touches == 2){
        [self zoomWithPoint:point];
    }
}

- (void)zoomWithPoint:(CGPoint)point
{
    if (self.minimumZoomScale <= self.zoomScale && self.maximumZoomScale > self.zoomScale * 2)
    {
        // Zoom in to twice the size
        CGRect zoomRect = [self zoomRectWithTouchPoint:point zoomScale:(self.maximumZoomScale + self.minimumZoomScale) / 2];;
        [self zoomToRect:zoomRect animated:YES];
    }
    else{
        if (self.maximumZoomScale > self.zoomScale && self.maximumZoomScale / 2 <= self.zoomScale)
        {
            [self setZoomScale:self.maximumZoomScale animated:YES];
        }
        else
        {
            [self setZoomScale:self.minimumZoomScale animated:YES];
        }
    }
}


- (CGRect)zoomRectWithTouchPoint:(CGPoint)point zoomScale:(CGFloat)zoomScale
{
    CGFloat newZoomScale = zoomScale;
    CGFloat xsize = self.contentSize.width / newZoomScale;
    CGFloat ysize = self.contentSize.height / newZoomScale;
    CGRect zoomRect = CGRectMake(point.x - xsize/2, point.y - ysize/2, xsize, ysize);
    return zoomRect;
}

#pragma mark - loadImage


- (void)setImageURL:(NSString *)imageUrlString thumb:(NSString *)thumbImageUrlString completeBlock:( void (^__nullable)(UIImage *))completeBlock
{
    [self displayImage];
    //保存
    self.completeBlock = completeBlock;
    self.imageUrlString = imageUrlString;
    self.thumbImageUrlString = self.thumbImageUrlString;
    
//    [self leql_hideLoadImageFail];
    
//    self.loadedOriginalImage = NO;
    self.imageView.image = nil;
    [self.imageOperation cancel];
    [self.thumbImageOperation cancel];
    
    self.maximumZoomScale = 1.f;
    
    NSURL *imageURL = [NSURL URLWithString:imageUrlString];
//    UIImage *image = [[SDImageCache sharedImageCache] imageFromCacheForKey:imageUrlString];
    
//    if (image) {
////        [self completeLoadOriginalImage:image completeBlock:completeBlock];
//    }else{
        self.imageOperation = [self loadImageWithURL:imageURL
                                            progress:^(CGFloat progress) {
                                                
                                            }
                                           completed:^(UIImage *image, NSError *error) {
                                               [self completeLoadOriginalImage:image completeBlock:completeBlock];
                                           }];
//    }
}

- (void)setImage:(UIImage *)image
{
    [self.imageOperation cancel];
    [self.thumbImageOperation cancel];
    
    self.imageView.image = image;
    self.originalImage = image;
    [self displayImage];
}

- (id <SDWebImageOperation>)loadImageWithURL:(NSURL *)url progress:(void(^)(CGFloat progress))progressBlock completed:(void(^)(UIImage *image, NSError *error))completeBlock
{
    return [[SDWebImageManager sharedManager] loadImageWithURL:url
                                                       options:0
                                                      progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                                          CGFloat progress = (CGFloat)receivedSize / expectedSize;
                                                          progressBlock(progress);
                                                          //                                                          [self setWK_ProgressBackgroundColor:kThemeMaskColor];
//                                                          [self setWK_Progress:progress];
                                                      }
                                                     completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                         self.maximumZoomScale = 3;
                                                         if (error) {
//                                                             [self setWK_Progress:1];
//                                                             [self leql_showLoadImageFail];
                                                         }else{
//                                                             [self leql_hideLoadImageFail];
//                                                             self.imageView.image = image;
//                                                             [self displayImage];
                                                             [self setImage:image];
                                                             NSLog(@"%@", imageURL);
                                                         }
                                                         self.maximumZoomScale = 3;
                                                         if (completeBlock) {
                                                             completeBlock(image, error);
                                                         }
                                                         
                                                     }];
}


- (UIImage *)originalImage
{
    if (self.loadedOriginalImage) {
        return _originalImage;
    }
    return nil;
}

- (void)reset
{
    self.imageView.image = self.originalImage;
}

#pragma mark -  from MW
- (void)displayImage
{
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    self.contentSize = CGSizeMake(0, 0);
    
    // Get image from browser as it handles ordering of fetching
    UIImage *img = self.imageView.image;
    if (img) {
        
        // Hide indicator
        
        
        // Set image
        _imageView.image = img;
        _imageView.hidden = NO;
        
        // Setup photo frame
        CGRect photoImageViewFrame;
        photoImageViewFrame.origin = CGPointZero;
        photoImageViewFrame.size = img.size;
        _imageView.frame = photoImageViewFrame;
        self.contentSize = photoImageViewFrame.size;
        
        // Set zoom to minimum zoom
        [self setMaxMinZoomScalesForCurrentBounds];
        
    } else  {
        
    }
    [self setNeedsLayout];
    
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    
    // Bail if no image
    if (_imageView.image == nil) return;
    
    // Reset position
    _imageView.frame = CGRectMake(0, 0, _imageView.frame.size.width, _imageView.frame.size.height);
    
    // Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _imageView.image.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    
    // Calculate Max
    CGFloat maxScale = 3;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Let them go a bit bigger on a bigger screen!
        maxScale = 4;
    }
    
    // Image is smaller than screen so no zooming!
    if (xScale >= 1 && yScale >= 1) {
        minScale = 1.0;
    }
    
    // Set min/max zoom
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    
    // Initial zoom
    self.zoomScale = [self initialZoomScaleWithMinScale];
    
    
    // If we're zooming to fill then centralise
    if (self.zoomScale != minScale) {
        // Centralise
        self.contentOffset = CGPointMake((imageSize.width * self.zoomScale - boundsSize.width) / 2.0,
                                         (imageSize.height * self.zoomScale - boundsSize.height) / 2.0);
        
    }
    
    // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
    self.scrollEnabled = NO;
    
    // If it's a video then disable zooming
    
    
    // Layout
    [self setNeedsLayout];
    
}

- (CGFloat)initialZoomScaleWithMinScale {
    CGFloat zoomScale = self.minimumZoomScale;
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _imageView.image.size;
    CGFloat boundsAR = boundsSize.width / boundsSize.height;
    CGFloat imageAR = imageSize.width / imageSize.height;
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
    if (ABS(boundsAR - imageAR) < 0.17) {
        zoomScale = MAX(xScale, yScale);
        // Ensure we don't zoom in or out too far, just in case
        zoomScale = MIN(MAX(self.minimumZoomScale, zoomScale), self.maximumZoomScale);
    }
    
    return zoomScale;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _imageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    // Center
    if (!CGRectEqualToRect(_imageView.frame, frameToCenter))
        _imageView.frame = frameToCenter;
    
}

#pragma mark - private mehtod
- (void)completeLoadOriginalImage:(UIImage *)image completeBlock:(void (^)(UIImage *))completeBlock
{
    [self setImage:image];
    if (completeBlock) {
        completeBlock(image);
    }
}

#pragma mark - getter & setter
- (UIImageView *)imageView
{
    if (_imageView == nil) {
        _imageView = ({
            UIImageView *iv = [UIImageView new];
            iv = [[UIImageView alloc] initWithFrame:CGRectZero];
            iv.contentMode = UIViewContentModeCenter;
            [self addSubview:iv];
            iv.layer.masksToBounds = NO;
            self.layer.masksToBounds = NO;
            iv;
            
        });
    }
    return _imageView;
}

- (UIColor *)drawColor
{
    if (_drawColor == nil) {
        _drawColor = [UIColor blackColor];
    }
    
    return _drawColor;
}

#pragma mark - Draw Line
- (void)drawingViewDidPan:(UIPanGestureRecognizer*)sender
{
   __block  UIImage *image;

    if(!_isEditing){
        return;
    }

    if (self.drawTool == nil) {
        switch (self.OperateType) {
            case WKImageEditOperateTypeBaseOnOriginalImage:{
                image = self.imageView.image;
            }
                break;
                
            case WKImageEditOperateTypeCaptureFromContainerView:
            default:{
                UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
                [self.layer renderInContext:UIGraphicsGetCurrentContext()];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
                break;
        }
        [self setImage:[self ttt:image]];
        
        self.drawTool = [WKImageEditorDrawTool imageEditorDrawTool:image.size originalImage:image];
        self.drawTool.delegate = self;
        self.drawTool.dataSource = self;
        self.drawTool.drawColor = self.drawColor;
        self.drawTool.OperateType = self.OperateType;
    }
    
    //分别判断点
    CGPoint currentDraggingPosition;
    __block UIView *locationView;
    switch (self.OperateType) {
        case WKImageEditOperateTypeBaseOnOriginalImage:{
            locationView = self.imageView;
        }
            break;
        case WKImageEditOperateTypeCaptureFromContainerView:
        default:{
            locationView = self;
        }
            break;
    }

    currentDraggingPosition = [sender locationInView:locationView];
    if(sender.state == UIGestureRecognizerStateBegan){
        _prevDraggingPosition = currentDraggingPosition;
        _startDraggingPosition = currentDraggingPosition;
        self.operateID++;
        
        //告诉deleate做了一次操作
        if ([self.operateDelegate respondsToSelector:@selector(editOperator:type:)]) {
            [self.operateDelegate editOperator:self type:WKImageEditorEditOperationTypeGraph];
        }
    }
    
    CGPoint from = _prevDraggingPosition;
    CGPoint to = currentDraggingPosition;
    if (self.drawType == WKImageEditorDrawToolDrawTypeLine) {
        from = _startDraggingPosition;
    }
    from = _startDraggingPosition;
    
    BOOL isNeedRemoveLastDrawData = YES;
    BOOL isNeedAddToDrawDataSource = YES;
    if(sender.state != UIGestureRecognizerStateEnded && sender.state != UIGestureRecognizerStateBegan){

        NSMutableDictionary *drawInfo = [NSMutableDictionary dictionaryWithCapacity:3];
        drawInfo[WKImageEditorDrawToolInfoKeyDrawType] = @(self.drawType);
        drawInfo[WKImageEditorDrawToolInfoKeyFromPoint] = [NSValue valueWithCGPoint:from];
        drawInfo[WKImageEditorDrawToolInfoKeyToPoint] = [NSValue valueWithCGPoint:to];
        drawInfo[WKImageEditorDrawToolInfoKeyDrawID] = @(self.operateID);
        drawInfo[WKImageEditorDrawToolInfoKeyDrawColor] = self.drawColor;

        switch (self.drawType) {
            case WKImageEditorScrollViewDrawTypeLine:
            case WKImageEditorScrollViewDrawTypeCircle:
            case WKImageEditorScrollViewDrawTypeRect:{
                
            }
                break;
            case WKImageEditorScrollViewDrawTypeBezier:{
                if ([self isSameOperateWithOperateID]) {//同一次操作取之前的修改bezier path
                    UIBezierPath *bezierPath = [self.drawDataSource lastObject][WKImageEditorDrawToolInfoKeyBezier];
                    [bezierPath addLineToPoint:to];
                    isNeedRemoveLastDrawData = NO;
                    isNeedAddToDrawDataSource = NO;
                }else{
                    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
                    [bezierPath moveToPoint:from];
                    drawInfo[WKImageEditorDrawToolInfoKeyBezier] = bezierPath;
                }
            }
                break;
            default:
                break;
        }
        
        if ([self isSameOperateWithOperateID] && isNeedRemoveLastDrawData) {
            [self.drawDataSource removeLastObject];
        }
    
        if (isNeedAddToDrawDataSource) {
            [self.drawDataSource addObject:drawInfo];
        }
        [self.drawTool redraw];
    }
    _prevDraggingPosition = currentDraggingPosition;
    
}

- (void)addInputTextView:(CGPoint)point
{
    CGRect rect = CGRectMake(point.x, point.y, 100, 100);
    WKImageEditorTextView *textView = [[WKImageEditorTextView alloc] initWithFrame:rect];
    textView.text = @"我就是用力啊测是发斯蒂芬克拉斯锻炼腹肌拉斯科沙发客拉丝机i";
    [self addSubview:textView];
    [textView becomeFirstResponder];
    
    self.currentInputTextView = textView;
}

#pragma mark - 编辑状态控制
- (void)beginEditImage
{
    [self changeEditImageStatus:YES];
}

- (void)endEditImage
{
    [self changeEditImageStatus:NO];
}

- (void)changeEditImageStatus:(BOOL)isEditing
{
    _isEditing = isEditing;
    self.imageView.userInteractionEnabled = isEditing;
    self.scrollEnabled = !isEditing;
    self.panGesture.enabled = isEditing;
}

- (void)rollback
{
    [self.drawDataSource removeLastObject];
    [self.drawTool redraw];
}

- (void)clear
{
    [self.drawDataSource removeAllObjects];
    [self.drawTool redraw];
}
#pragma mark - 编辑功能实现
#pragma mark WKImageEditorDrawToolDataSource
- (NSInteger)numberOfDrawTaskInImageEditorDrawTool:(WKImageEditorDrawTool *)tool
{
    return self.drawDataSource.count;
}

- (NSDictionary *)imageEditorDrawTool:(WKImageEditorDrawTool *)drawTool drawInfoAtIndex:(NSInteger)index
{
    NSDictionary *info = self.drawDataSource[index];
    return info;
}

#pragma mark WKImageEditorDrawToolDelegate
- (void)imageEditorDrawToolDidDrawImage:(WKImageEditorDrawTool *)drawTool drawImage:(UIImage *)drawImage
{
//    [self setImage:drawImage];
    self.imageView.image = drawImage;
}

#pragma mark - getter && setter
- (NSMutableArray *)drawDataSource
{
    if (_drawDataSource == nil) {
        _drawDataSource = [NSMutableArray array];
    }
    return _drawDataSource;
}


#pragma mark - convenience method
- (BOOL)isSameOperateWithOperateID
{
    NSInteger lastOperateID = [([self.drawDataSource lastObject][WKImageEditorDrawToolInfoKeyDrawID]) integerValue];
    return lastOperateID == self.operateID;
}

- (UIImage *)resizeImageSizeToFullScreen:(UIImage *)image
{
    //绘制到中间
    UIGraphicsBeginImageContextWithOptions(self.superview.bounds.size, NO, [UIScreen mainScreen].scale);
    
    CGSize boundsSize = self.superview.bounds.size;
    CGSize imageSize = image.size;
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    
    CGFloat effectScale = MIN(MIN(xScale, yScale), 1);
    CGFloat scaleWidth = boundsSize.width * effectScale;
    CGFloat scaleHeight = boundsSize.height * effectScale;
    
    CGFloat x = floorf((boundsSize.width - scaleWidth) / 2.0);
    CGFloat y = floorf((boundsSize.height - scaleHeight) / 2.0);

    
    [image drawInRect:CGRectMake(x, y, scaleWidth, scaleHeight)];
    UIImage *resizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.originalImage = resizeImage;
    return resizeImage;
}

- (UIImage *)ttt:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    [image drawAtPoint:CGPointZero];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
//    return [resultImage fixOrientation];
    return resultImage;
}

- (UIImage *)croppedImage:(UIImage *)image {
    CGImageRef imageRef = CGImageCreateCopy(image.CGImage);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}
@end
