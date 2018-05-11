//
//  ViewController.m
//  WKImageEditor
//
//  Created by 吴珂 on 2018/4/3.
//  Copyright © 2018年 wukong.company. All rights reserved.
//

#import "ViewController.h"
#import "WKImageEditorScrollView.h"
#import "WKImageEditorTextView.h"
#import "WKImageEditorInputTextViewContainer.h"
#import <Masonry/Masonry.h>
#import "WKImageEditorEditContainer.h"
#import "WKImageEditorToolBar.h"
#import "WKImageEditorChooseColorView.h"
#import "WKImageEditorChooseTextSizeView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet WKImageEditorScrollView *scorllView;
@property (strong, nonatomic) WKImageEditorEditContainer *container;
@property (strong, nonatomic) WKImageEditorChooseColorView *chooseColorView;
@property (strong, nonatomic) WKImageEditorToolBar *toolBar;
@property (strong, nonatomic) WKImageEditorChooseTextSizeView *chooseTextSizeView;

- (IBAction)drawLine:(id)sender;
- (IBAction)drawBezier:(id)sender;
- (IBAction)drawRect:(id)sender;
- (IBAction)drawCircle:(id)sender;
- (IBAction)Backspace:(id)sender;
- (IBAction)addText:(id)sender;
- (IBAction)endEditImage:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSString *url = @"http://xxyx-test.oss-cn-qingdao.aliyuncs.com///answercard/6786d07bc00e4c5d92523dc2b6c05c5b.jpg";
//    __weak typeof(self)weakSelf = self;
//    [self.scorllView setImageURL:url thumb:url completeBlock:^(UIImage * _Nonnull image) {
//        [weakSelf.scorllView setImage:image];
//    }];
//
//    [self.scorllView beginEditImage];
//    self.scorllView.drawType = WKImageEditorScrollViewDrawTypeBezier;
//    self.scorllView.drawColor = [UIColor redColor];
//
//
//    WKImageEditorInputTextViewContainer *container = ({
//        WKImageEditorInputTextViewContainer *c = [[WKImageEditorInputTextViewContainer alloc] init];
//
//        [self.view addSubview:c];
//
//        [c mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.view);
//        }];
//
//        c;
//    });
//
//    container.backgroundColor = [UIColor clearColor];
//    [container beginInputText];
    
    [self.scorllView removeFromSuperview];
    
    
    WKImageEditorEditContainer *container = ({
        WKImageEditorEditContainer *c = [WKImageEditorEditContainer imageEditorEditContainerWithUrl:@"http://xxyx-test.oss-cn-qingdao.aliyuncs.com///answercard/6786d07bc00e4c5d92523dc2b6c05c5b.jpg"];
        [self.view addSubview:c];
        [c mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        c;
    });
    
    
    self.container = container;
    container.OperateType = WKImageEditOperateTypeBaseOnOriginalImage;
    
    container.drawColor = [UIColor purpleColor];
    container.drawFont = [UIFont systemFontOfSize:14.f];
    
    [self.view sendSubviewToBack:container];
    
    //工具栏
    WKImageEditorToolBar *toolBar = [WKImageEditorToolBar imageEditorToolBar];
    __weak typeof(self)weakSelf = self;
    toolBar.operateBlock = ^(WKImageEditorToolBarOperateType type) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        switch (type) {
            //绘制
            case WKImageEditorToolBarOperateTypeDrawLine:
                [strongSelf.container beginEditing:WKImageEditTypeLine];
                break;
            case WKImageEditorToolBarOperateTypeDrawRect:
                [strongSelf.container beginEditing:WKImageEditTypeRect];
                break;
            case WKImageEditorToolBarOperateTypeDrawText:
                [strongSelf.container beginEditing:WKImageEditTypeText];
                break;
            case WKImageEditorToolBarOperateTypeDrawBezier:
                [strongSelf.container beginEditing:WKImageEditTypeBezier];
                break;
            case WKImageEditorToolBarOperateTypeDrawCircle:
                [strongSelf.container beginEditing:WKImageEditTypeCircle];
                break;
            case WKImageEditorToolBarOperateTypeBackspace:
                [strongSelf.container rollback];
                break;
            case WKImageEditorToolBarOperateTypeSave:
                [strongSelf.container  resultImage:^(UIImage *image) {
                    
                }];
                break;
            case WKImageEditorToolBarOperateTypeClear:
                [strongSelf.container clear];
                break;
                //功能性
            case WKImageEditorToolBarOperateTypeChooseColor:
                strongSelf.chooseColorView.hidden = !strongSelf.chooseColorView.hidden;
                break;
            case WKImageEditorToolBarOperateTypePackUp:
                
                break;
            case WKImageEditorToolBarOperateTypeUnpack:
                
                break;
            
            case WKImageEditorToolBarOperateTypeChooseTextSize:
                strongSelf.chooseTextSizeView.hidden = !strongSelf.chooseTextSizeView.hidden;
                break;
                
            default:
                break;
        }
    };
    
    [self.view addSubview:toolBar];
    [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.height.equalTo(@50);
        make.left.right.equalTo(self.view);
    }];

    [toolBar setFontSize:14.f];
    
    self.toolBar = toolBar;

    //选择颜色
    WKImageEditorChooseColorView *colorView = [[WKImageEditorChooseColorView alloc] initWithFrame:CGRectZero];
    [self.view addSubview: colorView];
    [colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@40);
        make.top.equalTo(self.view);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@400.f);
    }];
    
    colorView.didChooseColor = ^(UIColor *color) {
      __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.container setDrawColor:color];
        [strongSelf.toolBar setDrawColor:color];
    };
    
    colorView.hidden = YES;
    self.chooseColorView = colorView;
    
    //选择字体大小
    WKImageEditorChooseTextSizeView *chooseTextSizeView = [[WKImageEditorChooseTextSizeView alloc] initWithFrame:CGRectZero];
    [self.view addSubview: chooseTextSizeView];
    
    [chooseTextSizeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@300.f);
        make.top.equalTo(colorView.mas_bottom).offset(5.f);
        make.left.equalTo(colorView);
        make.height.equalTo(@30);
    }];
    
    chooseTextSizeView.didChooseFontSize = ^(CGFloat fontSize) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.container setDrawFont:[UIFont systemFontOfSize:fontSize]];
        [strongSelf.toolBar setFontSize:fontSize];
    };
    
    chooseTextSizeView.hidden = YES;
    
    self.chooseTextSizeView = chooseTextSizeView;
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)drawLine:(id)sender {
//    self.scorllView.drawType = WKImageEditorScrollViewDrawTypeLine;
    [self.container beginEditing:WKImageEditTypeLine];
}

