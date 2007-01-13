// Copyright 1997-2005 Omni Development, Inc.  All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.

#import <OmniFoundation/OFStringScanner.h>

#import <Foundation/Foundation.h>
#import <OmniBase/OmniBase.h>

RCS_ID("$Header: svn+ssh://source.omnigroup.com/Source/svn/Omni/tags/OmniSourceRelease_2006-09-07/OmniGroup/Frameworks/OmniFoundation/OFStringScanner.m 68913 2005-10-03 19:36:19Z kc $")

@implementation OFStringScanner

- initWithString:(NSString *)aString;
{
    if ([super init] == nil)
	return nil;

    targetString = [aString retain];
    [self fetchMoreDataFromString:aString];

    return self;
}

- (void)dealloc;
{
    [targetString release];
    [super dealloc];
}

@end


