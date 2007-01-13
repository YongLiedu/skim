// Copyright 1997-2005 Omni Development, Inc.  All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.

#import <OmniFoundation/NSHost-OFExtensions.h>

#import <Foundation/Foundation.h>
#import <OmniBase/OmniBase.h>
#import <OmniBase/system.h>

RCS_ID("$Header: svn+ssh://source.omnigroup.com/Source/svn/Omni/tags/OmniSourceRelease_2006-09-07/OmniGroup/Frameworks/OmniFoundation/OpenStepExtensions.subproj/NSHost-OFExtensions.m 68913 2005-10-03 19:36:19Z kc $")

@implementation NSHost (OFExtensions)

- (NSNumber *)addressNumber
{
    return [NSNumber numberWithUnsignedLong:inet_addr([[self address] cString])];
}

@end
