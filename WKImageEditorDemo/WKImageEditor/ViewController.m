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

@interface ViewController ()

@property (weak, nonatomic) IBOutlet WKImageEditorScrollView *scorllView;
@property (strong, nonatomic) WKImageEditorEditContainer *container;

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
//        c = [WKImageEditorEditContainer imageEditorEditContainerWithImage:[UIImage imageNamed:@"22222"]];
        [self.view addSubview:c];
        
        [c mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        
        c;
    });
    
    self.container = container;
    container.OperateType = WKImageEditOperateTypeCaptureFromContainerView;
    
    container.drawColor = [UIColor redColor];
    
    [self.view sendSubviewToBack:container];
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
}
- (IBAction)clear:(id)sender {
    [self.container clear];
}
- (IBAction)save:(id)sender {
    [self.container resultImage:^(UIImage *image) {
        
    }];
}
@end
