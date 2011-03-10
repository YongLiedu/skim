//
//  SKBookmarkController.h
//  Skim
//
//  Created by Christiaan Hofman on 3/16/07.
/*
 This software is Copyright (c) 2007
 Christiaan Hofman. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

 - Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

 - Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in
    the documentation and/or other materials provided with the
    distribution.

 - Neither the name of Christiaan Hofman nor the names of any
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
#import "SKOutlineView.h"

@class SKBookmark, SKBookmarkOutlineView, SKStatusBar;

@interface SKBookmarkController : NSWindowController {
    IBOutlet SKBookmarkOutlineView *outlineView;
    IBOutlet SKStatusBar *statusBar;
    NSMutableArray *bookmarks;
    NSMutableArray *recentDocuments;
    NSUndoManager *undoManager;
    NSArray *draggedBookmarks;
    NSMutableDictionary *toolbarItems;
}

+ (id)sharedBookmarkController;

- (NSArray *)bookmarks;
- (void)setBookmarks:(NSArray *)newBookmarks;
- (unsigned)countOfBookmarks;
- (id)objectInBookmarksAtIndex:(unsigned)index;
- (void)insertObject:(id)obj inBookmarksAtIndex:(unsigned)index;
- (void)removeObjectFromBookmarksAtIndex:(unsigned)index;

- (void)addBookmarkForPath:(NSString *)path pageIndex:(unsigned)pageIndex label:(NSString *)label toFolder:(SKBookmark *)folder;
- (void)handleApplicationWillTerminateNotification:(NSNotification *)notification;
- (void)handleBookmarkChangedNotification:(NSNotification *)notification;
- (void)handleBookmarkWillBeRemovedNotification:(NSNotification *)notification;
- (NSString *)bookmarksFilePath;
- (void)openBookmarks:(NSArray *)items;

- (IBAction)doubleClickBookmark:(id)sender;
- (IBAction)insertBookmarkFolder:(id)sender;
- (IBAction)insertBookmarkSeparator:(id)sender;
- (IBAction)deleteBookmark:(id)sender;
- (IBAction)toggleStatusBar:(id)sender;

- (NSArray *)recentDocuments;
- (void)addRecentDocumentForPath:(NSString *)path pageIndex:(unsigned)pageIndex snapshots:(NSArray *)setups;
- (unsigned int)pageIndexForRecentDocumentAtPath:(NSString *)path;
- (NSArray *)snapshotsAtPath:(NSString *)path;

- (NSUndoManager *)undoManager;

- (void)setupToolbar;

@end


@interface SKBookmarkOutlineView : SKOutlineView
@end


@interface NSObject (SKBookmarkOutlineViewDelegate)
- (BOOL)outlineView:(NSOutlineView *)anOutlineView drawSeparatorRowForItem:(id)item;
@end