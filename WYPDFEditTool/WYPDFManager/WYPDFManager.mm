//
//  WYPDFManager.m
//  PDF3
//
//  Created by 杨新威 on 2017/5/28.
//  Copyright © 2017年 White-Young. All rights reserved.
//

#import "WYPDFManager.h"

@interface WYPDFManager()

@property (nonatomic, strong) NSArray *toolHandleArr;

@end

static WYPDFManager *_pdfManager;

static UIExtensionsManager *_extensionsManager;

static FSPDFViewCtrl *_pdfViewCtrl;

@implementation WYPDFManager

+ (instancetype)defalutManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pdfManager = [[WYPDFManager alloc] init];
    });
    return _pdfManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pdfManager = [super allocWithZone:zone];
    });
    return _pdfManager;
}

- (id)copy{
    return [_pdfManager copy];
}

- (instancetype)init{
    if (self = [super init]) {
        _toolHandleArr = @[Tool_Select,Tool_Note,Tool_Markup,Tool_Shape,Tool_Freetext,Tool_Pencil,Tool_Eraser,Tool_Line,Tool_Stamp,Tool_Insert,Tool_Replace,Tool_Attachment,Tool_Signature];
        
        _pdfViewCtrl = [[FSPDFViewCtrl alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        
        // Initialize a UIExtensionsManager object and set it to _pdfViewCtrl
        _extensionsManager = [[UIExtensionsManager alloc] initWithPDFViewControl:_pdfViewCtrl];
        _pdfViewCtrl.extensionsManager = _extensionsManager;
        
    }
    return self;
}

+ (BOOL)applyTheLicenseKey{
    
    NSString *sn = @"PY9e8y9xl0ZTlA9vjTZ60JyunwiawCW33N980Rxv41meTr0t7NcB0Q==";
   
    NSString *key = @"ezKXjl3GvG5z9JsXIVWofHV+ZehNuFa2h+1wcVyZN+fWppNxib3Fx/cHiPtMXxdqfiiQUw0XE1kg/58xwEt0VSJqR+dh76vN7h068CTe99ohD6LDXTuFaF0S0uVSaZDfDTmllthT0nF5T1XC+vcJCA7TI4qr/ZKv7P3z824/3khSRjK/IEYJc9RpJLA2/aTALnBR9F+YBq36ygPZANpoMoS8hTGRdtnpSC/5sVegsiUVpp1B7WR9yMdLG6Roi3sJM2DawatcKFGd9kJ1ejM3qMXLLMuVjQA8Px3Tx+DtyKVZs8fkEzvYaQjjbnc7+fR2gSvvxN4ddYwieAgVql1QI1CNU/tT7xet5FcB83VXvftaInuSXzFcA13Bkz8tTdUl/SpBOf0R7y4zRvLUb+h8O5SyYjoShoBf/Kc/RAG3WzRHGd0GZ1TZkBHV/rGxvmfAH1v60sexYLTf2H9uZyN6Iv5SNrWL+ByGOlyWZilo/qtpnBfD0Tc3T5cw7dBZ794C37+1/8r8xLQUvv8rYUwL/YS+1vp2JFyzPWzoZ4ZXR6nq3gtdaew0r+zD7yPUUDAuhqJ5ryGZWcFTvpzgC/vdWZk9NQRUfbxMLHEz7p4GTGYKFcUnsGB5HyxpX0mEXSeWSBhUfwMy3GCPX+hr0ohBgzs1T6azrtrIt5H02Yq75CazobTbj1KoRrRwFFPAoKUDMX757rbVC75vlHRjdAP7uv7BKSI1UmPBUL8LIWW1MBIoqxCbh7EgJdtvQ4+7pCfRKLZ65FVBRvKp/aL5gHgeDni2TQAyG3PRw9GAAkwIwmGDu4KJnRM4lhe5uiM5mXD3cVa+s0ZLahgAn0Z8jPIwmauLdMjDf5kpo/Mkrn8uDRDYkUf5ozhHJlXltXJfMjDkr1i5/6VKE67/RC5ON9lb5SsYzegpKrADz/HhXPUlJjU8Ks3YEDc8+TTwEfA6XFK40p+U6W0641T/gt5Rms2ppdxXrSGs2qhtGcPK0Rzrw01XJeYNMlAaWAmnG8KrGLU0ItO/KgibOq/ftCECM+YxrqsJ/jGAE4Gu47jDxiest1ges94updB6BmnL3glq325BMKCVrX4/Jxe7sZln0ZSW34oOJvmZoDi9Os+0bYHHET0j/xxExoR4DUTke/rHNFKHqidaeAIGYYV2b7OomNVFuSQlJL0AZKRn6uB2YVtrGFbU7ocIxlPc6hgrACjfyk7BtAU4";
    
    enum FS_ERRORCODE eRet = [FSLibrary init:sn key:key];
    if (e_errSuccess != eRet) {
        return NO;
    }
    
    return YES;
}

- (void)openPDFDocWithFilePath:(NSString *)filePath showInView:(UIView *)view{
    FSPDFDoc* pdfdoc = [FSPDFDoc createFromFilePath:filePath];
    if(e_errSuccess != [pdfdoc load:nil]) {
        return;
    }
    _pdfViewCtrl.frame = view.frame;
    [_pdfViewCtrl setDoc:pdfdoc];
    [view addSubview:_pdfViewCtrl];
}

- (void)setPdfDocFrame:(CGRect)pdfDocFrame{
    _pdfDocFrame = pdfDocFrame;
    _pdfViewCtrl.frame = pdfDocFrame;
}

- (void)addAnnotToolHandle:(WYPDFAnnotType)annotType{
    
    if (annotType == WYPDFAnnotTypeSearch) {
        
        if (_extensionsManager.currentAnnot) {
            [_extensionsManager setCurrentAnnot:nil];
        }
        [_extensionsManager showSearchBar:YES];
        
        return;
    }
    
    id<IToolHandler> toolHandler = [_extensionsManager getToolHandlerByName:_toolHandleArr[annotType]];
    [_extensionsManager setCurrentToolHandler:toolHandler];
    
}

- (void)cancalAnnot{
    [_extensionsManager setCurrentToolHandler:nil];
    if (_extensionsManager.currentAnnot) {
        [_extensionsManager setCurrentAnnot:nil];
    }
}

- (BOOL)savePDFDocWithFilePath:(NSString *)filePath{
    if(filePath)
    {
        NSFileManager * fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:filePath])
        {
            [fileManager removeItemAtPath:filePath error:nil];
        }
        BOOL result = [_pdfViewCtrl saveDoc:filePath flag:e_saveFlagIncremental];
        
        return result;
    }
    return NO;
}




@end
