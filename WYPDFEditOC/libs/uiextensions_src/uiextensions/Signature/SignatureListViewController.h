/**
 * Copyright (C) 2003-2017, Foxit Software Inc..
 * All Rights Reserved.
 *
 * http://www.foxitsoftware.com
 *
 * The following code is copyrighted and is the proprietary of Foxit Software Inc.. It is not allowed to
 * distribute any parts of Foxit Mobile PDF SDK to third party or public without permission unless an agreement
 * is signed between Foxit Software Inc. and customers to explicitly grant customers permissions.
 * Review legal.txt for additional license and legal information.
 */

#import <UIKit/UIKit.h>
#import <FoxitRDK/FSPDFViewControl.h>

@class AnnotationSignature;

typedef void (^OpenSignatureViewHandler)(AnnotationSignature* sig);
typedef void (^SelectSignatureHandler)();
typedef void(^DeleteSignatureHandler)(AnnotationSignature* sig);
typedef void (^CancelSignatureHandler)();

@interface SignatureListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *signatureArray;
@property (nonatomic, strong) NSMutableDictionary *selectDict;
@property (nonatomic, strong) NSMutableDictionary *refreshDict;
@property (nonatomic, strong) NSString *currentName;

@property (copy, nonatomic) OpenSignatureViewHandler openSignatureViewHandler;
@property (copy, nonatomic) SelectSignatureHandler selectSignatureHandler;
@property (copy, nonatomic) DeleteSignatureHandler deleteSignatureHandler;
@property (copy, nonatomic) CancelSignatureHandler cancelSignatureHandler;

@property (nonatomic, assign) BOOL isFieldSigList;
@end
