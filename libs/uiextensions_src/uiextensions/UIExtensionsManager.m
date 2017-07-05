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

#import <Foundation/Foundation.h>
#import "UIExtensionsManager.h"
#import "UIExtensionsManager+Private.h"
#import <FoxitRDK/FSPDFViewControl.h>
#import "LinkAnnotHandler.h"
#import "TextMKAnnotHandler.h"
#import "NoteAnnotHandler.h"

#import "NoteToolHandler.h"
#import "TextMKToolHandler.h"
#import "SelectToolHandler.h"
#import "FormAnnotHandler.h"
#import "ShapeAnnotHandler.h"
#import "ShapeToolHandler.h"
#import "FtAnnotHandler.h"
#import "FtToolHandler.h"
#import "LineAnnotHandler.h"
#import "LineToolHandler.h"

#import "PencilAnnotHandler.h"
#import "PencilToolHandler.h"
#import "EraseToolHandler.h"

#import "PropertyBar.h"
#import "MenuControl.h"

#import "AnnotationPanel.h"
#import "OutlinePanel.h"

#import "FSAnnotExtent.h"
#import "ColorUtility.h"
#import "AlertView.h"

#import "StampToolHandler.h"
#import "StampAnnotHandler.h"
#import "StampIconController.h"

#import "CaretAnnotHandler.h"
#import "InsertToolHandler.h"
#import "ReplaceToolHandler.h"

#import "FSUndo.h"
#import "AttachmentAnnotHandler.h"
#import "AttachmentToolHandler.h"
#import "SignToolHandler.h"
#import "DigitalSignatureAnnotHandler.h"

@interface UIExtensionsManager() <UIPopoverControllerDelegate, IDocEventListener>

@property (nonatomic, strong) NSMutableDictionary *propertyBarListeners;
@property (nonatomic, strong) NSMutableArray *rotateListeners;

@property (nonatomic, strong) NSMutableDictionary* annotColors;
@property (nonatomic, strong) NSMutableDictionary* annotOpacities;
@property (nonatomic, strong) NSMutableDictionary* annotLineWidths;
@property (nonatomic, strong) NSMutableDictionary* annotFontSizes;
@property (nonatomic, strong) NSMutableDictionary* annotFontNames;

@property (nonatomic, strong) NSMutableArray<IAnnotPropertyListener>* annotPropertyListeners;

@property (nonatomic, strong) NSMutableArray<IGestureEventListener>* guestureEventListeners;

@property (nonatomic, strong) StampIconController* stampIconController;
@property (nonatomic, strong) UIPopoverController* popOverController;

@property (nonatomic, strong) NSMutableArray* securityHandlers;

@end


@implementation UIExtensionsManager

- (id)initWithPDFViewControl:(FSPDFViewCtrl*)viewctrl
{
    self = [super init];
    _pdfViewCtrl = viewctrl;
    [_pdfViewCtrl registerDrawEventListener:self];
    [_pdfViewCtrl registerGestureEventListener:self];
    [_pdfViewCtrl registerRecoveryEventListener:self];
    [_pdfViewCtrl registerDocEventListener:self];
    [_pdfViewCtrl registerPageEventListener:self];
    self.toolHandlers = [NSMutableArray array];
    self.annotHandlers = [NSMutableArray array];
    self.annotListeners = [NSMutableArray array];
    self.toolListeners = [NSMutableArray array];
    self.searchListeners = [NSMutableArray array];
    
    self.currentToolHandler = nil;
    self.propertyBarListeners = [NSMutableDictionary dictionary];
    self.rotateListeners = [[NSMutableArray alloc] init];
    
    self.propertyBar = [[PropertyBar alloc] initWithPDFViewController:viewctrl extensionsManager:self];
    self.searchControl = nil;
    
    self.taskServer = [[TaskServer alloc] init];
    
    self.annotColors = [NSMutableDictionary dictionary];
    self.annotOpacities = [NSMutableDictionary dictionary];
    self.annotLineWidths = [NSMutableDictionary dictionary];
    self.annotFontSizes = [NSMutableDictionary dictionary];
    self.annotFontNames = [NSMutableDictionary dictionary];
    self.annotPropertyListeners = [NSMutableArray<IAnnotPropertyListener> array];
    self.enablelinks = YES;
    self.noteIcon = 2;
    self.attachmentIcon = 1;
    self.eraserLineWidth = 4;
    self.selectionHighlightColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.3];
    
    self.securityHandlers = [NSMutableArray array];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
    [[NoteToolHandler alloc] initWithUIExtensionsManager:self];
    [[NoteAnnotHandler alloc] initWithUIExtensionsManager:self];
    [[LinkAnnotHandler alloc] initWithUIExtensionsManager:self];
    [[MKToolHandler alloc] initWithUIExtensionsManager:self];
    [[MKAnnotHandler alloc] initWithUIExtensionsManager:self];
    [[SelectToolHandler alloc] initWithUIExtensionsManager:self];
    [[ShapeAnnotHandler alloc] initWithUIExtensionsManager:self];
    [[ShapeToolHandler alloc] initWithUIExtensionsManager:self];
    [[FormAnnotHandler alloc] initWithUIExtensionsManager:self];
    [[FtAnnotHandler alloc] initWithUIExtensionsManager:self];
    [[FtToolHandler alloc] initWithUIExtensionsManager:self];
    [[PencilAnnotHandler alloc] initWithUIExtensionsManager:self];
    [[PencilToolHandler alloc] initWithUIExtensionsManager:self];
    [[EraseToolHandler alloc] initWithUIExtensionsManager:self];
    [[LineAnnotHandler alloc] initWithUIExtensionsManager:self];
    [[LineToolHandler alloc] initWithUIExtensionsManager:self];
    [[StampToolHandler alloc] initWithUIExtensionsManager:self];
    [[StampAnnotHandler alloc] initWithUIExtensionsManager:self];
    [[CaretAnnotHandler alloc] initWithUIExtensionsManager:self];
    [[ReplaceToolHandler alloc] initWithUIExtensionsManager:self];
    [[InsertToolHandler alloc] initWithUIExtensionsManager:self];
    [[AttachmentAnnotHandler alloc] initWithUIExtensionsManager:self];
    [[AttachmentToolHandler alloc] initWithUIExtensionsManager:self];
    [[SignToolHandler alloc] initWithUIExtensionsManager:self];
    [[DigitalSignatureAnnotHandler alloc] initWithUIExtensionsManager:self];
#pragma clang diagnostic pop
    
    self.menuControl = [[MenuControl alloc] initWithUIExtensionsManager:self];

    _iconProvider = [[ExAnnotIconProviderCallback alloc] init];
    [FSLibrary setAnnotIconProvider:_iconProvider];
    _actionHandler = [[ExActionHandler alloc] initWithPDFViewControl:viewctrl];
    [FSLibrary setActionHandler:_actionHandler];
    [FSLibrary registerDefaultSignatureHandler];
    
    return self;
}


#pragma mark - IPageEventListener

- (void)onPagesRemoved:(NSArray<NSNumber*>*)indexes
{
    // remove all undo/redo items in removed pages
    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(UndoItem* undoItem, NSDictionary* bindings) {
        return ![indexes containsObject:[NSNumber numberWithInt:undoItem.pageIndex]];
    }];
    [self.undoItems filterUsingPredicate:predicate];
    [self.redoItems filterUsingPredicate:predicate];
    
    void (^updatePageIndex)(UndoItem *item) = ^(UndoItem *item){
        int subcount = 0;
        for(NSNumber* x in indexes)
        {
            if (item.pageIndex > [x intValue])
                subcount++;
        }
        item.pageIndex -= subcount;
    };
    
    [self.undoItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        updatePageIndex((UndoItem*)obj);
    }];
    
    [self.redoItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        updatePageIndex((UndoItem*)obj);
    }];
    
    for (id<IFSUndoEventListener> listener in self.listeners) {
        [listener onUndoChanged];
    }
}

#pragma mark - IRotationEventListener

-(void)registerRotateChangedListener:(id<IRotationEventListener>)listener
{
    if (self.rotateListeners) {
        [self.rotateListeners addObject:listener];
    }
    return YES;
}

