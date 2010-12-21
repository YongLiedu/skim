//
//  SKMainWindowController.h
//  Skim
//
//  Created by Michael McCracken on 12/6/06.
/*
 This software is Copyright (c) 2006-2008
 Michael O. McCracken. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

 - Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

 - Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in
    the documentation and/or other materials provided with the
    distribution.

 - Neither the name of Michael O. McCracken nor the names of any
    contributors may be used to endorse or promote products derived
    from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Cocoa/Cocoa.h>

enum {
    SKThumbnailSidePaneState,
    SKOutlineSidePaneState
};
typedef NSInteger SKLeftSidePaneState;

enum {
    SKNoteSidePaneState,
    SKSnapshotSidePaneState
};
typedef NSInteger SKRightSidePaneState;

enum {
    SKSingularFindPaneState,
    SKGroupedFindPaneState
};
typedef NSInteger SKFindPaneState;

enum {
    SKDefaultWindowOption,
    SKMaximizeWindowOption,
    SKFitWindowOption
};

typedef struct _SKPDFViewState {
	int displayMode;
	BOOL autoScales;
	float scaleFactor;
	BOOL hasHorizontalScroller;
	BOOL hasVerticalScroller;
	BOOL autoHidesScrollers;
} SKPDFViewState;

extern NSString *SKMainWindowPageLabelsKey;
extern NSString *SKMainWindowSearchResultsKey;
extern NSString *SKMainWindowGroupedSearchResultsKey;
extern NSString *SKMainWindowNotesKey;
extern NSString *SKMainWindowThumbnailsKey;
extern NSString *SKMainWindowSnapshotsKey;

extern NSString *SKLeftSidePaneWidthKey;
extern NSString *SKRightSidePaneWidthKey;

extern NSString *SKMainWindowPageColumnIdentifer;

@class PDFOutline, SKThumbnail;
@class SKPDFView, SKSecondaryPDFView, SKTocOutlineView, SKNoteOutlineView, SKThumbnailTableView, SKSnapshotTableView, SKSplitView, BDSKCollapsibleView, BDSKEdgeView, BDSKGradientView, SKColorSwatch, SKStatusBar;
@class SKFullScreenWindow, SKNavigationWindow, SKSideWindow, SKSnapshotWindowController, SKProgressController, SKPageSheetController, SKScaleSheetController, SKPasswordSheetController, SKBookmarkSheetController;

@interface SKMainWindowController : NSWindowController {
    IBOutlet SKSplitView        *splitView;
    
    IBOutlet SKSplitView        *pdfSplitView;
    IBOutlet BDSKEdgeView       *pdfEdgeView;
    IBOutlet SKPDFView          *pdfView;
    
    BDSKEdgeView                *secondaryPdfEdgeView;
    SKSecondaryPDFView          *secondaryPdfView;
    
    IBOutlet NSView             *leftSideContentView;
    IBOutlet NSView             *leftSideView;
    IBOutlet BDSKEdgeView       *leftSideEdgeView;
    IBOutlet BDSKCollapsibleView *leftSideCollapsibleView;
    IBOutlet BDSKGradientView   *leftSideGradientView;
    IBOutlet NSSegmentedControl *leftSideButton;
    IBOutlet NSSearchField      *searchField;
    
    IBOutlet NSView             *rightSideContentView;
    IBOutlet NSView             *rightSideView;
    IBOutlet BDSKEdgeView       *rightSideEdgeView;
    IBOutlet BDSKCollapsibleView *rightSideCollapsibleView;
    IBOutlet BDSKGradientView   *rightSideGradientView;
    IBOutlet NSSegmentedControl *rightSideButton;
    IBOutlet NSSearchField      *noteSearchField;
    
    IBOutlet NSView             *currentLeftSideView;
    IBOutlet NSView             *currentRightSideView;
    SKLeftSidePaneState         leftSidePaneState;
    SKRightSidePaneState        rightSidePaneState;
    SKLeftSidePaneState         savedLeftSidePaneState;
    
    SKStatusBar                 *statusBar;
    
    IBOutlet SKTocOutlineView   *outlineView;
    IBOutlet NSView             *tocView;
    PDFOutline                  *pdfOutline;
    NSMutableArray              *pdfOutlineItems;
    BOOL                        updatingOutlineSelection;
    
    IBOutlet NSObjectController *ownerController;
    IBOutlet NSArrayController  *thumbnailArrayController;
    IBOutlet SKThumbnailTableView *thumbnailTableView;
    IBOutlet NSView             *thumbnailView;
    NSMutableArray              *thumbnails;
    BOOL                        updatingThumbnailSelection;
    float                       roundedThumbnailSize;
    BOOL                        isAnimating;
    
    IBOutlet NSArrayController  *findArrayController;
    IBOutlet NSTableView        *findTableView;
    IBOutlet NSView             *findView;
    NSMutableArray              *searchResults;
    BOOL                        findPanelFind;
    BOOL                        caseInsensitiveSearch;
    BOOL                        wholeWordSearch;
    CFMutableSetRef             temporaryAnnotations;
    NSTimer                     *temporaryAnnotationTimer;
    NSTimer                     *highlightTimer;
    
    IBOutlet NSArrayController  *groupedFindArrayController;
    IBOutlet NSTableView        *groupedFindTableView;
    IBOutlet NSView             *groupedFindView;
    NSMutableArray              *groupedSearchResults;
    IBOutlet NSSegmentedControl *findButton;
    SKFindPaneState             findPaneState;
    
    IBOutlet NSArrayController  *noteArrayController;
    IBOutlet SKNoteOutlineView  *noteOutlineView;
    IBOutlet NSView             *noteView;
    NSMutableArray              *notes;
    CFMutableDictionaryRef      rowHeights;
    BOOL                        updatingNoteSelection;
    
    IBOutlet NSArrayController  *snapshotArrayController;
    IBOutlet SKSnapshotTableView *snapshotTableView;
    IBOutlet NSView             *snapshotView;
    NSMutableArray              *snapshots;
    NSMutableArray              *dirtySnapshots;
    NSTimer                     *snapshotTimer;
    float                       roundedSnapshotThumbnailSize;
    
    NSWindow                    *mainWindow;
    SKFullScreenWindow          *fullScreenWindow;
    SKSideWindow                *leftSideWindow;
    SKSideWindow                *rightSideWindow;
    NSMutableArray              *blankingWindows;
    
    IBOutlet NSSegmentedControl *backForwardButton;
    IBOutlet NSTextField        *pageNumberField;
    IBOutlet NSSegmentedControl *previousNextPageButton;
    IBOutlet NSSegmentedControl *previousPageButton;
    IBOutlet NSSegmentedControl *nextPageButton;
    IBOutlet NSSegmentedControl *previousNextFirstLastPageButton;
    IBOutlet NSSegmentedControl *zoomInOutButton;
    IBOutlet NSSegmentedControl *zoomInActualOutButton;
    IBOutlet NSSegmentedControl *zoomActualButton;
    IBOutlet NSSegmentedControl *zoomFitButton;
    IBOutlet NSSegmentedControl *zoomSelectionButton;
    IBOutlet NSSegmentedControl *rotateLeftButton;
    IBOutlet NSSegmentedControl *rotateRightButton;
    IBOutlet NSSegmentedControl *rotateLeftRightButton;
    IBOutlet NSSegmentedControl *cropButton;
    IBOutlet NSSegmentedControl *fullScreenButton;
    IBOutlet NSSegmentedControl *presentationButton;
    IBOutlet NSSegmentedControl *leftPaneButton;
    IBOutlet NSSegmentedControl *rightPaneButton;
    IBOutlet NSSegmentedControl *toolModeButton;
    IBOutlet NSSegmentedControl *textNoteButton;
    IBOutlet NSSegmentedControl *circleNoteButton;
    IBOutlet NSSegmentedControl *markupNoteButton;
    IBOutlet NSSegmentedControl *lineNoteButton;
    IBOutlet NSSegmentedControl *singleTwoUpButton;
    IBOutlet NSSegmentedControl *continuousButton;
    IBOutlet NSSegmentedControl *displayModeButton;
    IBOutlet NSSegmentedControl *displayBoxButton;
    IBOutlet NSSegmentedControl *infoButton;
    IBOutlet NSSegmentedControl *colorsButton;
    IBOutlet NSSegmentedControl *fontsButton;
    IBOutlet NSSegmentedControl *linesButton;
    IBOutlet NSSegmentedControl *printButton;
    IBOutlet NSSegmentedControl *customizeButton;
    IBOutlet NSTextField        *scaleField;
    IBOutlet NSSegmentedControl *noteButton;
    IBOutlet SKColorSwatch      *colorSwatch;
    NSMutableDictionary         *toolbarItems;
    
    SKPageSheetController       *pageSheetController;
    SKScaleSheetController      *scaleSheetController;
    SKPasswordSheetController   *passwordSheetController;
    SKBookmarkSheetController   *bookmarkSheetController;
    
    SKProgressController        *progressController;
    
    NSButton                    *colorAccessoryView;
    BOOL                        updatingColor;
    BOOL                        updatingFont;
    BOOL                        updatingFontAttributes;
    BOOL                        updatingLine;
    
    BOOL                        settingUpWindow;
    
    NSMutableArray              *pageLabels;
    
    NSString                    *pageLabel;
    unsigned int                pageNumber;
    
    unsigned int                markedPageIndex;
    unsigned int                beforeMarkedPageIndex;
    
    NSMutableArray              *lastViewedPages;
    
    NSTimer                     *activityTimer;
    
    BOOL                        isPresentation;
    NSMutableDictionary         *savedNormalSetup;
    
    float                       lastLeftSidePaneWidth;
    float                       lastRightSidePaneWidth;
    float                       lastSecondaryPdfViewPaneHeight;
    
    float                       thumbnailCacheSize;
    float                       snapshotCacheSize;
    
    NSDrawer                    *leftSideDrawer;
    NSDrawer                    *rightSideDrawer;
    BOOL                        usesDrawers;
    
    NSMutableDictionary         *undoGroupOldPropertiesPerNote;
}

- (IBAction)changeColor:(id)sender;
- (IBAction)changeColorFill:(id)sender;
- (IBAction)selectColor:(id)sender;
- (IBAction)changeFont:(id)sender;
- (IBAction)createNewNote:(id)sender;
- (IBAction)createNewTextNote:(id)sender;
- (IBAction)createNewCircleNote:(id)sender;
- (IBAction)createNewMarkupNote:(id)sender;
- (IBAction)createNewLineNote:(id)sender;
- (IBAction)editNote:(id)sender;
- (IBAction)toggleHideNotes:(id)sender;
- (IBAction)takeSnapshot:(id)sender;
- (IBAction)displaySinglePages:(id)sender;
- (IBAction)displayFacingPages:(id)sender;
- (IBAction)changeDisplaySinglePages:(id)sender;
- (IBAction)toggleDisplayContinuous:(id)sender;
- (IBAction)changeDisplayContinuous:(id)sender;
- (IBAction)changeDisplayMode:(id)sender;
- (IBAction)toggleDisplayAsBook:(id)sender;
- (IBAction)toggleDisplayPageBreaks:(id)sender;
- (IBAction)changeDisplayBox:(id)sender;
- (IBAction)doGoToNextPage:(id)sender;
- (IBAction)doGoToPreviousPage:(id)sender;
- (IBAction)doGoToFirstPage:(id)sender;
- (IBAction)doGoToLastPage:(id)sender;
- (IBAction)allGoToNextPage:(id)sender;
- (IBAction)allGoToPreviousPage:(id)sender;
- (IBAction)allGoToFirstPage:(id)sender;
- (IBAction)allGoToLastPage:(id)sender;
- (IBAction)goToPreviousNextFirstLastPage:(id)sender;
- (IBAction)doGoToPage:(id)sender;
- (IBAction)doGoBack:(id)sender;
- (IBAction)doGoForward:(id)sender;
- (IBAction)goBackOrForward:(id)sender;
- (IBAction)goToMarkedPage:(id)sender;
- (IBAction)markPage:(id)sender;
- (IBAction)doZoomIn:(id)sender;
- (IBAction)doZoomOut:(id)sender;
- (IBAction)doZoomToActualSize:(id)sender;
- (IBAction)doZoomToPhysicalSize:(id)sender;
- (IBAction)doZoomToFit:(id)sender;
- (IBAction)alternateZoomToFit:(id)sender;
- (IBAction)doZoomToSelection:(id)sender;
- (IBAction)zoomInActualOut:(id)sender;
- (IBAction)doAutoScale:(id)sender;
- (IBAction)toggleAutoScale:(id)sender;
- (IBAction)toggleAutoActualSize:(id)sender;
- (IBAction)rotateRight:(id)sender;
- (IBAction)rotateLeft:(id)sender;
- (IBAction)rotateAllRight:(id)sender;
- (IBAction)rotateAllLeft:(id)sender;
- (IBAction)rotateAllLeftRight:(id)sender;
- (IBAction)crop:(id)sender;
- (IBAction)cropAll:(id)sender;
- (IBAction)autoCropAll:(id)sender;
- (IBAction)smartAutoCropAll:(id)sender;
- (IBAction)autoSelectContent:(id)sender;
- (IBAction)getInfo:(id)sender;
- (void)displaySearchResultsForString:(NSString *)string;
- (IBAction)search:(id)sender;
- (IBAction)searchNotes:(id)sender;
- (IBAction)changeScaleFactor:(id)sender;
- (IBAction)chooseScale:(id)sender;
- (IBAction)changeToolMode:(id)sender;
- (IBAction)changeAnnotationMode:(id)sender;
- (IBAction)toggleLeftSidePane:(id)sender;
- (IBAction)toggleRightSidePane:(id)sender;
- (IBAction)changeLeftSidePaneState:(id)sender;
- (IBAction)changeRightSidePaneState:(id)sender;
- (IBAction)changeFindPaneState:(id)sender;
- (IBAction)toggleStatusBar:(id)sender;
- (IBAction)toggleSplitPDF:(id)sender;
- (IBAction)toggleReadingBar:(id)sender;
- (IBAction)searchPDF:(id)sender;
- (IBAction)enterFullScreen:(id)sender;
- (IBAction)exitFullScreen:(id)sender;
- (IBAction)toggleFullScreen:(id)sender;
- (IBAction)enterPresentation:(id)sender;
- (IBAction)togglePresentation:(id)sender;
- (IBAction)performFit:(id)sender;
- (IBAction)password:(id)sender;
- (IBAction)savePDFSettingToDefaults:(id)sender;
- (IBAction)chooseTransition:(id)sender;
- (IBAction)toggleCaseInsensitiveSearch:(id)sender;
- (IBAction)toggleWholeWordSearch:(id)sender;

- (void)showSnapshotAtPageNumber:(int)pageNum forRect:(NSRect)rect scaleFactor:(float)scaleFactor autoFits:(BOOL)autoFits;
- (void)showSnapshotWithSetups:(NSArray *)setups;
- (void)toggleSnapshots:(NSArray *)snapshotArray;
- (void)showNote:(PDFAnnotation *)annotation;

- (SKPDFView *)pdfView;

- (PDFDocument *)pdfDocument;
- (void)setPdfDocument:(PDFDocument *)document;

- (NSArray *)notes;
- (void)setNotes:(NSArray *)newNotes;
- (unsigned)countOfNotes;
- (id)objectInNotesAtIndex:(unsigned)index;
- (void)insertObject:(id)obj inNotesAtIndex:(unsigned)index;
- (void)removeObjectFromNotesAtIndex:(unsigned)index;

- (unsigned)countOfThumbnails;
- (id)objectInThumbnailsAtIndex:(unsigned)theIndex;
- (void)insertObject:(id)obj inThumbnailsAtIndex:(unsigned)theIndex;
- (void)removeObjectFromThumbnailsAtIndex:(unsigned)theIndex;

- (NSArray *)snapshots;
- (void)setSnapshots:(NSArray *)newSnapshots;
- (unsigned)countOfSnapshots;
- (id)objectInSnapshotsAtIndex:(unsigned)theIndex;
- (void)insertObject:(id)obj inSnapshotsAtIndex:(unsigned)theIndex;
- (void)removeObjectFromSnapshotsAtIndex:(unsigned)theIndex;

- (NSArray *)selectedNotes;

- (unsigned int)pageNumber;
- (void)setPageNumber:(unsigned int)pageNumber;
- (NSString *)pageLabel;
- (void)setPageLabel:(NSString *)label;

- (BOOL)isFullScreen;
- (BOOL)isPresentation;

- (BOOL)autoScales;

- (SKLeftSidePaneState)leftSidePaneState;
- (void)setLeftSidePaneState:(SKLeftSidePaneState)newLeftSidePaneState;
- (SKRightSidePaneState)rightSidePaneState;
- (void)setRightSidePaneState:(SKRightSidePaneState)newRightSidePaneState;
- (SKFindPaneState)findPaneState;
- (void)setFindPaneState:(SKFindPaneState)newFindPaneState;

- (BOOL)leftSidePaneIsOpen;
- (BOOL)rightSidePaneIsOpen;

- (void)closeSideWindow:(SKSideWindow *)sideWindow;

- (void)displayOutlineView;
- (void)fadeInOutlineView;
- (void)displayThumbnailView;
- (void)fadeInThumbnailView;
- (void)displaySearchView;
- (void)fadeInSearchView;
- (void)displayGroupedSearchView;
- (void)fadeInGroupedSearchView;
- (void)displayNoteView;
- (void)displaySnapshotView;

- (void)removeTemporaryAnnotations;
- (void)addTemporaryAnnotationForPoint:(NSPoint)point onPage:(PDFPage *)page;

- (PDFSelection *)findString:(NSString *)string fromSelection:(PDFSelection *)selection withOptions:(int)options;

- (int)outlineRowForPageIndex:(unsigned int)pageIndex;
- (void)updateOutlineSelection;

- (void)updateNoteSelection;

- (void)addNote:(PDFAnnotation *)note;
- (void)removeNote:(PDFAnnotation *)note;

- (void)updateThumbnailSelection;
- (void)resetThumbnails;
- (void)resetThumbnailSizeIfNeeded;
- (void)updateThumbnailAtPageIndex:(unsigned)index;
- (void)allThumbnailsNeedUpdate;

- (void)resetSnapshotSizeIfNeeded;
- (void)snapshotNeedsUpdate:(SKSnapshotWindowController *)dirstySnapshot;
- (void)allSnapshotsNeedUpdate;
- (void)updateSnapshotsIfNeeded;
- (void)updateSnapshot:(NSTimer *)timer;

- (IBAction)addBookmark:(id)sender;

- (void)addAnnotationsFromDictionaries:(NSArray *)noteDicts undoable:(BOOL)undoable;
- (void)setAnnotationsFromDictionaries:(NSArray *)noteDicts undoable:(BOOL)undoable;

- (void)setInitialSetup:(NSDictionary *)setup;
- (NSDictionary *)currentSetup;
- (void)applyPDFSettings:(NSDictionary *)setup;
- (NSDictionary *)currentPDFSettings;

@end