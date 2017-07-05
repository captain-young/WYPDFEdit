//
//  WYPDFManager.h
//  PDF3
//
//  Created by 杨新威 on 2017/5/28.
//  Copyright © 2017年 White-Young. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FoxitRDK/FSPDFObjC.h>
#import "FoxitRDK/FSPDFViewControl.h"
#import "../../../libs/uiextensions_src/uiextensions/UIExtensionsManager.h"

typedef NS_ENUM(NSInteger, WYPDFAnnotType){
    WYPDFAnnotTypeSelect,
    WYPDFAnnotTypeNote,         // 文字标注
    WYPDFAnnotTypeMarkup,       // 添加高亮标记
    WYPDFAnnotTypeShape,        // 添加形状选框
    WYPDFAnnotTypeFreetext,     // 添加自由文本
    WYPDFAnnotTypePencil,       // 画笔涂鸦
    WYPDFAnnotTypeEraser,       // 橡皮擦
    WYPDFAnnotTypeLine,         // 直线
    WYPDFAnnotTypeStamp,        // 图章
    WYPDFAnnotTypeInsert,       // 插入文字
    WYPDFAnnotTypeReplce,       // 替换
    WYPDFAnnotTypeAttachment,   // 附件
    WYPDFAnnotTypeSignature,    // 签名
    WYPDFAnnotTypeSearch        // 全文搜索
};

@interface WYPDFManager : NSObject


/**
 set pdfView frame
 */
@property (nonatomic, assign) CGRect pdfDocFrame;

+ (instancetype)defalutManager;

/**
 unlock Foxit MobilePDF SDK using a license before calling any APIs.
 */
+ (BOOL)applyTheLicenseKey;


/**
 打开文档
 @param filePath 文档路径
 */
- (void)openPDFDocWithFilePath:(NSString *)filePath showInView:(UIView *)view;


/**
 添加文档编辑功能
 */
- (void)addAnnotToolHandle:(WYPDFAnnotType)annotType;


/**
 取消编辑功能返回预览模式
 */
- (void)cancalAnnot;


/**
 保存修改后的文档
 */
- (BOOL)savePDFDocWithFilePath:(NSString *)filePath;

@end