-(void)unregisterRotateChangedListener:(id<IRotationEventListener>)listener
{
    if ([self.rotateListeners containsObject:listener]) {
        [self.rotateListeners removeObject:listener];
    }
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    for (id<IRotationEventListener> listener in self.rotateListeners) {
        if ([listener respondsToSelector:@selector(willRotateToInterfaceOrientation:duration:)]) {
            [listener willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
        }
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    for (id<IRotationEventListener> listener in self.rotateListeners) {
        if ([listener respondsToSelector:@selector(didRotateFromInterfaceOrientation:)]) {
            [listener didRotateFromInterfaceOrientation:fromInterfaceOrientation];
        }
    }
}

-(NSString*)getToolHandlerNameByAnnotType:(enum FS_ANNOTTYPE)type
{
    if (type == e_annotHighlight || type == e_annotSquiggly
        || type == e_annotStrikeOut || type == e_annotUnderline) {
        return Tool_Markup;
    }
    if (type == e_annotNote) {
        return Tool_Note;
    }
    return nil;
}

-(void)setCurrentToolHandler:(id<IToolHandler>)toolHandler
{
    id<IToolHandler> lastToolHandler = _currentToolHandler;
    if (lastToolHandler != nil)
    {
        [lastToolHandler onDeactivate];
    }
    if (toolHandler != nil)
    {
        if ([self currentAnnot] != nil)
            [self setCurrentAnnot:nil];
    }
    
    _currentToolHandler = toolHandler;
    
    if (_currentToolHandler != nil)
    {
        [_currentToolHandler onActivate];
    }
    
    for (id<IToolEventListener> listener in self.toolListeners) {
        if ([listener respondsToSelector:@selector(onToolChanged:CurrentToolName:)]) {
            [listener onToolChanged:[lastToolHandler getName] CurrentToolName:[_currentToolHandler getName]];
        }
    }
}

-(id<IToolHandler>)getCurrentToolHandler
{
    return _currentToolHandler;
}

-(id<IToolHandler>)getToolHandlerByName:(NSString*)name
{
    for (id<IToolHandler> toolHandler in self.toolHandlers) {
        if ([toolHandler respondsToSelector:@selector(getName)]) {
            if ([[toolHandler getName] isEqualToString:name]) {
                return toolHandler;
            }
        }
    }
    return nil;
}

-(void)registerToolHandler:(id<IToolHandler>)toolHandler
{
    if (self.toolHandlers) {
        [self.toolHandlers addObject:toolHandler];
    }
}

-(void)unregisterToolHandler:(id<IToolHandler>)toolHandler
{
    if ([self.toolHandlers containsObject:toolHandler]) {
        [self.toolHandlers removeObject:toolHandler];
    }
}
-(void)registerAnnotHandler:(id<IAnnotHandler>)annotHandler
{
    if (self.annotHandlers) {
        [self.annotHandlers addObject:annotHandler];
    }
}
-(void)unregisterAnnotHandler:(id<IAnnotHandler>)annotHandler
{
    if ([self.annotHandlers containsObject:annotHandler]) {
        [self.annotHandlers removeObject:annotHandler];
    }
}

-(id<IAnnotHandler>)getAnnotHandlerByType:(enum FS_ANNOTTYPE)type
{
    if (type == e_annotSquiggly || type == e_annotStrikeOut || type == e_annotUnderline) {
        type = e_annotHighlight;
    }
    if (type == e_annotSquare) {
        type = e_annotCircle;
    }
    for (id<IAnnotHandler> annotHandler in self.annotHandlers) {
        if ([annotHandler respondsToSelector:@selector(getType)]) {
            if ([annotHandler getType] == type) {
                return annotHandler;
            }
        }
    }
    return nil;
}

-(id<IAnnotHandler>)getAnnotHandlerByAnnot:(FSAnnot*)annot
{
    enum FS_ANNOTTYPE type = [annot getType];
    if (type == e_annotSquiggly || type == e_annotStrikeOut || type == e_annotUnderline) {
        type = e_annotHighlight;
    }
    if (type == e_annotSquare) {
        type = e_annotCircle;
    }
    for (id<IAnnotHandler> annotHandler in self.annotHandlers) {
        if ([annotHandler respondsToSelector:@selector(getType)]) {
            if ([annotHandler getType] == type) {
                if (e_annotWidget == type) {
                    FSFormControl* control = (FSFormControl*)annot;
                    enum FS_FORMFIELDTYPE fieldType = [[control getField] getType];
                    if(e_formFieldSignature == fieldType && [annotHandler isKindOfClass:[DigitalSignatureAnnotHandler class]]) {
                        return annotHandler;
                    }
                    if(e_formFieldSignature != fieldType && [annotHandler isKindOfClass:[FormAnnotHandler class]]) {
                        return annotHandler;
                    }
                }
                else
                    return annotHandler;
            }
        }
    }
    return nil;
}

- (void)registerAnnotEventListener:(id<IAnnotEventListener>)listener
{
    if (self.annotListeners) {
        [self.annotListeners addObject:listener];
    }
}
- (void)unregisterAnnotEventListener:(id<IAnnotEventListener>)listener
{
    if ([self.annotListeners containsObject:listener]) {
        [self.annotListeners removeObject:listener];
    }
}

- (void)registerToolEventListener:(id<IToolEventListener>)listener
{
    if (self.toolListeners) {
        [self.toolListeners addObject:listener];
    }
}
- (void)unregisterToolEventListener:(id<IToolEventListener>)listener
{
    if ([self.toolListeners containsObject:listener]) {
        [self.toolListeners removeObject:listener];
    }
}

- (void)registerSearchEventListener:(id<ISearchEventListener>)listener
{
    if (self.searchListeners) {
        [self.searchListeners addObject:listener];
    }
}

- (void)unregisterSearchEventListener:(id<ISearchEventListener>)listener
{
    if ([self.searchListeners containsObject:listener]) {
        [self.searchListeners removeObject:listener];
    }
}

#pragma mark - IGestureEventListener

-(void)registerGestureEventListener:(id<IGestureEventListener>)listener
{
    if (!self.guestureEventListeners) {
        self.guestureEventListeners = [NSMutableArray<IGestureEventListener> array];
    }
    [self.guestureEventListeners addObject:listener];
}

-(void)unregisterGestureEventListener:(id<IGestureEventListener>)listener
{
    [self.guestureEventListeners removeObject:listener];
}

- (BOOL)onLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:[_pdfViewCtrl getDisplayView]];
    int pageIndex = [_pdfViewCtrl getPageIndex:point];
    UIView* pageView = [_pdfViewCtrl getPageView:pageIndex];
    CGPoint cgPoint = [gestureRecognizer locationInView:pageView];
    CGRect rect1 = [pageView frame];
    CGSize size = rect1.size;
    if(cgPoint.x > size.width || cgPoint.y > size.height ||cgPoint.x < 0 ||cgPoint.y < 0)
        return NO;
 
    if ([_pdfViewCtrl getPageLayoutMode] == PDF_LAYOUT_MODE_REFLOW) {
        return NO;
    }
    id<IToolHandler> originToolHandler = self.currentToolHandler;
    if (self.currentToolHandler != nil) {
        if ([self.currentToolHandler onPageViewLongPress:pageIndex recognizer:gestureRecognizer]) {
            return YES;
        }
    }
    id<IToolHandler> selectTool = [self getToolHandlerByName:Tool_Select];
    if (self.currentToolHandler == selectTool)
        [self setCurrentToolHandler:nil];
    
    if (self.currentToolHandler == nil)
    {
        //annot handler
        FSAnnot *annot = nil;
        id<IAnnotHandler> annotHandler = nil;
        annot = self.currentAnnot;
        if (annot != nil) {
            annotHandler = [self getAnnotHandlerByAnnot:annot];
            return [annotHandler onPageViewLongPress:pageIndex recognizer:gestureRecognizer annot:annot];
        }
        
        point = [gestureRecognizer locationInView:[_pdfViewCtrl getPageView:pageIndex]];
        annot = [self getAnnotAtPoint:point pageIndex:pageIndex];
        if (annot != nil) {
            if ([annot getType] != e_annotLink && ![annot isKindOfClass:[FSTextMarkup class]]) //for adding text markups one more at same text
            {
                annotHandler = [self getAnnotHandlerByAnnot:annot];
                if (annotHandler != nil) {
                    return [annotHandler onPageViewLongPress:pageIndex recognizer:gestureRecognizer annot:annot];
                }
            }
        }
        
        id<IAnnotHandler> linkAnnotHandler = [self getAnnotHandlerByType:e_annotLink];
        if (linkAnnotHandler && [linkAnnotHandler onPageViewLongPress:pageIndex recognizer:gestureRecognizer annot:nil])
        {
            return YES;
        }
        
        if (originToolHandler != selectTool && [selectTool onPageViewLongPress:pageIndex recognizer:gestureRecognizer]) {
            if (self.currentToolHandler == nil) {
                [self setCurrentToolHandler:selectTool];
            }
            return YES;
        }
    }
    
    for (id<IGestureEventListener> listener in self.guestureEventListeners) {
        if ([listener respondsToSelector:@selector(onLongPress:)]) {
            if ([listener onLongPress:gestureRecognizer])
                return YES;
        }
    }

    return NO;
}

