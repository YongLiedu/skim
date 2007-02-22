//
//  SKMainWindowController.h
//  This code is licensed under a BSD license. Please see the file LICENSE for details.
//
//  Created by Michael McCracken on 12/6/06.
//  Copyright 2006 Michael O. McCracken. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum _SKLeftSidePaneState {
    SKThumbnailSidePaneState,
    SKOutlineSidePaneState
} SKLeftSidePaneState;

typedef enum _SKRightSidePaneState {
    SKNoteSidePaneState,
    SKSnapshotSidePaneState
} SKRightSidePaneState;

typedef struct _SKPDFViewState {
	int displayMode;
	BOOL autoScales;
	float scaleFactor;
	BOOL hasHorizontalScroller;
	BOOL hasVerticalScroller;
	BOOL autoHidesScrollers;
} SKPDFViewState;

@class SKPDFView, PDFOutline, BDSKCollapsibleView, BDSKEdgeView, SKFullScreenWindow, SKNavigationWindow, SKSideWindow, SKSnapshotWindowController, SKSplitView;

@interface SKNoteTableView : NSTableView
- (void)delete:(id)sender;
@end

@interface SKSnapshotTableView : SKNoteTableView
@end

@interface SKThumbnailTableView : NSTableView
@end

@interface SKOutlineView : NSOutlineView
@end

@interface SKMainWindowController : NSWindowController {
    IBOutlet SKPDFView          *pdfView;
    IBOutlet BDSKEdgeView       *pdfContentBox;
    
    IBOutlet SKSplitView        *splitView;
    IBOutlet NSBox              *leftSideContentBox;
    IBOutlet NSBox              *leftSideBox;
    IBOutlet BDSKEdgeView       *leftSideEdgeView;
    IBOutlet NSBox              *rightSideContentBox;
    IBOutlet NSBox              *rightSideBox;
    IBOutlet BDSKEdgeView       *rightSideEdgeView;
    
    IBOutlet NSOutlineView      *outlineView;
    PDFOutline                  *pdfOutline;
    BOOL                        updatingOutlineSelection;
    
    IBOutlet NSSearchField      *findField;
    
    IBOutlet NSArrayController  *noteArrayController;
    IBOutlet SKNoteTableView   *noteTableView;
    BOOL                        updatingNoteSelection;
    
    IBOutlet NSSegmentedControl *backForwardButton;
    IBOutlet NSView             *pageNumberView;
    IBOutlet NSStepper          *pageNumberStepper;
    IBOutlet NSTextField        *pageNumberField;
    IBOutlet NSSegmentedControl *toolModeButton;
    IBOutlet NSSegmentedControl *annotationModeButton;
    IBOutlet NSTextField        *scaleField;
    IBOutlet NSPopUpButton      *displayBoxPopUpButton;
    IBOutlet NSSearchField      *searchField;
    IBOutlet BDSKCollapsibleView  *searchBox;
    NSMutableDictionary         *toolbarItems;
    
    IBOutlet NSSegmentedControl *leftSideButton;
    IBOutlet NSSegmentedControl *rightSideButton;
    
    IBOutlet NSWindow           *choosePageSheet;
    IBOutlet NSTextField        *choosePageField;
    
    NSWindow                    *mainWindow;
    SKFullScreenWindow          *fullScreenWindow;
    SKSideWindow                *leftSideWindow;
    SKSideWindow                *rightSideWindow;
    
    BOOL                        isPresentation;
    SKPDFViewState              savedState;
    
    IBOutlet NSTableView        *currentTableView;
    SKLeftSidePaneState         leftSidePaneState;
    SKRightSidePaneState        rightSidePaneState;
    
    IBOutlet NSTableView        *findTableView;
    NSMutableArray              *searchResults;
    IBOutlet NSArrayController  *findArrayController;
    IBOutlet NSProgressIndicator *spinner;
    
    IBOutlet NSArrayController  *thumbnailArrayController;
    IBOutlet SKThumbnailTableView *thumbnailTableView;
    NSMutableArray              *thumbnails;
    BOOL                        updatingThumbnailSelection;
    NSMutableIndexSet           *dirtyThumbnailIndexes;
    NSTimer                     *thumbnailTimer;
    
    NSMutableIndexSet           *dirtySnapshotIndexes;
    NSTimer                     *snapshotTimer;
    
    IBOutlet NSArrayController  *snapshotArrayController;
    IBOutlet SKSnapshotTableView *snapshotTableView;
    NSMutableArray              *snapshots;
    
    float                       lastLeftSidePaneWidth;
    float                       lastRightSidePaneWidth;
    
    float                       thumbnailCacheSize;
    float                       snapshotCacheSize;
    
    BOOL                        edited;
    
    BOOL                        findPanelFind;
    
    IBOutlet NSWindow           *saveProgressSheet;
    IBOutlet NSProgressIndicator *saveProgressBar;
    
    NSMutableArray *lastViewedPages;
}

