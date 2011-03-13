//
//  SKColorSwatch.m
//  Skim
//
//  Created by Christiaan Hofman on 7/4/07.
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

#import "SKColorSwatch.h"
#import "OBUtilities.h"

NSString *SKColorSwatchColorsChangedNotification = @"SKColorSwatchColorsChangedNotification";


static void *SKColorsObservationContext = (void *)1091;
static NSString *SKColorsBindingName = @"colors";

@implementation SKColorSwatch

+ (void)initialize {
    OBINITIALIZE;
    
    [self exposeBinding:@"colors"];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        colors = [[NSMutableArray alloc] initWithObjects:[NSColor whiteColor], nil];
        highlightedIndex = -1;
        focusedIndex = 0;
        clickedIndex = -1;
        draggedIndex = -1;
        
        bindingInfo = [[NSMutableDictionary alloc] init];
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSColorPboardType, nil]];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        if ([decoder allowsKeyedCoding]) {
            colors = [[NSMutableArray alloc] initWithArray:[decoder decodeObjectForKey:@"colors"]];
            action = NSSelectorFromString([decoder decodeObjectForKey:@"action"]);
            target = [decoder decodeObjectForKey:@"target"];
        } else {
            colors = [[NSMutableArray alloc] initWithArray:[decoder decodeObject]];
            [decoder decodeValueOfObjCType:@encode(SEL) at:&action];
            target = [decoder decodeObject];
        }
        
        highlightedIndex = -1;
        focusedIndex = 0;
        clickedIndex = -1;
        draggedIndex = -1;
        
        bindingInfo = [[NSMutableDictionary alloc] init];
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSColorPboardType, nil]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    if ([coder allowsKeyedCoding]) {
        [coder encodeObject:colors forKey:@"colors"];
        [coder encodeObject:NSStringFromSelector(action) forKey:@"action"];
        [coder encodeObject:target forKey:@"target"];
    } else {
        [coder encodeObject:colors];
        [coder encodeValueOfObjCType:@encode(SEL) at:action];
        [coder encodeObject:target];
    }
}

- (void)dealloc {
    [self unbind:SKColorsBindingName];
    [colors release];
    [bindingInfo release];
    [super dealloc];
}

- (BOOL)isOpaque{  return YES; }

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent { return YES; }

- (BOOL)acceptsFirstResponder { return YES; }

- (void)sizeToFit {
    NSRect frame = [self frame];
    int count = [colors count];
    frame.size.width = fminf(NSWidth(frame), count * (NSHeight(frame) - 3.0) + 3.0);
    [self setFrame:frame];
}

- (void)drawRect:(NSRect)rect {
    NSRect bounds = [self bounds];
    int count = [colors count];
    
    bounds.size.width = fminf(NSWidth(bounds), count * (NSHeight(bounds) - 3.0) + 3.0);
    
    NSRectEdge sides[4] = {NSMaxYEdge, NSMaxXEdge, NSMinXEdge, NSMinYEdge};
    float grays[4] = {0.5, 0.75, 0.75, 0.75};
    
    rect = NSDrawTiledRects(bounds, rect, sides, grays, 4);
    
    [[NSBezierPath bezierPathWithRect:rect] addClip];
    
    NSRect r = NSMakeRect(1.0, 1.0, NSHeight(rect), NSHeight(rect));
    int i;
    for (i = 0; i < count; i++) {
        NSColor *borderColor = [NSColor colorWithCalibratedWhite:0.66667 alpha:1.0];
        [borderColor set];
        [NSBezierPath strokeRect:NSInsetRect(r, 0.5, 0.5)];
        borderColor = highlightedIndex == i ? [NSColor selectedControlColor] : [NSColor controlBackgroundColor];
        [borderColor set];
        [[NSBezierPath bezierPathWithRect:NSInsetRect(r, 1.5, 1.5)] stroke];
        [[colors objectAtIndex:i] drawSwatchInRect:NSInsetRect(r, 2.0, 2.0)];
        r.origin.x += NSHeight(r) - 1.0;
    }
    
    if ([self refusesFirstResponder] == NO && [NSApp isActive] && [[self window] isKeyWindow] && [[self window] firstResponder] == self && focusedIndex != -1) {
        NSRect rect = NSInsetRect([self bounds], 1.0, 1.0);
        rect.size.width = NSHeight(rect);
        rect.origin.x += focusedIndex * (NSWidth(rect) - 1.0);
        NSSetFocusRingStyle(NSFocusRingOnly);
        NSRectFill(rect);
    }
}

