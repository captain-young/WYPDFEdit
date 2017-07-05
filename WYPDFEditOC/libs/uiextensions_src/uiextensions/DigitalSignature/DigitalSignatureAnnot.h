//
//  DigitalSignatureAnnot.h
//  FoxitApp
//
//  Created by Apple on 16/8/23.
//
//

#import <Foundation/Foundation.h>
#import <FoxitRDK/FSPDFObjC.h>

@interface DigitalSignatureAnnot : DmAnnot
+ (DigitalSignatureAnnot *)createWithDefaultOptionForPageIndex:(int)pageIndex rect:(FSRectF*)rect;
@end
