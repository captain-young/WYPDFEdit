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

#ifndef UIExtensionsManager_Private_h
#define UIExtensionsManager_Private_h
#import <UIKit/UIKit.h>
#import <FoxitRDK/FSPDFViewControl.h>
#import "Utility/Utility.h"
#import "Property/PropertyBar.h"
#import "UIExtensionsManager.h"
#import "Const.h"
#import "Utility/TaskServer.h"
#import "Utility/Preference.h"
#import "Utility/SettingPreference.h"
#import "FSAnnotExtent.h"
#import "Search/SearchControl.h"

@class MenuControl;
@class ExAnnotIconProviderCallback;
@class ExActionHandler;


/** @brief Private implementation for extension manager, these properites and methods are not supposed to be called. */
@interface UIExtensionsManager() <IDrawEventListener, IPropertyValueChangedListener, IGestureEventListener>
@property (nonatomic, strong) id<IToolHandler> currentToolHandler;
@property (nonatomic, strong) NSMutableArray *annotListeners;
@property (nonatomic, strong) NSMutableArray *toolListeners;
@property (nonatomic, strong) NSMutableArray *searchListeners;
@property (nonatomic, strong) NSMutableArray *toolHandlers;
@property (nonatomic, strong) NSMutableArray *annotHandlers;
@property (nonatomic, assign) int noteIcon;
@property (nonatomic, assign) int attachmentIcon;
@property (nonatomic, assign) int eraserLineWidth;
@property (nonatomic, assign) int stampIcon;
@property (nonatomic, strong) PropertyBar* propertyBar;
@property (nonatomic, strong) SearchControl* searchControl;
@property (nonatomic, strong) TaskServer* taskServer;
@property (nonatomic, strong) MenuControl* menuControl;

@property (nonatomic, strong) ExAnnotIconProviderCallback* iconProvider;
@property (nonatomic, strong) ExActionHandler* actionHandler;

- (void)setCurrentAnnot:(FSAnnot*)anot;
-(unsigned int)getAnnotColor:(enum FS_ANNOTTYPE)annotType;
-(void)setAnnotColor:(unsigned int)color annotType:(enum FS_ANNOTTYPE)annotType;
-(int)getAnnotOpacity:(enum FS_ANNOTTYPE)annotType;
-(void)setAnnotOpacity:(int)opacity annotType:(enum FS_ANNOTTYPE)annotType;
-(int)getAnnotLineWidth:(enum FS_ANNOTTYPE)annotType;
-(void)setAnnotLineWidth:(int)lineWidth annotType:(enum FS_ANNOTTYPE)annotType;
-(int)getAnnotFontSize:(enum FS_ANNOTTYPE)annotType;
-(void)setAnnotFontSize:(int)fontSize annotType:(enum FS_ANNOTTYPE)annotType;
-(NSString*)getAnnotFontName:(enum FS_ANNOTTYPE)annotType;
-(void)setAnnotFontName:(NSString*)fontName annotType:(enum FS_ANNOTTYPE)annotType;
-(int)filterAnnotType:(enum FS_ANNOTTYPE)annotType;
-(id<IAnnotHandler>)getAnnotHandlerByAnnot:(FSAnnot*)annot;

-(void)registerRotateChangedListener:(id<IRotationEventListener>)listener;
-(void)unregisterRotateChangedListener:(id<IRotationEventListener>)listener;

-(void)registerGestureEventListener:(id<IGestureEventListener>)listener;
-(void)unregisterGestureEventListener:(id<IGestureEventListener>)listener;
@end

@interface ExAnnotIconProviderCallback : FSAnnotIconProviderCallback
-(NSString *)getProviderID;
-(NSString *)getProviderVersion;
-(BOOL)hasIcon: (enum FS_ANNOTTYPE)annotType iconName: (NSString *)iconName;
-(BOOL)canChangeColor: (enum FS_ANNOTTYPE)annotType iconName: (NSString *)iconName;
-(FSPDFPage*)getIcon: (enum FS_ANNOTTYPE)annotType iconName: (NSString *)iconName color: (unsigned int)color;
-(FSShadingColor*)getShadingColor: (enum FS_ANNOTTYPE)annotType iconName: (NSString *)iconName refColor: (unsigned int)refColor shadingIndex: (int)shadingIndex;
-(NSNumber*)getDisplayWidth: (enum FS_ANNOTTYPE)annotType iconName: (NSString *)iconName;
-(NSNumber*)getDisplayHeight: (enum FS_ANNOTTYPE)annotType iconName: (NSString *)iconName;
@end

@interface ExActionHandler : FSActionHandler
@property (nonatomic, strong) FSPDFViewCtrl* pdfViewCtrl;

- (id)initWithPDFViewControl:(FSPDFViewCtrl*)viewctrl;
-(int)getCurrentPage:(FSPDFDoc*)pdfDoc;
-(void)setCurrentPage:(FSPDFDoc*)pdfDoc pageIndex:(int)pageIndex;
-(enum FS_ROTATION)getPageRotation:(FSPDFDoc*)pdfDoc pageIndex:(int)pageIndex;
-(BOOL)setPageRotation:(FSPDFDoc*)pdfDoc pageIndex:(int)pageIndex rotation:(enum FS_ROTATION)rotation;
-(int)alert: (NSString *)msg title: (NSString *)title type: (int)type icon: (int)icon;
-(FSIdentityProperties*)getIdentityProperties;
@end

#endif /* UIExtensionsManager_Private_h */
