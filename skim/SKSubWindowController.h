//
//  SKSubWindowController.h


//  This code is licensed under a BSD license. Please see the file LICENSE for details.
//
//  Created by Michael McCracken on 12/6/06.
//  Copyright 2006 Michael O. McCracken. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class PDFView, PDFDocument;

@interface SKSubWindowController : NSWindowController {
    IBOutlet PDFView* pdfView;
}
- (void)setPdfDocument:(PDFDocument *)pdfDocument scaleFactor:(float)factor goToPageNumber:(int)pageNum rect:(NSRect)rect;
- (PDFView *)pdfView;
- (NSRect)rectForThumbnail;
- (NSImage *)thumbnailWithSize:(float)size shadowBlurRadius:(float)shadowBlurRadius shadowOffset:(NSSize)shadowOffset;
- (void)handlePageChangedNotification;
@end


@interface SKSubWindow : NSWindow
@end