- (BOOL)onTap:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:[_pdfViewCtrl getDisplayView]];
    int pageIndex = [_pdfViewCtrl getPageIndex:point];
    UIView* pageView = [_pdfViewCtrl getPageView:pageIndex];
    CGPoint cgPoint = [gestureRecognizer locationInView:pageView];
    CGRect rect1 = [pageView frame];
    CGSize size = rect1.size;
    if(cgPoint.x > size.width || cgPoint.y > size.height ||cgPoint.x < 0 ||cgPoint.y < 0)
        return NO;
    
    if ([_pdfViewCtrl getPageLayoutMode] == PDF_LAYOUT_MODE_REFLOW) {
        return NO;
    }
    id<IToolHandler> originToolHandler = self.currentToolHandler;
    if (self.currentToolHandler != nil) {
        if ([self.currentToolHandler onPageViewTap:pageIndex recognizer:gestureRecognizer]) {
            return YES;
        }
    }
    id<IToolHandler> selectTool = [self getToolHandlerByName:Tool_Select];
    if (self.currentToolHandler == selectTool)
        [self setCurrentToolHandler:nil];

    if (self.currentToolHandler == nil)
    {
        //annot handler
        FSAnnot *annot = nil;
        id<IAnnotHandler> annotHandler = nil;
        annot = self.currentAnnot;
        if (annot != nil) {
            annotHandler = [self getAnnotHandlerByAnnot:annot];
            return [annotHandler onPageViewTap:pageIndex recognizer:gestureRecognizer annot:annot];
        }
        point = [gestureRecognizer locationInView:[_pdfViewCtrl getPageView:pageIndex]];
        annot = [self getAnnotAtPoint:point pageIndex:pageIndex];
        
        if (originToolHandler != selectTool && [selectTool onPageViewTap:pageIndex recognizer:gestureRecognizer]) {
            return YES;
        }
        if (annot != nil) {
            annotHandler = [self getAnnotHandlerByAnnot:annot];
            if (annotHandler != nil) {
                return [annotHandler onPageViewTap:pageIndex recognizer:gestureRecognizer annot:annot];
            }
        }
    
        id<IAnnotHandler> linkAnnotHandler = [self getAnnotHandlerByType:e_annotLink];
        if (linkAnnotHandler && [linkAnnotHandler onPageViewTap:pageIndex recognizer:gestureRecognizer annot:nil])
        {
            return YES;
        }
    }
    
    for (id<IGestureEventListener> listener in self.guestureEventListeners) {
        if ([listener respondsToSelector:@selector(onTap:)]) {
            if ([listener onTap:gestureRecognizer])
                return YES;
        }
    }
    return NO;
}

- (BOOL)onPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:[_pdfViewCtrl getDisplayView]];
    int pageIndex = [_pdfViewCtrl getPageIndex:point];
    if ([_pdfViewCtrl getPageLayoutMode] == PDF_LAYOUT_MODE_REFLOW) {
        return NO;
    }
    id<IToolHandler> originToolHandler = self.currentToolHandler;
    if (self.currentToolHandler != nil) {
        if ([self.currentToolHandler onPageViewPan:pageIndex recognizer:recognizer]) {
            return YES;
        }
    }
    id<IToolHandler> selectTool = [self getToolHandlerByName:Tool_Select];
    if (self.currentToolHandler == selectTool)
        [self setCurrentToolHandler:nil];
    
    if (self.currentToolHandler == nil)
    {
        //annot handler
        FSAnnot *annot = nil;
        id<IAnnotHandler> annotHandler = nil;
        annot = self.currentAnnot;
        if (annot != nil) {
            annotHandler = [self getAnnotHandlerByAnnot:annot];
            return [annotHandler onPageViewPan:pageIndex recognizer:recognizer annot:annot];
        }

        point = [recognizer locationInView:[_pdfViewCtrl getPageView:pageIndex]];
        annot = [self getAnnotAtPoint:point pageIndex:pageIndex];
        if (annot != nil) {
            annotHandler = [self getAnnotHandlerByAnnot:annot];
            if (annotHandler != nil) {
                return [annotHandler onPageViewPan:pageIndex recognizer:recognizer annot:annot];
            }
        }
        id<IToolHandler> selectTool = [self getToolHandlerByName:Tool_Select];
        if (originToolHandler != selectTool && [selectTool onPageViewPan:pageIndex recognizer:recognizer]) {
            return YES;
        }
    }
    for (id<IGestureEventListener> listener in self.guestureEventListeners) {
        if ([listener respondsToSelector:@selector(onPan:)]) {
            if ([listener onPan:recognizer])
                return YES;
        }
    }
    return NO;
}

- (FSAnnot*)getAnnotAtPoint:(CGPoint)pvPoint pageIndex:(int)pageIndex
{
    FSPDFPage*  page = [_pdfViewCtrl.currentDoc getPage:pageIndex];
    FSMatrix* matrix = [_pdfViewCtrl getDisplayMatrix:pageIndex];
    FSPointF* devicePoint = [[FSPointF alloc] init];
    [devicePoint set:pvPoint.x y:pvPoint.y];
    FSAnnot* annot = [page getAnnotAtDevicePos:matrix position:devicePoint tolerance:5];
    
    if (!annot) {
        return nil;
    }
    
    id<IAnnotHandler> annotHandler = [self getAnnotHandlerByAnnot:annot];
    if ([annotHandler isHitAnnot:annot point:[_pdfViewCtrl convertPageViewPtToPdfPt:pvPoint pageIndex:pageIndex]]) {
        return  annot;
    }
    
    if (annot.type == e_annotStrikeOut) {
        FSMarkup* markup = (FSMarkup*)annot;
        for (int i = 0; i < [markup getGroupElementCount]; i ++) {
            FSAnnot* groupAnnot = [markup getGroupElement:i];
            if (groupAnnot.type == e_annotCaret) {
                return groupAnnot;
            }
        }
        return annot;
    }
    return nil;
}

- (BOOL)onShouldBegin:(UIGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:[_pdfViewCtrl getDisplayView]];
    int pageIndex = [_pdfViewCtrl getPageIndex:point];
    
    if ([_pdfViewCtrl getPageLayoutMode] == PDF_LAYOUT_MODE_REFLOW) {
        return NO;
    }
    if (_currentToolHandler != nil) {
        if ([_currentToolHandler onPageViewShouldBegin:pageIndex recognizer:recognizer]) {
            return YES;
        }
    }
    
    if (self.currentToolHandler == nil || [[self.currentToolHandler getName] isEqualToString:Tool_Select])
    {
        //annot handler
        FSAnnot *annot = nil;
        id<IAnnotHandler> annotHandler = nil;
        annot = self.currentAnnot;
        if (annot != nil) {
            annotHandler = [self getAnnotHandlerByAnnot:annot];
            return [annotHandler onPageViewShouldBegin:pageIndex recognizer:recognizer annot:annot];
        }
        
        if ([recognizer isKindOfClass:[UITapGestureRecognizer class]])
        {
            if (((UITapGestureRecognizer*)recognizer).numberOfTapsRequired == 2)
            {
                return NO;
            }
        }
        
        if ([recognizer isKindOfClass:[UITapGestureRecognizer class]] ||
            [recognizer isKindOfClass:[UILongPressGestureRecognizer class]] ||
            [recognizer isKindOfClass:[UIPanGestureRecognizer class]])
        {
            CGPoint point = [recognizer locationInView:[_pdfViewCtrl getPageView:pageIndex]];
            annot = [self getAnnotAtPoint:point pageIndex:pageIndex];
            if (annot != nil) {
                annotHandler = [self getAnnotHandlerByAnnot:annot];
                if (annotHandler != nil && ![recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                    return [annotHandler onPageViewShouldBegin:pageIndex recognizer:recognizer annot:annot];
                }
            }
            //    }
            
            id<IAnnotHandler> linkAnnotHandler = [self getAnnotHandlerByType:e_annotLink];
            if (linkAnnotHandler && [linkAnnotHandler onPageViewShouldBegin:pageIndex recognizer:recognizer annot:nil] && ![recognizer isKindOfClass:[UIPanGestureRecognizer class]])
            {
                return YES;
            }
            
            id<IToolHandler> selectTool = [self getToolHandlerByName:Tool_Select];
            if (self.currentToolHandler != selectTool && [selectTool onPageViewShouldBegin:pageIndex recognizer:recognizer]) {
                return YES;
            }
        }
        return NO;
    }
        // return no here,
        // make the pan gesture recognized by the page container
    if ([self getCurrentToolHandler] != nil) {
        NSString* name = [[self getCurrentToolHandler] getName];
        if (name != nil) {
            return YES;
        }
    }
    
    for (id<IGestureEventListener> listener in self.guestureEventListeners) {
        if ([listener respondsToSelector:@selector(onShouldBegin:)]) {
            if ([listener onShouldBegin:recognizer])
                return YES;
        }
    }

    return NO;
}

