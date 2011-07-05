//
//  SKThumbnail.m
//  Skim
//
//  Created by Christiaan Hofman on 2/16/07.
/*
 This software is Copyright (c) 2007-2009
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

#import "SKThumbnail.h"


@implementation SKThumbnail

- (id)initWithImage:(NSImage *)anImage label:(NSString *)aLabel pageIndex:(NSUInteger)anIndex {
    if (self = [super init]) {
        image = [anImage retain];
        label = [aLabel retain];
        pageIndex = anIndex;
        dirty = NO;
    }
    return self;
}

- (void)dealloc {
    [image release];
    [label release];
    [super dealloc];
}

- (id)delegate { return delegate; }

- (void)setDelegate:(id)newDelegate { delegate = newDelegate; }

- (BOOL)isDirty { return dirty; }

- (void)setDirty:(BOOL)flag { dirty = flag; }

- (void)setImage:(NSImage *)newImage {
    if (image != newImage) {
        [image release];
        image = [newImage retain];
    }
}

- (NSImage *)image {
    if (dirty) {
        NSImage *anImage = [delegate imageForThumbnail:self];
        if (anImage) {
            [self setDirty:NO];
            [self setImage:anImage];
        }
    }
    return image;
}

- (NSString *)label {
    return label;
}

- (NSUInteger)pageIndex {
    return pageIndex;
}

- (NSSize)size {
    return [image size];
}

@end