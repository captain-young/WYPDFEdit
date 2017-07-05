//
//  DigitalSignatureAnnot.m
//  FoxitApp
//
//  Created by Apple on 16/8/23.
//
//

#import "DigitalSignatureAnnot.h"

@implementation DigitalSignatureAnnot

+ (DigitalSignatureAnnot *)createWithDefaultOptionForPageIndex:(int)pageIndex rect:(FSCRT_RECTF)rect
{
    DigitalSignatureAnnot *annot = [[DigitalSignatureAnnot alloc] initWithType:Annot_DigitalSignature];
    annot.NM = [Utility getUUID];
    annot.pageIndex = pageIndex;
    annot.rect = rect;
    annot.author = [AppSettingPreference getAnnotationAuthor];
    annot.color = 0;
    annot.opacity = 100;
    return annot;
}

- (BOOL)isSame:(DigitalSignatureAnnot *)annot
{
    return (self.annotType == annot.annotType
            && self.rect.top == annot.rect.top
            && self.rect.bottom == annot.rect.bottom
            && self.rect.left == annot.rect.left
            && self.rect.right == annot.rect.right
            && [self.author compare:annot.author] == NSOrderedSame
            && [self.NM compare:annot.NM] == NSOrderedSame
            && [self.contents compare:annot.contents] == NSOrderedSame
            && self.color == annot.color
            && self.opacity == annot.opacity
            && self.fontSize == annot.fontSize
            && [self.fontName compare:annot.fontName] == NSOrderedSame);
}


@end