- (BOOL)onTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:[_pdfViewCtrl getDisplayView]];
    int pageIndex = [_pdfViewCtrl getPageIndex:point];
    
    if ([_pdfViewCtrl getPageLayoutMode] == PDF_LAYOUT_MODE_REFLOW) {
        return NO;
    }
    if (_currentToolHandler != nil) {
        if ([_currentToolHandler onPageViewTouchesBegan:pageIndex touches:touches withEvent:event]) {
            return YES;
        }
    } else
    {
        //annot handler
        FSAnnot *annot = nil;
        id<IAnnotHandler> annotHandler = nil;
        annot = self.currentAnnot;
        if (annot != nil) {
            annotHandler = [self getAnnotHandlerByAnnot:annot];
            return [annotHandler onPageViewTouchesBegan:pageIndex touches:touches withEvent:event annot:annot];
        }
        point = [[touches anyObject] locationInView:[_pdfViewCtrl getPageView:pageIndex]];
        annot = [self getAnnotAtPoint:point pageIndex:pageIndex];
        if (annot != nil) {
            annotHandler = [self getAnnotHandlerByAnnot:annot];
            if (annotHandler != nil) {
                return [annotHandler onPageViewTouchesBegan:pageIndex touches:touches withEvent:event annot:annot];
            }
        }
        return NO;
    }
    return NO;
    
}
- (BOOL)onTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:[_pdfViewCtrl getDisplayView]];
    int pageIndex = [_pdfViewCtrl getPageIndex:point];
    
    if ([_pdfViewCtrl getPageLayoutMode] == PDF_LAYOUT_MODE_REFLOW) {
        return NO;
    }
    if (_currentToolHandler != nil) {
        if ([_currentToolHandler onPageViewTouchesMoved:pageIndex touches:touches withEvent:event]) {
            return YES;
        }
    } else
    {
        //annot handler
        FSAnnot *annot = nil;
        id<IAnnotHandler> annotHandler = nil;
        annot = self.currentAnnot;
        if (annot != nil) {
            annotHandler = [self getAnnotHandlerByAnnot:annot];
            return [annotHandler onPageViewTouchesMoved:pageIndex touches:touches withEvent:event annot:annot];
        }
        point = [[touches anyObject] locationInView:[_pdfViewCtrl getPageView:pageIndex]];
        annot = [self getAnnotAtPoint:point pageIndex:pageIndex];
        if (annot != nil) {
            annotHandler = [self getAnnotHandlerByAnnot:annot];
            if (annotHandler != nil) {
                return [annotHandler onPageViewTouchesMoved:pageIndex touches:touches withEvent:event annot:annot];
            }
        }
        return NO;
    }
    return NO;
}

- (BOOL)onTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:[_pdfViewCtrl getDisplayView]];
    int pageIndex = [_pdfViewCtrl getPageIndex:point];
    
    if ([_pdfViewCtrl getPageLayoutMode] == PDF_LAYOUT_MODE_REFLOW) {
        return NO;
    }
    /** The current tool will handle the tourches first if it's actived. */
    if (_currentToolHandler != nil) {
        if ([_currentToolHandler onPageViewTouchesEnded:pageIndex touches:touches withEvent:event]) {
            return YES;
        }
    } else
    {
        //annot handler
        FSAnnot *annot = nil;
        id<IAnnotHandler> annotHandler = nil;
        annot = self.currentAnnot;
        if (annot != nil) {
            annotHandler = [self getAnnotHandlerByAnnot:annot];
            return [annotHandler onPageViewTouchesEnded:pageIndex touches:touches withEvent:event annot:annot];
        }
        point = [[touches anyObject] locationInView:[_pdfViewCtrl getPageView:pageIndex]];
        annot = [self getAnnotAtPoint:point pageIndex:pageIndex];
        if (annot != nil) {
            annotHandler = [self getAnnotHandlerByAnnot:annot];
            if (annotHandler != nil) {
                return [annotHandler onPageViewTouchesEnded:pageIndex touches:touches withEvent:event annot:annot];
            }
        }
        return NO;
    }
    return NO;
}

- (BOOL)onTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:[_pdfViewCtrl getDisplayView]];
    int pageIndex = [_pdfViewCtrl getPageIndex:point];
    
    if ([_pdfViewCtrl getPageLayoutMode] == PDF_LAYOUT_MODE_REFLOW) {
        return NO;
    }
    
    if (_currentToolHandler != nil) {
        if ([_currentToolHandler onPageViewTouchesCancelled:pageIndex touches:touches withEvent:event]) {
            return YES;
        }
    } else
    {
        //annot handler
        FSAnnot *annot = nil;
        id<IAnnotHandler> annotHandler = nil;
        annot = self.currentAnnot;
        if (annot != nil) {
            annotHandler = [self getAnnotHandlerByAnnot:annot];
            return [annotHandler onPageViewTouchesCancelled:pageIndex touches:touches withEvent:event annot:annot];
        }
        point = [[touches anyObject] locationInView:[_pdfViewCtrl getPageView:pageIndex]];
        annot = [self getAnnotAtPoint:point pageIndex:pageIndex];
        if (annot != nil) {
            annotHandler = [self getAnnotHandlerByAnnot:annot];
            if (annotHandler != nil) {
                return [annotHandler onPageViewTouchesCancelled:pageIndex touches:touches withEvent:event annot:annot];
            }
        }
        return NO;
    }
    return NO;
}

#pragma mark IDrawEventListener
-(void)onDraw:(int)pageIndex inContext:(CGContextRef)context
{
    for (id<IToolHandler> handler in self.toolHandlers) {
        if ([handler respondsToSelector:@selector(onDraw:inContext:)]) {
            [handler onDraw:pageIndex inContext:context];
        }
    }
    
    if (self.currentAnnot) {
        id<IAnnotHandler> annotHandler = [self getAnnotHandlerByAnnot:self.currentAnnot];
        if ([annotHandler respondsToSelector:@selector(onDraw:inContext:annot:)]) {
            [annotHandler onDraw:pageIndex inContext:context annot:self.currentAnnot];
        }
    }
    
    id<IAnnotHandler> annotHandler = [self getAnnotHandlerByType:e_annotLink];
    if (annotHandler) {
        if ([annotHandler respondsToSelector:@selector(onDraw:inContext:annot:)]) {
            [annotHandler onDraw:pageIndex inContext:context annot:nil];
        }
    }
}

- (void)onAnnotAdded:(FSPDFPage* )page annot:(FSAnnot*)annot
{
    for (id<IAnnotEventListener> listener in self.annotListeners) {
        if ([listener respondsToSelector:@selector(onAnnotAdded:annot:)]) {
            [listener onAnnotAdded:page annot:annot];
        }
    }
}

- (void)onAnnotDeleted:(FSPDFPage* )page annot:(FSAnnot*)annot
{
    if(annot == self.currentAnnot)
    {
        _currentAnnot = nil;
    }
    
    for (id<IAnnotEventListener> listener in self.annotListeners) {
        if ([listener respondsToSelector:@selector(onAnnotDeleted:annot:)]) {
            [listener onAnnotDeleted:page annot:annot];
        }
    }
}