- (IBAction)pickColor:(id)sender;
- (IBAction)changeColor:(id)sender;
- (IBAction)createNewNote:(id)sender;
- (IBAction)displaySinglePages:(id)sender;
- (IBAction)displayFacingPages:(id)sender;
- (IBAction)toggleDisplayContinuous:(id)sender;
- (IBAction)toggleDisplayAsBook:(id)sender;
- (IBAction)toggleDisplayPageBreaks:(id)sender;
- (IBAction)displayMediaBox:(id)sender;
- (IBAction)displayCropBox:(id)sender;
- (IBAction)changeDisplayBox:(id)sender;
- (IBAction)doGoToNextPage:(id)sender;
- (IBAction)doGoToPreviousPage:(id)sender;
- (IBAction)doGoToPage:(id)sender;
- (IBAction)dismissChoosePageSheet:(id)sender;
- (IBAction)doGoBack:(id)sender;
- (IBAction)doGoForward:(id)sender;
- (IBAction)goBackOrForward:(id)sender;
- (IBAction)doZoomIn:(id)sender;
- (IBAction)doZoomOut:(id)sender;
- (IBAction)doZoomToActualSize:(id)sender;
- (IBAction)doZoomToFit:(id)sender;
- (IBAction)toggleZoomToFit:(id)sender;
- (IBAction)rotateRight:(id)sender;
- (IBAction)rotateLeft:(id)sender;
- (IBAction)rotateAllRight:(id)sender;
- (IBAction)rotateAllLeft:(id)sender;
- (IBAction)getInfo:(id)sender;
- (IBAction)search:(id)sender;
- (IBAction)changeScaleFactor:(id)sender;
- (IBAction)changeToolMode:(id)sender;
- (IBAction)changeAnnotationMode:(id)sender;
- (IBAction)toggleLeftSidePane:(id)sender;
- (IBAction)toggleRightSidePane:(id)sender;
- (IBAction)changeLeftSidePaneState:(id)sender;
- (IBAction)changeRightSidePaneState:(id)sender;
- (IBAction)enterFullScreen:(id)sender;
- (IBAction)exitFullScreen:(id)sender;
- (IBAction)toggleFullScreen:(id)sender;
- (IBAction)toggleFullScreen:(id)sender;
- (IBAction)enterPresentation:(id)sender;
- (IBAction)togglePresentation:(id)sender;

- (void)showSnapshotAtPageNumber:(int)pageNum forRect:(NSRect)rect;
- (void)showSnapshots:(NSArray *)snapshotToShow;
- (void)showNote:(PDFAnnotation *)annotation;

- (PDFView *)pdfView;

- (PDFDocument *)pdfDocument;
- (void)setPdfDocument:(PDFDocument *)document;

- (unsigned int)pageNumber;
- (void)setPageNumber:(unsigned int)pageNumber;

- (BOOL)isFullScreen;
- (BOOL)isPresentation;

- (BOOL)autoScales;

- (SKLeftSidePaneState)leftSidePaneState;
- (void)setLeftSidePaneState:(SKLeftSidePaneState)newLeftSidePaneState;
- (SKRightSidePaneState)rightSidePaneState;
- (void)setRightSidePaneState:(SKRightSidePaneState)newRightSidePaneState;

- (void)displayOutlineView;
- (void)fadeInOutlineView;
- (void)displayThumbnailView;
- (void)fadeInThumbnailView;
- (void)displaySearchView;
- (void)fadeInSearchView;
- (void)displayNoteView;
- (void)fadeInNoteView;
- (void)displaySnapshotView;
- (void)fadeInSnapshotView;

- (void)removeTemporaryAnnotations;

- (void)updateOutlineSelection;
- (void)updateNoteSelection;

- (void)updateThumbnailSelection;
- (void)resetThumbnails;
- (void)resetThumbnailSizeIfNeeded;
- (void)thumbnailAtIndexNeedsUpdate:(unsigned)index;
- (void)thumbnailsAtIndexesNeedUpdate:(NSIndexSet *)indexes;
- (void)updateThumbnailsIfNeeded;
- (void)updateThumbnail:(NSTimer *)timer;

- (void)resetSnapshotSizeIfNeeded;
- (void)snapshotAtIndexNeedsUpdate:(unsigned)index;
- (void)snapshotsAtIndexesNeedUpdate:(NSIndexSet *)indexes;
- (void)updateSnapshotsIfNeeded;
- (void)updateSnapshot:(NSTimer *)timer;

- (void)registerForNotifications;
- (void)registerForDocumentNotifications;
- (void)unregisterForDocumentNotifications;
- (void)registerAsObserver;
- (void)unregisterForChangeNotification;

- (void)handleApplicationWillTerminateNotification:(NSNotification *)notification;
- (void)handlePageChangedNotification:(NSNotification *)notification;
- (void)handleScaleChangedNotification:(NSNotification *)notification;
- (void)handleChangedHistoryNotification:(NSNotification *)notification;
- (void)handleDidChangeActiveAnnotationNotification:(NSNotification *)notification;
- (void)handleDidAddAnnotationNotification:(NSNotification *)notification;
- (void)handleDidRemoveAnnotationNotification:(NSNotification *)notification;
- (void)handleDidChangeAnnotationNotification:(NSNotification *)notification;
- (void)handleDoubleClickedAnnotationNotification:(NSNotification *)notification;
- (void)handleDocumentBeginWrite:(NSNotification *)notification;
- (void)handleDocumentEndWrite:(NSNotification *)notification;
- (void)handleDocumentEndPageWrite:(NSNotification *)notification;

- (void)setAnnotationsFromDictionaries:(NSArray *)noteDicts;

- (void)setupWindow:(NSDictionary *)setup;
- (NSDictionary *)currentSetup;

- (void)setupToolbar;

@end


@interface NSObject (SKNoteTableViewDelegate)
- (void)tableView:(NSTableView *)aTableView deleteRowsWithIndexes:(NSIndexSet *)rowIndexes;
@end


@interface NSObject (SKThumbnailTableViewDelegate)
- (NSArray *)tableViewHighlightedRows:(NSTableView *)tableView;
@end


@interface NSObject (SKOutlineViewDelegate)
- (NSArray *)outlineViewHighlightedRows:(NSOutlineView *)anOutlineView;
@end


@interface NSUserDefaultsController (SKExtensions)
- (void)addObserver:(NSObject *)anObserver forKey:(NSString *)key;
- (void)removeObserver:(NSObject *)anObserver forKey:(NSString *)key;
@end
