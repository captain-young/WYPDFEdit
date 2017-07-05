//
//  WYPDFViewController.m
//  WYPDFEditOC
//
//  Created by Apple on 2017/7/5.
//  Copyright © 2017年 White-Young. All rights reserved.
//

#import "WYPDFViewController.h"
#import "WYPDFManager.h"
@interface WYPDFViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation WYPDFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"批注";
    
    // 打开PDF文档
    [[WYPDFManager defalutManager] openPDFDocWithFilePath:self.pdfPath showInView:self.contentView];
    // 设置Frame
    [WYPDFManager defalutManager].pdfDocFrame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 49 - 64);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveClick)];
    
}

/****************** 保存 ******************/
- (void)saveClick{
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"123.pdf"];
    [[WYPDFManager defalutManager] savePDFDocWithFilePath:filePath];
}

/****************** 画笔涂鸦 ******************/
- (IBAction)pencilClick:(UIButton *)sender {
    [[WYPDFManager defalutManager] addAnnotToolHandle:WYPDFAnnotTypePencil];
    
}

/****************** 添加文字 ******************/
- (IBAction)wordClick:(UIButton *)sender {
    [[WYPDFManager defalutManager] addAnnotToolHandle:WYPDFAnnotTypeFreetext];
}

/****************** 全文搜索 ******************/
- (IBAction)searchClick:(UIButton *)sender {
     [[WYPDFManager defalutManager] addAnnotToolHandle:WYPDFAnnotTypeSearch];
}

/****************** 取消编辑动作 ******************/
- (IBAction)completClick:(UIButton *)sender {
    [[WYPDFManager defalutManager] cancalAnnot];
}


@end