- (void)onAnnotModified:(FSPDFPage* )page annot:(FSAnnot*)annot
{
    for (id<IAnnotEventListener> listener in self.annotListeners) {
        if ([listener respondsToSelector:@selector(onAnnotModified:annot:)]) {
            [listener onAnnotModified:page annot:annot];
        }
    }
}
- (void)onAnnotSelected:(FSPDFPage* )page annot:(FSAnnot*)annot
{
    for (id<IAnnotEventListener> listener in self.annotListeners) {
        if ([listener respondsToSelector:@selector(onAnnotSelected:annot:)]) {
            [listener onAnnotSelected:page annot:annot];
        }
    }
}

- (void)onAnnotDeselected:(FSPDFPage* )page annot:(FSAnnot*)annot
{
    for (id<IAnnotEventListener> listener in self.annotListeners) {
        if ([listener respondsToSelector:@selector(onAnnotDeselected:annot:)]) {
            [listener onAnnotDeselected:page annot:annot];
        }
    }
}

- (void)onScrollViewWillBeginDragging:(UIScrollView *)scrollView
{

}
- (void)onScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{

}
- (void)onScrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{

}
- (void)onScrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

}
- (void)onScrollViewWillBeginZooming:(UIScrollView *)scrollView
{

}
- (void)onScrollViewDidEndZooming:(UIScrollView *)scrollView
{

}

- (void)setCurrentAnnot:(FSAnnot*)annot
{
    if ([self.currentAnnot getCptr] == [annot getCptr])
    {
        return;
    }
    
    if (self.currentAnnot != nil) {
        id<IAnnotHandler> annotHandler = [self getAnnotHandlerByAnnot:self.currentAnnot];
        if(annotHandler)
        {
            [annotHandler onAnnotDeselected:self.currentAnnot];
            [self onAnnotDeselected:[annot getPage] annot:self.currentAnnot];
        }
    }
    
    _currentAnnot = annot;
    if (annot != nil) {
        
        int pageIndex = annot.pageIndex;
        CGRect pvRect = [Utility getAnnotRect:annot pdfViewCtrl:_pdfViewCtrl];
        CGRect dvRect = [_pdfViewCtrl convertPageViewRectToDisplayViewRect:pvRect pageIndex:pageIndex];
        BOOL isAnnotVisible = CGRectContainsRect(_pdfViewCtrl.bounds, dvRect);
        if (!isAnnotVisible) {
            FSPointF* fspt = [[FSPointF alloc] init];
            FSRectF* fsrect = annot.type == e_annotCaret ? [Utility getCaretAnnotRect:(FSCaret*)annot] : annot.fsrect;
            [fspt set:fsrect.left y:fsrect.bottom];
            
            if (DEVICE_iPHONE)
            {
                //Avoid being sheltered from top bar. To do, need to check page rotation.
                [fspt setY:[fspt getY] + 64];
            }

            [_pdfViewCtrl gotoPage:pageIndex withDocPoint:fspt animated:YES];
                    }
        
        id<IAnnotHandler> annotHandler = [self getAnnotHandlerByAnnot:annot];
        if(annotHandler)
        {
            [annotHandler onAnnotSelected:annot];
            [self onAnnotSelected:[annot getPage] annot:annot];
        }
    }
}

#pragma mark - annot property

