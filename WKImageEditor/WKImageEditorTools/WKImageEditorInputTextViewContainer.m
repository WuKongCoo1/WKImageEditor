//
//  WKImageEditorInputTextViewContainer.m
//  WKImageEditor
//
//  Created by 吴珂 on 2018/4/8.
//  Copyright © 2018年 wukong.company. All rights reserved.
//

#import "WKImageEditorInputTextViewContainer.h"
#import "WKImageEditorTextView.h"
#import <Masonry/Masonry.h>

@interface WKImageEditorInputTextViewContainer()
<
UITextViewDelegate
>

@end

@implementation WKImageEditorInputTextViewContainer
{
    WKImageEditorTextView *_currentEditTextView;
    WKImageEditorTextView *_currentMoveTextView;
    NSMutableArray *_inputTextViews;
    BOOL _isEditing;
}


- (instancetype)init
{
    self = [super init];
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
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    
    _inputTextViews = [NSMutableArray array];
}

- (void)pan:(UIPanGestureRecognizer *)sender
{
    
    CGPoint point = [sender translationInView:self];
    CGPoint locationPoint = [sender locationInView:self];
    
    static CGPoint latestPoint;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        latestPoint = CGPointZero;
        [_inputTextViews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(WKImageEditorTextView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (CGRectContainsPoint(obj.frame, locationPoint)) {
                *stop = YES;
                _currentMoveTextView = obj;
                
                self.layer.masksToBounds = NO;
            }
        }];
    }
    
    if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateFailed) {
        _currentMoveTextView = nil;
        self.layer.masksToBounds = YES;
        return;
    }
    
    if (_currentMoveTextView) {
        //每次都多加了
        CGFloat targetX = _currentMoveTextView.frame.origin.x + (point.x - latestPoint.x);
        CGFloat targetY = _currentMoveTextView.frame.origin.y + (point.y - latestPoint.y);
        
        _currentMoveTextView.frame = CGRectMake(targetX >=0 ? targetX : 0, targetY >= 0 ? targetY :0, 100, 100);
        
        [self adjustLayoutWithTextView:_currentMoveTextView];
    }
    
    latestPoint = point;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if (_currentEditTextView.isFirstResponder) {//不做反应
        if (!CGRectContainsPoint(_currentEditTextView.frame, point)) {//停止输入
            [_currentEditTextView resignFirstResponder];
            _currentEditTextView.selectable = NO;
            _currentEditTextView.editable = NO;
            
            self.layer.masksToBounds = YES;
        }
    }else{
        CGRect rect = CGRectMake(point.x, point.y, 100, 100);
        WKImageEditorTextView *textView = [[WKImageEditorTextView alloc] initWithFrame:rect];
        textView.text = @"";
        [self addSubview:textView];
        [textView becomeFirstResponder];
        textView.delegate = self;
        textView.scrollEnabled = NO;
        textView.backgroundColor = [UIColor clearColor];

        [self adjustLayoutWithTextView:textView];
        [_inputTextViews addObject:textView];
        _currentEditTextView = textView;
        
        //告诉deleate做了一次操作
        if ([self.operateDelegate respondsToSelector:@selector(editOperator:type:)]) {
            [self.operateDelegate editOperator:self type:WKImageEditorEditOperationTypeText];
        }
        
        self.layer.masksToBounds = NO;
    }
    
    
}

- (void)beginInputText
{
    _isEditing = YES;
}

- (void)endInputText
{
    _isEditing = NO;
    [_currentEditTextView resignFirstResponder];
}



#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _currentEditTextView = (WKImageEditorTextView *)textView;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self adjustLayoutWithTextView:_currentEditTextView];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
//    _currentEditTextView = nil;
}

- (void)adjustLayoutWithTextView:(UITextView *)textView
{
    CGFloat maxWidth = self.bounds.size.width - textView.frame.origin.x;
    CGFloat maxHeight = self.bounds.size.height - textView.frame.origin.y;
    
    CGSize maxSize = [textView sizeThatFits:CGSizeMake(maxWidth, maxHeight)];
    
    [textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(textView.frame.origin.y).priority(MASLayoutPriorityDefaultMedium);
        make.left.equalTo(self).offset(textView.frame.origin.x).priority(MASLayoutPriorityDefaultMedium);
        make.size.mas_equalTo(maxSize);
    }];
}
#pragma mark - 事件响应
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (_isEditing) {
        return [super hitTest:point withEvent:event];
    }
    return nil;
}


- (void)rollback
{
    [_inputTextViews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
        *stop = YES;
    }];
    [_inputTextViews removeLastObject];
}

- (void)clear
{
    [_inputTextViews enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(UIView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [obj removeFromSuperview];
        });
    }];
    
    [_inputTextViews removeAllObjects];
}
@end