- (void)setKeyboardFocusRingNeedsDisplayInRect:(NSRect)rect {
    [super setKeyboardFocusRingNeedsDisplayInRect:rect];
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    int i = [self colorIndexAtPoint:mouseLoc];
    
    if ([self isEnabled]) {
        highlightedIndex = i;
        [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
        [self setNeedsDisplay:YES];
    }
    
    if (i != -1) {
        BOOL keepOn = YES;
        while (keepOn) {
            theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask];
            switch ([theEvent type]) {
                case NSLeftMouseDragged:
                {
                    if ([self isEnabled]) {
                        highlightedIndex = -1;
                        [self setNeedsDisplay:YES];
                    }
                    
                    draggedIndex = i;
                    
                    NSColor *color = [colors objectAtIndex:i];
                    NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
                    [pboard declareTypes:[NSArray arrayWithObjects:NSColorPboardType, nil] owner:nil];
                    [color writeToPasteboard:pboard];
                    
                    NSRect rect = NSMakeRect(0.0, 0.0, 12.0, 12.0);
                    NSImage *image = [[NSImage alloc] initWithSize:rect.size];
                    [image lockFocus];
                    [[NSColor blackColor] set];
                    [NSBezierPath strokeRect:NSInsetRect(rect, 0.5, 0.5)];
                    [color drawSwatchInRect:NSInsetRect(rect, 1.0, 1.0)];
                    [image unlockFocus];
                    
                    mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
                    mouseLoc.x -= 6.0;
                    mouseLoc.y -= 6.0;
                    [self dragImage:image at:mouseLoc offset:NSZeroSize event:theEvent pasteboard:pboard source:self slideBack:YES];
                    
                    keepOn = NO;
                    break;
                }
                case NSLeftMouseUp:
                    if ([self isEnabled]) {
                        highlightedIndex = -1;
                        clickedIndex = i;
                        [self setNeedsDisplay:YES];
                        [self sendAction:[self action] to:[self target]];
                        clickedIndex = -1;
                    }
                    keepOn = NO;
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)unhighlight {
    highlightedIndex = -1;
    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
    [self setNeedsDisplay:YES];
}

- (void)performClick:(NSEvent *)theEvent {
    if ([self isEnabled] && focusedIndex != -1) {
        clickedIndex = focusedIndex;
        [self sendAction:[self action] to:[self target]];
        clickedIndex = -1;
        highlightedIndex = focusedIndex;
        [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
        [self setNeedsDisplay:YES];
        [self performSelector:@selector(unhighlight) withObject:nil afterDelay:0.2];
    }
}

- (void)moveRight:(NSEvent *)theEvent {
    if (++focusedIndex >= (int)[colors count])
        focusedIndex = [colors count] - 1;
    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
}

- (void)moveLeft:(NSEvent *)theEvent {
    if (--focusedIndex < 0)
        focusedIndex = 0;
    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
}

- (int)colorIndexAtPoint:(NSPoint)point {
    NSRect rect = NSInsetRect([self bounds], 2.0, 2.0);
    
    if (NSPointInRect(point, rect)) {
        int i, count = [colors count];
        
        rect.size.width = NSHeight(rect);
        for (i = 0; i < count; i++) {
            if (NSPointInRect(point, rect))
                return i;
            rect.origin.x += NSWidth(rect) + 1.0;
        }
    }
    return -1;
}

#pragma mark Accessors

- (NSArray *)colors {
    return colors;
}

- (void)setColors:(NSArray *)newColors {
    [colors setArray:newColors];
}

- (int)clickedColorIndex {
    return clickedIndex;
}

- (NSColor *)color {
    int index = clickedIndex;
    return index == -1 ? nil : [colors objectAtIndex:index];
}

- (SEL)action {
    return action;
}

- (void)setAction:(SEL)selector {
    if (selector != action) {
        action = selector;
    }
}

- (id)target {
    return target;
}

- (void)setTarget:(id)newTarget {
    if (target != newTarget) {
        target = newTarget;
    }
}

#pragma mark Binding support

- (void)bind:(NSString *)bindingName toObject:(id)observableController withKeyPath:(NSString *)keyPath options:(NSDictionary *)options {	
    if ([bindingName isEqualToString:SKColorsBindingName]) {
        
        if ([bindingInfo objectForKey:bindingName])
            [self unbind:bindingName];
		
        NSDictionary *bindingsData = [NSDictionary dictionaryWithObjectsAndKeys:observableController, NSObservedObjectKey, [[keyPath copy] autorelease], NSObservedKeyPathKey, [[options copy] autorelease], NSOptionsKey, nil];
		[bindingInfo setObject:bindingsData forKey:bindingName];
        
        [observableController addObserver:self forKeyPath:keyPath options:0 context:SKColorsObservationContext];
        [self observeValueForKeyPath:keyPath ofObject:observableController change:nil context:SKColorsObservationContext];
    } else {
        [super bind:bindingName toObject:observableController withKeyPath:keyPath options:options];
    }
	[self setNeedsDisplay:YES];
}

- (void)unbind:(NSString *)bindingName {
    if ([bindingName isEqualToString:SKColorsBindingName]) {
        
        NSDictionary *info = [self infoForBinding:bindingName];
        [[info objectForKey:NSObservedObjectKey] removeObserver:self forKeyPath:[info objectForKey:NSObservedKeyPathKey]];
		[bindingInfo removeObjectForKey:bindingName];
    } else {
        [super unbind:bindingName];
    }
    [self setNeedsDisplay:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == SKColorsObservationContext) {
        NSDictionary *info = [self infoForBinding:SKColorsBindingName];
		id value = [[info objectForKey:NSObservedObjectKey] valueForKeyPath:[info objectForKey:NSObservedKeyPathKey]];
		if (NSIsControllerMarker(value) == NO) {
            NSString *transformerName = [[info objectForKey:NSOptionsKey] objectForKey:NSValueTransformerNameBindingOption];
            if (transformerName) {
                NSValueTransformer *valueTransformer = [NSValueTransformer valueTransformerForName:transformerName];
                value = [valueTransformer transformedValue:value]; 
            }
            [self setValue:value forKey:SKColorsBindingName];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (NSDictionary *)infoForBinding:(NSString *)bindingName {
	NSDictionary *info = [bindingInfo objectForKey:bindingName];
	if (info == nil)
		info = [super infoForBinding:bindingName];
	return info;
}

#pragma mark NSDraggingDestination protocol 

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSPoint mouseLoc = [self convertPoint:[sender draggingLocation] fromView:nil];
    int i = [self colorIndexAtPoint:mouseLoc];
    
    if ([sender draggingSource] == self && draggedIndex == i)
        i = -1;
    highlightedIndex = i;
    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
    [self setNeedsDisplay:YES];
    if ([self isEnabled] && i != -1)
        return NSDragOperationEvery;
    else
        return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
    return [self draggingEntered:sender];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender {
    highlightedIndex = -1;
    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
    [self setNeedsDisplay:YES];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    NSPoint mouseLoc = [self convertPoint:[sender draggingLocation] fromView:nil];
    int i = [self colorIndexAtPoint:mouseLoc];
    if ([self isEnabled] && i != -1 && ([sender draggingSource] != self || draggedIndex != i))
        return YES;
    else
        return NO;
} 

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender{
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSColor *color = [NSColor colorFromPasteboard:pboard];
    NSPoint mouseLoc = [self convertPoint:[sender draggingLocation] fromView:nil];
    int i = [self colorIndexAtPoint:mouseLoc];
    
    if (i != -1 && color) {
        [colors replaceObjectAtIndex:i withObject:color];
        
        NSDictionary *info = [self infoForBinding:@"colors"];
        id observedObject = [info objectForKey:NSObservedObjectKey];
        NSString *observedKeyPath = [info objectForKey:NSObservedKeyPathKey];
		if (observedObject && observedKeyPath) {
            id value = [[colors copy] autorelease];
            NSString *transformerName = [[info objectForKey:NSOptionsKey] objectForKey:NSValueTransformerNameBindingOption];
            if (transformerName) {
                NSValueTransformer *valueTransformer = [NSValueTransformer valueTransformerForName:transformerName];
                value = [valueTransformer reverseTransformedValue:value]; 
            }
            [observedObject setValue:value forKeyPath:observedKeyPath];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SKColorSwatchColorsChangedNotification object:self];
    }
    
    highlightedIndex = -1;
    [self setNeedsDisplay:YES];
    
	return YES;
}

@end

#pragma mark -

NSString *SKUnarchiveFromDataArrayTransformerName = @"SKUnarchiveFromDataArrayTransformer";

@implementation SKUnarchiveFromDataArrayTransformer

+ (Class)transformedValueClass {
    return [NSArray class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)array {
    NSValueTransformer *unarchiveTransformer = [NSValueTransformer valueTransformerForName:NSUnarchiveFromDataTransformerName];
    NSMutableArray *transformedArray = [NSMutableArray arrayWithCapacity:[array count]];
    NSEnumerator *objEnum = [array objectEnumerator];
    NSData *obj;
    while (obj = [objEnum nextObject])
        [transformedArray addObject:[unarchiveTransformer transformedValue:obj]];
    return transformedArray;
}

- (id)reverseTransformedValue:(id)array {
    NSValueTransformer *unarchiveTransformer = [NSValueTransformer valueTransformerForName:NSUnarchiveFromDataTransformerName];
    NSMutableArray *transformedArray = [NSMutableArray arrayWithCapacity:[array count]];
    NSEnumerator *objEnum = [array objectEnumerator];
    NSData *obj;
    while (obj = [objEnum nextObject])
        [transformedArray addObject:[unarchiveTransformer reverseTransformedValue:obj]];
    return transformedArray;
}

@end