-(void)showProperty:(enum FS_ANNOTTYPE)annotType rect:(CGRect)rect inView:(UIView*)view
{
    // stamp
    if (annotType == e_annotStamp) {
        {
            __weak UIExtensionsManager* weakSelf = self;
            self.stampIconController = [[StampIconController alloc] initWithUIExtensionsManager:self];
            self.stampIconController.selectHandler = ^(int icon)
            {
                ((StampToolHandler*)[weakSelf getToolHandlerByName:Tool_Stamp]).stampIcon = icon;
                if (DEVICE_iPHONE) {
                    [weakSelf.stampIconController dismissViewControllerAnimated:YES completion:nil];
                }
            };
        }
        if (DEVICE_iPHONE) {
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            [rootViewController presentViewController:self.stampIconController animated:YES completion:nil];
        }
        else
        {
            self.popOverController = [[UIPopoverController alloc] initWithContentViewController:self.stampIconController];
            self.popOverController.delegate = self;
            [self.popOverController setPopoverContentSize:CGSizeMake(300, 420)];
            [self.popOverController presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        return;
    }
    // eraser
    if (annotType == e_annotInk && [[self.currentToolHandler getName] isEqualToString:Tool_Eraser]) {
        [self.propertyBar resetBySupportedItems:PROPERTY_LINEWIDTH frame:CGRectZero];
        [self.propertyBar setProperty:PROPERTY_COLOR intValue:[UIColor grayColor].rgbHex];
        [self.propertyBar setProperty:PROPERTY_LINEWIDTH intValue:self.eraserLineWidth];
        [self.propertyBar addListener:self];
        [self.propertyBar showPropertyBar:rect inView:view viewsCanMove:nil];
        return;
    }
    NSArray *colors = nil;
    if (annotType == e_annotHighlight) {
        colors = @[@0xFFFF00,@0xCCFF66,@0x00FFFF,@0x99CCFF,@0x7480FC,@0xCC99FF,@0xFF99FF,@0xFF9999,@0x00CC66,@0x22F3B1];
    }
    else if (annotType == e_annotUnderline || annotType == e_annotSquiggly)
    {
        colors = @[@0x33CC00,@0xCCCC00,@0xFF9933,@0x0099CC,@0xBBBBBB,@0x3366FF,@0xCC33FF,@0xCC0099,@0xFF0000,@0x686767];
    }
    else if (annotType == e_annotStrikeOut)
    {
        colors = @[@0xFF3333,@0xFF00FF,@0x9966FF,@0x66CC33,@0x996666,@0xCCCC00,@0xFF9900,@0x00CCFF,@0x00CCCC,@0x000000];
    }
    else if (annotType == e_annotNote)
    {
        colors = @[@0xFF9F40,@0x8080FF,@0xBAE94C,@0xFFF160,@0xC3C3C3,@0xFF4C4C,@0x669999,@0xC72DA1,@0x996666,@0x000000];
    }
    else if (annotType == e_annotCircle || annotType == e_annotSquare ||annotType ==e_annotLine)
    {
        colors = @[@0xFF9F40,@0x8080FF,@0xBAE94C,@0xFFF160,@0xC3C3C3,@0xFF4C4C,@0x669999,@0xC72DA1,@0x996666,@0x000000];
    }
    else if (annotType == e_annotFreeText)
    {
        colors = @[@0x3366CC,@0x669933,@0xCC6600,@0xCC9900,@0xA3A305,@0xCC0000,@0x336666,@0x660066,@0x000000,@0x8F8E8E];
    }
    else if (annotType == e_annotInk)
    {
        colors = @[@0xFF9F40,@0x8080FF,@0xBAE94C,@0xFFF160,@0xC3C3C3,@0xFF4C4C,@0x669999,@0xC72DA1,@0x996666,@0x000000];
    }
    else if (annotType == e_annotCaret || annotType == e_annotFileAttachment)
    {
        colors = @[@0xFF9F40,@0x8080FF,@0xBAE94C,@0xFFF160,@0x996666,@0xFF4C4C,@0x669999,@0xFFFFFF,@0xC3C3C3,@0x000000];
    }

    [self.propertyBar setColors:colors];
    
    if (annotType == e_annotSquare || annotType == e_annotCircle ||annotType == e_annotLine) {
        [self.propertyBar resetBySupportedItems:PROPERTY_COLOR | PROPERTY_OPACITY | PROPERTY_LINEWIDTH frame:CGRectZero];
        [self.propertyBar setProperty:PROPERTY_LINEWIDTH intValue:[self getAnnotLineWidth:annotType]];
    } else if (annotType == e_annotFreeText) {
        [self.propertyBar resetBySupportedItems:PROPERTY_COLOR | PROPERTY_OPACITY | PROPERTY_FONTNAME | PROPERTY_FONTSIZE frame:CGRectZero];
        [self.propertyBar setProperty:PROPERTY_FONTSIZE floatValue:[self getAnnotFontSize:annotType]];
        [self.propertyBar setProperty:PROPERTY_FONTNAME stringValue:[self getAnnotFontName:annotType]];
    } else if (annotType == e_annotInk) {
        [self.propertyBar resetBySupportedItems:PROPERTY_COLOR | PROPERTY_OPACITY | PROPERTY_LINEWIDTH frame:CGRectZero];
        [self.propertyBar setProperty:PROPERTY_LINEWIDTH intValue:[self getAnnotLineWidth:annotType]];
    } else if (annotType == e_annotFileAttachment) {
        [self.propertyBar resetBySupportedItems:PROPERTY_COLOR | PROPERTY_OPACITY | PROPERTY_ATTACHMENT_ICONTYPE frame:CGRectZero];
        [self.propertyBar setProperty:PROPERTY_ATTACHMENT_ICONTYPE intValue:self.attachmentIcon];
    } else {
        [self.propertyBar resetBySupportedItems:PROPERTY_COLOR | PROPERTY_OPACITY frame:CGRectZero];
    }
    [self.propertyBar setProperty:PROPERTY_COLOR intValue:[self getPropertyBarSettingColor:annotType]];
    [self.propertyBar setProperty:PROPERTY_OPACITY intValue:[self getAnnotOpacity:annotType]];
    
    if (annotType == e_annotNote) {
        if (self.noteIcon == 0) {
            self.noteIcon = 2;
        }
        [self.propertyBar setProperty:PROPERTY_ICONTYPE intValue:self.noteIcon];
    }
    [self.propertyBar addListener:self];
    [self.propertyBar showPropertyBar:rect inView:view viewsCanMove:nil];
}

-(int)filterAnnotType:(enum FS_ANNOTTYPE)annotType
{
    if (e_annotLine == annotType)
    {
        LineToolHandler* toolHandler = [self getToolHandlerByName:Tool_Line];
        if (toolHandler.isArrowLine)
            return e_annotArrowLine;
    }
    if (e_annotCaret == annotType) {
        NSString* toolHandlerName = [self.currentToolHandler getName];
        if ([toolHandlerName isEqualToString:@"Tool_Insert"]) {
            return e_annotInsert;
        }
        else if ([toolHandlerName isEqualToString:@"Tool_Replace"])
            return e_annotCaret;
        CaretAnnotHandler* annotHandler = (CaretAnnotHandler*)[self getAnnotHandlerByType:e_annotCaret];
        if (annotHandler.isInsert) {
            return e_annotInsert;
        }
    }
    
    return annotType;
}

-(unsigned int)getPropertyBarSettingColor:(enum FS_ANNOTTYPE)annotType
{
    return [self getAnnotColor:annotType];
}

-(unsigned int)getPropertyBarSettingOpacity:(enum FS_ANNOTTYPE)annotType
{
    return [self getAnnotOpacity:annotType];
}

-(unsigned int)getAnnotColor:(enum FS_ANNOTTYPE)annotType
{
    NSNumber* colorNum = self.annotColors[[NSNumber numberWithInt:[self filterAnnotType:annotType]]];
    if (colorNum != nil)
    {
        return colorNum.intValue;
    }
    else
    {
        // markup
        if (annotType == e_annotHighlight)
        {
            return 0xFFFF00;
        }
        else if (annotType == e_annotUnderline || annotType == e_annotSquiggly)
        {
            return 0x33CC00;
        }
        else if (annotType == e_annotStrikeOut)
        {
            return 0xFF3333;
        }
        // note
        else if (annotType == e_annotNote)
        {
            return 0xFF9F40;
        }
        // shape
        else if (annotType == e_annotSquare || annotType == e_annotCircle ||annotType == e_annotLine)
        {
            return 0xFF9F40;
        }
        // free text
        else if (annotType == e_annotFreeText)
        {
            return 0x3366CC;
        }
        else if (annotType == e_annotInk)
        {
            return 0xbae94c;
        }
        else if (annotType == e_annotCaret || annotType == e_annotFileAttachment)
        {
            return 0xFF9F40;
        }
        else
        {
            return 0;
        }
    }
}

-(void)setAnnotColor:(unsigned int)color annotType:(enum FS_ANNOTTYPE)annotType
{
    self.annotColors[[NSNumber numberWithInt:[self filterAnnotType:annotType]]] = [NSNumber numberWithInt:color];
    for (id<IAnnotPropertyListener> listender in self.annotPropertyListeners) {
        if ([listender respondsToSelector:@selector(onAnnotColorChanged:annotType:)])
            [listender onAnnotColorChanged:color annotType:annotType];
    }
}

-(int)getAnnotOpacity:(enum FS_ANNOTTYPE)annotType
{
    int opacity = ((NSNumber*)self.annotOpacities[[NSNumber numberWithInt:[self filterAnnotType:annotType]]]).intValue;
    return opacity ? opacity : 100;
}

-(void)setAnnotOpacity:(int)opacity annotType:(enum FS_ANNOTTYPE)annotType
{
    self.annotOpacities[[NSNumber numberWithInt:[self filterAnnotType:annotType]]] = [NSNumber numberWithInt:opacity];
    for (id<IAnnotPropertyListener> listender in self.annotPropertyListeners) {
        if ([listender respondsToSelector:@selector(onAnnotOpacityChanged:annotType:)])
            [listender onAnnotOpacityChanged:opacity annotType:annotType];
    }
}

-(int)getAnnotLineWidth:(enum FS_ANNOTTYPE)annotType
{
    NSNumber* widthNum = self.annotLineWidths[[NSNumber numberWithInt:[self filterAnnotType:annotType]]];
    if (widthNum != nil)
    {
        return widthNum.intValue;
    }
    else
    {
       return 2;
    }
}

-(void)setAnnotLineWidth:(int)lineWidth annotType:(enum FS_ANNOTTYPE)annotType
{
    self.annotLineWidths[[NSNumber numberWithInt:[self filterAnnotType:annotType]]] = [NSNumber numberWithInt:lineWidth];
    for (id<IAnnotPropertyListener> listener in self.annotPropertyListeners) {
        if ([listener respondsToSelector:@selector(onAnnotLineWidthChanged:annotType:)]) {
            [listener onAnnotLineWidthChanged:lineWidth annotType:annotType];
        }
    }
}

-(int)getAnnotFontSize:(enum FS_ANNOTTYPE)annotType
{
    NSNumber* num = (NSNumber*)self.annotFontSizes[[NSNumber numberWithInt:annotType]];
    if (num) {
        return num.intValue;
    } else {
        return 18;
    }
}

-(void)setAnnotFontSize:(int)fontSize annotType:(enum FS_ANNOTTYPE)annotType
{
    self.annotFontSizes[[NSNumber numberWithInt:annotType]] = [NSNumber numberWithInt:fontSize];
    for (id<IAnnotPropertyListener> listener in self.annotPropertyListeners) {
        if ([listener respondsToSelector:@selector(onAnnotFontSizeChanged:annotType:)]) {
            [listener onAnnotFontSizeChanged:fontSize annotType:annotType];
        }
    }
}

-(NSString*)getAnnotFontName:(enum FS_ANNOTTYPE)annotType
{
    return self.annotFontNames[[NSNumber numberWithInt:annotType]] ?: @"Courier";
}

-(void)setAnnotFontName:(NSString*)fontName annotType:(enum FS_ANNOTTYPE)annotType
{
    self.annotFontNames[[NSNumber numberWithInt:annotType]] = fontName;
    for (id<IAnnotPropertyListener> listener in self.annotPropertyListeners) {
        if ([listener respondsToSelector:@selector(onAnnotFontNameChanged:annotType:)]) {
            [listener onAnnotFontNameChanged:fontName annotType:annotType];
        }
    }
}

-(void)setNoteIcon:(int)noteIcon
{
    _noteIcon = noteIcon;
    for (id<IAnnotPropertyListener> listener in self.annotPropertyListeners) {
        if ([listener respondsToSelector:@selector(onAnnotIconChanged:annotType:)]) {
            [listener onAnnotIconChanged:noteIcon annotType:e_annotNote];
        }
    }
}

-(void)setAttachmentIcon:(int)attachmentIcon
{
    _attachmentIcon = attachmentIcon;
    for (id<IAnnotPropertyListener> listener in self.annotPropertyListeners) {
        if ([listener respondsToSelector:@selector(onAnnotIconChanged:annotType:)]) {
            [listener onAnnotIconChanged:attachmentIcon annotType:e_annotFileAttachment];
        }
    }
}



#pragma mark - IPropertyValueChangedListener
-(void)onProperty:(long)property changedFrom:(NSValue *)oldValue to:(NSValue *)newValue
{
    FSAnnot* annot = self.currentAnnot;
    if (annot) {
        BOOL addUndo;
        switch (annot.type) {
            case e_annotNote:
            case e_annotCircle:
            case e_annotSquare:
            case e_annotFreeText:
            // text markup
            case e_annotHighlight:
            case e_annotUnderline:
            case e_annotStrikeOut:
            case e_annotSquiggly:
                
            case e_annotLine:
            case e_annotInk:
            case e_annotCaret:
            case e_annotStamp:
                addUndo = NO;
                break;
            default:
                addUndo = YES;
                break;
        }
        [self changeAnnot:annot property:property from:oldValue to:newValue];
    }

    enum FS_ANNOTTYPE annotType = annot ? annot.type : _currentToolHandler.type;
    switch (property) {
        case PROPERTY_COLOR:
            [self setAnnotColor:[(NSNumber*)newValue unsignedIntValue] annotType:annotType];
            break;
        case PROPERTY_OPACITY:
            [self setAnnotOpacity:[(NSNumber*)newValue unsignedIntValue] annotType:annotType];
            break;
        case PROPERTY_ICONTYPE:
            self.noteIcon = [(NSNumber*)newValue intValue];
            break;
        case PROPERTY_ATTACHMENT_ICONTYPE:
            self.attachmentIcon = [(NSNumber*)newValue unsignedIntValue];
            break;
        case PROPERTY_LINEWIDTH:
            if ([[self.currentToolHandler getName] isEqualToString:Tool_Eraser]) {
                self.eraserLineWidth = [(NSNumber*)newValue unsignedIntValue];
            } else {
                [self setAnnotLineWidth:[(NSNumber*)newValue unsignedIntValue] annotType:annotType];
            }
            break;
        case PROPERTY_FONTSIZE:
            [self setAnnotFontSize:[(NSNumber*)newValue unsignedIntValue] annotType:annotType];
            break;
        case PROPERTY_FONTNAME:
            [self setAnnotFontName:(NSString*)[newValue nonretainedObjectValue] annotType:annotType];
            break;
        default:
            break;
    }
}

-(void)changeAnnot:(FSAnnot*)annot property:(long)property from:(NSValue *)oldValue to:(NSValue *)newValue// addUndo:(BOOL)addUndo
{
    int pageIndex = annot.pageIndex;
    CGRect oldRect = [_pdfViewCtrl convertPdfRectToPageViewRect:annot.fsrect pageIndex:pageIndex];
    BOOL modified = YES;
    switch (property) {
        case PROPERTY_COLOR:
            annot.color = [(NSNumber*)newValue unsignedIntValue];
            break;
        case PROPERTY_OPACITY:
            annot.opacity = [(NSNumber*)newValue unsignedIntValue] / 100.0f;
            break;
        case PROPERTY_ICONTYPE:
            if (annot.type == e_annotNote) {
                ((FSNote*)annot).icon = [(NSNumber*)newValue unsignedIntValue];
            } else {
                modified = NO;
            }
            break;
        case PROPERTY_ATTACHMENT_ICONTYPE:
            if (annot.type == e_annotFileAttachment) {
                ((FSFileAttachment*)annot).icon = [(NSNumber*)newValue unsignedIntValue];
            } else {
                modified = NO;
            }
            break;
        case PROPERTY_LINEWIDTH:
            annot.lineWidth = [(NSNumber*)newValue unsignedIntValue];
            break;
        case PROPERTY_FONTSIZE:
            if (annot.type == e_annotFreeText) {
                FSFreeText* freeText = (FSFreeText*)annot;
                int newFontSize = [(NSNumber*)newValue unsignedIntValue];
                FSDefaultAppearance* ap = [freeText getDefaultAppearance];
                ap.fontSize = newFontSize;
                [freeText setDefaultAppearance:ap];
            } else {
                modified = NO;
            }
            break;
        case PROPERTY_FONTNAME:
            if (annot.type == e_annotFreeText) {
                FSFreeText* freeText = (FSFreeText*)annot;
                NSString* newFontName = (NSString*)[newValue nonretainedObjectValue];
                FSDefaultAppearance* ap = [freeText getDefaultAppearance];
                FSFont* originFont = ap.font;
                if ([newFontName caseInsensitiveCompare:[originFont getName]] != NSOrderedSame) {
                    int fontID = [Utility toStandardFontID:newFontName];
                    if (fontID == -1) {
                        ap.font = [FSFont create:newFontName fontStyles:0 weight:0 charset:e_fontCharsetDefault];
                    } else {
                        ap.font = [FSFont createStandard:fontID];
                    }
                    [freeText setDefaultAppearance:ap];
                }
            } else {
                modified = NO;
            }
            break;
        default:
            modified = NO;
            break;
    }
    if (modified) {
        FSDateTime *now = [Utility convert2FSDateTime:[NSDate date]];
        [annot setModifiedDateTime:now];
        [annot resetAppearanceStream];
        
        id<IAnnotHandler> annotHandler = [self getAnnotHandlerByAnnot:annot];
        if ([annotHandler respondsToSelector:@selector(onAnnot:property:changedFrom:to:)]) {
            [annotHandler onAnnot:annot property:property changedFrom:oldValue to:newValue];
        }

        if([self shouldDrawAnnot:annot]) {
            CGRect rect = [_pdfViewCtrl convertPdfRectToPageViewRect:annot.fsrect pageIndex:pageIndex];
            rect = CGRectUnion(rect, oldRect);
            rect = CGRectInset(rect, -20, -20);
            [_pdfViewCtrl refresh:rect pageIndex:pageIndex];
        }
        
        if (annot.type == e_annotCaret && [(FSMarkup*)annot isGrouped]) {
            for (int i = 0; i < [(FSMarkup*)annot getGroupElementCount]; i ++) {
                FSAnnot* groupAnnot = [(FSMarkup*)annot getGroupElement:i];
                if (groupAnnot && ![groupAnnot.NM isEqualToString:annot.NM]) {
                    [self changeAnnot:groupAnnot property:property from:oldValue to:newValue];
                }
            }
        }
    }
}

-(void)registerAnnotPropertyListener:(id<IAnnotPropertyListener>)listener
{
    [self.annotPropertyListeners addObject:listener];
}

-(void)unregisterAnnotPropertyListener:(id<IAnnotPropertyListener>)listener
{
    if (listener) {
        [self.annotPropertyListeners removeObject:listener];
    }
}

- (void)showSearchBar:(BOOL)show
{
    if(!self.searchControl)
    {
        self.searchControl = [[SearchControl alloc] initWithPDFViewController:_pdfViewCtrl extensionsManager:self];
        [self.searchControl load];
    }
    
    [self.searchControl showSearchBar:show];
}

-(NSString*)getCurrentSelectedText
{
    id<IToolHandler> toolHandler = [self getToolHandlerByName:Tool_Select];
    if(!toolHandler)
        return nil;
    SelectToolHandler* selHandler = (SelectToolHandler*)toolHandler;
    return [selHandler copyText];
}

-(void)stopFormFilling
{
    FormAnnotHandler* formHandler = (FormAnnotHandler*)[self getAnnotHandlerByType:e_annotWidget];
    [formHandler endTextInput];
    [formHandler.formNaviBar setHidden:YES];
}

-(void)exitFormFilling
{
    FormAnnotHandler* formHandler = (FormAnnotHandler*)[self getAnnotHandlerByType:e_annotWidget];
    formHandler.formFiller = nil;
}

#pragma mark - IRecoveryEventListener

- (void)onWillRecover
{
    self.currentAnnot = nil;
    self.currentToolHandler = nil;
}

- (void)onRecovered
{
    [FSLibrary setAnnotIconProvider:_iconProvider];
    [FSLibrary setActionHandler:_actionHandler];
    [FSLibrary registerDefaultSignatureHandler];
}

- (BOOL)shouldDrawAnnot:(FSAnnot *)annot
{
    if (!self.currentAnnot) {
        return YES;
    }
    static enum FS_ANNOTTYPE shouldNotRenderTypes[] = {
        e_annotFreeText,
        e_annotLine,
        e_annotNote,
        e_annotInk,
        e_annotSquare,
        e_annotCircle,
        e_annotStamp,
        e_annotFileAttachment
    };
    if ((self.currentAnnot == annot || [self.currentAnnot.NM isEqualToString:annot.NM])) {
        enum FS_ANNOTTYPE type = annot.type;
        for (int i = 0; i < sizeof(shouldNotRenderTypes) / sizeof(shouldNotRenderTypes[0]); i ++) {
            if (shouldNotRenderTypes[i] == type) {
                if(type == e_annotFreeText)
                {
                    NSString* intent = [((FSMarkup*)annot) getIntent];
                    if(!intent || [intent caseInsensitiveCompare:@"FreeTextTypeWriter"] != NSOrderedSame)
                        return YES;
                }
                return NO;
            }
        }
    }
    if (annot.type == e_annotInk) {
        FSPDFPath* path = [(FSInk*)annot getInkList];
        if ([path getPointCount] <= 1) {
            return NO;
        }
    }
    return YES;
}

# pragma mark UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popOverController = nil;
}

#pragma mark IDocEventListener

- (void)onDocClosed:(FSPDFDoc *)document error:(int)error
{
    _currentAnnot = nil;
    _currentToolHandler = nil;
    [self clearUndoRedo];
    self.menuControl.menuItems  = nil;
}

#pragma mark override FSUndo methods

-(void)undo
{
    if (self.currentAnnot) {
        [self setCurrentAnnot:nil];
    }
    //todel
    if ([[self.currentToolHandler getName] isEqualToString:Tool_Freetext]) {
        [(FtToolHandler*)self.currentToolHandler save];
    }
    [super undo];
}

-(void)redo
{
    if (self.currentAnnot) {
        [self setCurrentAnnot:nil];
    }
    if ([[self.currentToolHandler getName] isEqualToString:Tool_Freetext]) {
        [(FtToolHandler*)self.currentToolHandler save];
    }
    [super redo];
}

@end


@interface ExAnnotIconProviderCallback ()

@property (nonatomic, strong) NSMutableArray* iconDocs;

@end

@implementation ExAnnotIconProviderCallback

-(NSString *)getProviderID
{
    return @"FX";
}

-(NSString *)getProviderVersion
{
    return @"0";
}

-(BOOL)hasIcon: (enum FS_ANNOTTYPE)annotType iconName: (NSString *)iconName
{
    if (annotType == e_annotNote || annotType == e_annotFileAttachment || annotType == e_annotStamp) {
        return YES;
    }
    return NO;
}
-(BOOL)canChangeColor: (enum FS_ANNOTTYPE)annotType iconName: (NSString *)iconName
{
    if (annotType == e_annotNote || annotType == e_annotFileAttachment) {
        return YES;
    }
    return NO;
}

-(FSShadingColor*)getShadingColor: (enum FS_ANNOTTYPE)annotType iconName: (NSString *)iconName refColor: (unsigned int)refColor shadingIndex: (int)shadingIndex;
{
    FSShadingColor* shadingColor = [[FSShadingColor alloc] init];
    [shadingColor set:refColor secondColor:refColor];
    return shadingColor;
}

-(NSNumber*)getDisplayWidth: (enum FS_ANNOTTYPE)annotType iconName: (NSString *)iconName
{
    return [NSNumber numberWithFloat:32];
}

-(NSNumber*)getDisplayHeight: (enum FS_ANNOTTYPE)annotType iconName: (NSString *)iconName
{
    return [NSNumber numberWithFloat:32];
}

-(FSPDFPage*)getIcon: (enum FS_ANNOTTYPE)annotType iconName: (NSString *)iconName color: (unsigned int)color
{
    static NSArray *arrayNames = nil;
    if (!arrayNames) {
        arrayNames = [Utility getAllIconLowercaseNames];
    }
    
    NSInteger iconIndex = -1;
    if (annotType == e_annotNote || annotType == e_annotFileAttachment || annotType == e_annotStamp)
    {
        iconName = [iconName lowercaseString];
        if ([arrayNames containsObject:iconName])
        {
            iconIndex = [arrayNames indexOfObject:iconName];
        }
    }
    
    if (iconIndex >= 0 && iconIndex < arrayNames.count)
    {
        if (!self.iconDocs) {
            self.iconDocs = [NSMutableArray arrayWithCapacity:arrayNames.count];
            for (int i = 0; i < arrayNames.count; i++) {
                [self.iconDocs addObject:[NSNull null]];
            }
        }
        
        FSPDFDoc* iconDoc = self.iconDocs[iconIndex];
        if ([iconDoc isEqual:[NSNull null]]) {
            NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",iconName]];
            iconDoc = [FSPDFDoc createFromFilePath:path];
            enum FS_ERRORCODE err = [iconDoc load:nil];
            if (e_errSuccess == err) {
                self.iconDocs[iconIndex] = iconDoc;
            } else {
                iconDoc = nil;
            }
        }
        return [iconDoc getPage:0];
    }
    
    return nil;
}

@end

int _formCurrentPageIndex = 0;

@implementation ExActionHandler

- (id)initWithPDFViewControl:(FSPDFViewCtrl*)viewctrl
{
    if (self = [super init])
    {
        _pdfViewCtrl = viewctrl;
    }
    return self;
}

-(int)getCurrentPage:(FSPDFDoc*)pdfDoc
{
    if (_pdfViewCtrl.currentDoc == pdfDoc)
        return _formCurrentPageIndex;
    else
        return 0;
}

-(void)setCurrentPage:(FSPDFDoc*)pdfDoc pageIndex:(int)pageIndex
{
    if (_pdfViewCtrl.currentDoc == pdfDoc)
        _formCurrentPageIndex = pageIndex;
}

-(enum FS_ROTATION)getPageRotation:(FSPDFDoc*)pdfDoc pageIndex:(int)pageIndex
{
    return 0;
}

-(BOOL)setPageRotation:(FSPDFDoc*)pdfDoc pageIndex:(int)pageIndex rotation:(enum FS_ROTATION)rotation
{
    return NO;
}

-(int)alert: (NSString *)msg title: (NSString *)title type: (int)type icon: (int)icon
{
    __block int retCode = -1;
    AlertView *alertView = [[AlertView alloc] initWithTitle:title message:msg buttonClickHandler:^(UIView *alertView, int buttonIndex) {
        
        if (type == 0 || type == 4)
        {
            retCode = 1;
        }
        else if (type == 1 )
        {
            if (buttonIndex == 0)
            {
                retCode = 1;
            }
            else
            {
                retCode = 2;
            }
        }
        else if (type == 2)
        {
            if (buttonIndex == 0)
            {
                retCode = 4;
            }
            else
            {
                retCode = 3;
            }
        }
        else if (type == 3)
        {
            if (buttonIndex == 0)
            {
                retCode = 4;
            }
            else if (buttonIndex == 0)
            {
                retCode = 3;
            }
            else
            {
                retCode = 2;
            }
        }
        else
            retCode = 0;
        
    } cancelButtonTitle:nil otherButtonTitles:nil];
    if (type == 0 || type == 4)
    {
        [alertView addButtonWithTitle:NSLocalizedString(@"kOK", nil)];
    }
    else if (type == 1)
    {
        [alertView addButtonWithTitle:NSLocalizedString(@"kOK", nil)];
        [alertView addButtonWithTitle:NSLocalizedString(@"kCancel", nil)];
    }
    else if (type == 2)
    {
        [alertView addButtonWithTitle:NSLocalizedString(@"kYes", nil)];
        [alertView addButtonWithTitle:NSLocalizedString(@"kNo", nil)];
    }
    else if (type == 3)
    {
        [alertView addButtonWithTitle:NSLocalizedString(@"kYes", nil)];
        [alertView addButtonWithTitle:NSLocalizedString(@"kNo", nil)];
        [alertView addButtonWithTitle:NSLocalizedString(@"kCancel", nil)];
    }
    [alertView show];
    
    while (retCode == -1) {
        [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return retCode;
}

-(FSIdentityProperties*)getIdentityProperties
{
    FSIdentityProperties* ip = [[FSIdentityProperties alloc] init];
    [ip setCorporation:@"Foxit"];
    [ip setEmail:@"Foxit"];
    [ip setLoginName:[SettingPreference getAnnotationAuthor]];
    [ip setName:[SettingPreference getAnnotationAuthor]];
    return ip;
}

@end