- (IBAction)drawBezier:(id)sender {
//    self.scorllView.drawType = WKImageEditorScrollViewDrawTypeBezier;
    [self.container beginEditing:WKImageEditTypeBezier];
}

- (IBAction)drawRect:(id)sender {
//    self.scorllView.drawType = WKImageEditorScrollViewDrawTypeRect;
    [self.container beginEditing:WKImageEditTypeRect];
}

- (IBAction)drawCircle:(id)sender {
//    self.scorllView.drawType = WKImageEditorScrollViewDrawTypeCircle;
    [self.container beginEditing:WKImageEditTypeCircle];
}

- (IBAction)Backspace:(id)sender {
    [self.scorllView rollback];
    [self.container rollback];
}

- (IBAction)addText:(id)sender {
//    self.scorllView.drawType = WKImageEditorScrollViewDrawTypeText;
    [self.container beginEditing:WKImageEditTypeText];
}

- (IBAction)endEditImage:(id)sender {
    [self.container endEditing];
    self.container.drawFont = [UIFont systemFontOfSize:(self.container.drawFont.pointSize + 5)];
}
- (IBAction)clear:(id)sender {
    [self.container clear];
}
- (IBAction)save:(id)sender {
    [self.container resultImage:^(UIImage *image) {
        
    }];
}
@end
