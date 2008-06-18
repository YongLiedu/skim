//
//  SKNExtendedAttributeManager.m
//
//  Created by Adam R. Maxwell on 05/12/05.
//  Copyright 2005-2008 Adam R. Maxwell. All rights reserved.
//
/*
 
 Redistribution and use in source and binary forms, with or without modification, 
 are permitted provided that the following conditions are met:
 - Redistributions of source code must retain the above copyright notice, this 
 list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or 
 other materials provided with the distribution.
 - Neither the name of Adam R. Maxwell nor the names of any contributors may be
 used to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <SkimNotes/SKNExtendedAttributeManager.h>
#include <sys/xattr.h>
#import "bzlib.h"

#ifndef SKNLocalizedString
#define SKNLocalizedString(key, comment) key
#endif

#define MAX_XATTR_LENGTH    2048
#define UNIQUE_VALUE        [[NSProcessInfo processInfo] globallyUniqueString]
#define NAME_PREFIX         @"net_sourceforge_skim-app_"
#define UNIQUE_KEY          @"net_sourceforge_skim-app_unique_key"
#define WRAPPER_KEY         @"net_sourceforge_skim-app_has_wrapper"
#define FRAGMENTS_KEY       @"net_sourceforge_skim-app_number_of_fragments"

static NSString *SKNErrorDomain = @"SKNErrorDomain";

@interface SKNExtendedAttributeManager (SKNPrivate)
// private methods to (un)compress data
- (NSData *)bzip2:(NSData *)data;
- (NSData *)bunzip2:(NSData *)data;
// private method to print error messages
- (NSError *)xattrError:(int)err forPath:(NSString *)path;
@end


@implementation SKNExtendedAttributeManager

static id sharedManager = nil;

+ (id)sharedManager;
{
    if (sharedManager == nil)
        sharedManager = [[[self class] alloc] init];
    return sharedManager;
}

- (id)init;
{
    self = [super init];
    if (sharedManager) {
        [self release];
        self = [sharedManager retain];
    } else {
        sharedManager = self;
    }
    return self;
}

- (NSArray *)extendedAttributeNamesAtPath:(NSString *)path traverseLink:(BOOL)follow error:(NSError **)error;
{
    const char *fsPath = [path fileSystemRepresentation];
    
    int xopts;
    
    if(follow)
        xopts = 0;
    else
        xopts = XATTR_NOFOLLOW;    
    
    ssize_t bufSize;
    ssize_t status;
    
    // call with NULL as attr name to get the size of the returned buffer
    status = listxattr(fsPath, NULL, 0, xopts);
    
    if(status == -1){
        if(error) *error = [self xattrError:errno forPath:path];
        return nil;
    }
    
    NSZone *zone = NSDefaultMallocZone();
    bufSize = status;
    char *namebuf = (char *)NSZoneMalloc(zone, sizeof(char) * bufSize);
    NSAssert(namebuf != NULL, @"unable to allocate memory");
    status = listxattr(fsPath, namebuf, bufSize, xopts);
    
    if(status == -1){
        if(error) *error = [self xattrError:errno forPath:path];
        NSZoneFree(zone, namebuf);
        return nil;
    }
    
    int idx, start = 0;

    NSString *attribute = nil;
    NSMutableArray *attrs = [NSMutableArray array];
    
    // the names are separated by NULL characters
    for(idx = 0; idx < bufSize; idx++){
        if(namebuf[idx] == '\0'){
            attribute = [[NSString alloc] initWithBytes:&namebuf[start] length:(idx - start) encoding:NSUTF8StringEncoding];
            if(attribute) [attrs addObject:attribute];
            [attribute release];
            attribute = nil;
            start = idx + 1;
        }
    }
    
    NSZoneFree(zone, namebuf);
    return attrs;
}

- (NSArray *)allExtendedAttributesAtPath:(NSString *)path traverseLink:(BOOL)follow error:(NSError **)error;
{
    NSError *anError = nil;
    NSArray *attrNames = [self extendedAttributeNamesAtPath:path traverseLink:follow error:&anError];
    if(attrNames == nil){
        if(error) *error = anError;
        return nil;
    }
    
    NSEnumerator *e = [attrNames objectEnumerator];
    NSMutableArray *attributes = [NSMutableArray arrayWithCapacity:[attrNames count]];
    NSData *data = nil;
    NSString *attrName = nil;
    
    while(attrName = [e nextObject]){
        data = [self extendedAttributeNamed:attrName atPath:path traverseLink:follow error:&anError];
        if(data != nil){
            [attributes addObject:data];
        } else {
            if(error) *error = anError;
            return nil;
        }
    }
    return attributes;
}

- (NSData *)extendedAttributeNamed:(NSString *)attr atPath:(NSString *)path traverseLink:(BOOL)follow error:(NSError **)error;
{
    const char *fsPath = [path fileSystemRepresentation];
    const char *attrName = [attr UTF8String];
    
    int xopts;
    
    if(follow)
        xopts = 0;
    else
        xopts = XATTR_NOFOLLOW;
    
    ssize_t bufSize;
    ssize_t status;
    status = getxattr(fsPath, attrName, NULL, 0, 0, xopts);
    
    if(status == -1){
        if(error) *error = [self xattrError:errno forPath:path];
        return nil;
    }
    
    bufSize = status;
    char *namebuf = (char *)NSZoneMalloc(NSDefaultMallocZone(), sizeof(char) * bufSize);
    NSAssert(namebuf != NULL, @"unable to allocate memory");
    status = getxattr(fsPath, attrName, namebuf, bufSize, 0, xopts);
    
    if(status == -1){
        if(error) *error = [self xattrError:errno forPath:path];
        NSZoneFree(NSDefaultMallocZone(), namebuf);
        return nil;
    }
    
    // let NSData worry about freeing the buffer
    NSData *attribute = [[NSData alloc] initWithBytesNoCopy:namebuf length:bufSize];
    
    NSPropertyListFormat format;
    NSString *errorString;
    
    // the plist parser logs annoying messages when failing to parse non-plist data, so sniff the header (this is correct for the binary plist that we use for split data)
    static NSData *plistHeaderData = nil;
    if (nil == plistHeaderData) {
        char *h = "bplist00";
        plistHeaderData = [[NSData alloc] initWithBytes:h length:strlen(h)];
    }

    id plist = nil;
    
    if ([attribute length] >= [plistHeaderData length] && [plistHeaderData isEqual:[attribute subdataWithRange:NSMakeRange(0, [plistHeaderData length])]])
        plist = [NSPropertyListSerialization propertyListFromData:attribute mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&errorString];
    
    // even if it's a plist, it may not be a dictionary or have the key we're looking for
    if (plist && [plist respondsToSelector:@selector(objectForKey:)] && [[plist objectForKey:WRAPPER_KEY] boolValue]) {
        
        NSString *uniqueValue = [plist objectForKey:UNIQUE_KEY];
        unsigned int i, numberOfFragments = [[plist objectForKey:FRAGMENTS_KEY] unsignedIntValue];
        NSString *name;

        NSMutableData *buffer = [NSMutableData data];
        NSData *subdata;
        BOOL success = (nil != uniqueValue && numberOfFragments > 0);
        
        // reassemble the original data object
        for (i = 0; success && i < numberOfFragments; i++) {
            name = [NSString stringWithFormat:@"%@-%i", uniqueValue, i];
            subdata = [self extendedAttributeNamed:name atPath:path traverseLink:follow error:error];
            if (nil == subdata)
                success = NO;
            else
                [buffer appendData:subdata];
        }
        
        [attribute release];
        attribute = success ? [[self bunzip2:buffer] retain] : nil;
    }
    return [attribute autorelease];
}

- (id)propertyListFromExtendedAttributeNamed:(NSString *)attr atPath:(NSString *)path traverseLink:(BOOL)traverse error:(NSError **)outError;
{
    NSError *error;
    NSData *data = [self extendedAttributeNamed:attr atPath:path traverseLink:traverse error:&error];
    id plist = nil;
    if (nil == data) {
        if (outError) *outError = [NSError errorWithDomain:SKNErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:path, NSFilePathErrorKey, error, NSUnderlyingErrorKey, nil]];
    } else {
        NSString *errorString;
        plist = [NSPropertyListSerialization propertyListFromData:data 
                                                 mutabilityOption:NSPropertyListImmutable 
                                                           format:NULL 
                                                 errorDescription:&errorString];
        if (nil == plist) {
            if (outError) *outError = [NSError errorWithDomain:SKNErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:path, NSFilePathErrorKey, errorString, NSLocalizedDescriptionKey, nil]];
            [errorString release];
        }
    }
    return plist;
}

- (BOOL)setExtendedAttributeNamed:(NSString *)attr toValue:(NSData *)value atPath:(NSString *)path options:(SKNXattrFlags)options error:(NSError **)error;
{

    const char *fsPath = [path fileSystemRepresentation];
    const void *data = [value bytes];
    size_t dataSize = [value length];
    const char *attrName = [attr UTF8String];
        
    // options passed to xattr functions
    int xopts = 0;
    if(options & kSKNXattrNoFollow)
        xopts = xopts | XATTR_NOFOLLOW;
    if(options & kSKNXattrCreateOnly)
        xopts = xopts | XATTR_CREATE;
    if(options & kSKNXattrReplaceOnly)
        xopts = xopts | XATTR_REPLACE;
    
    BOOL success;

    if ((options & kSKNXattrNoSplitData) == 0 && [value length] > MAX_XATTR_LENGTH) {
                    
        // compress to save space, and so we don't identify this as a plist when reading it (in case it really is plist data)
        value = [self bzip2:value];
        
        // this will be a unique identifier for the set of keys we're about to write (appending a counter to the UUID)
        NSString *uniqueValue = [NAME_PREFIX stringByAppendingString:UNIQUE_VALUE];
        unsigned numberOfFragments = ([value length] / MAX_XATTR_LENGTH) + ([value length] % MAX_XATTR_LENGTH ? 1 : 0);
        NSDictionary *wrapper = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], WRAPPER_KEY, uniqueValue, UNIQUE_KEY, [NSNumber numberWithUnsignedInt:numberOfFragments], FRAGMENTS_KEY, nil];
        NSData *wrapperData = [NSPropertyListSerialization dataFromPropertyList:wrapper format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
        NSParameterAssert([wrapperData length] < MAX_XATTR_LENGTH && [wrapperData length] > 0);
        
        // we don't want to split this dictionary (or compress it)
        if (setxattr(fsPath, attrName, [wrapperData bytes], [wrapperData length], 0, xopts))
            success = NO;
        else
            success = YES;
        
        // now split the original data value into multiple segments
        NSString *name;
        unsigned j;
        const char *valuePtr = [value bytes];
        
        for (j = 0; success && j < numberOfFragments; j++) {
            name = [[NSString alloc] initWithFormat:@"%@-%i", uniqueValue, j];
            
            char *subdataPtr = (char *)&valuePtr[j * MAX_XATTR_LENGTH];
            unsigned subdataLen = j == numberOfFragments - 1 ? ([value length] - j * MAX_XATTR_LENGTH) : MAX_XATTR_LENGTH;
            
            // could recurse here, but it's more efficient to use the variables we already have
            if (setxattr(fsPath, [name UTF8String], subdataPtr, subdataLen, 0, xopts)) {
                NSLog(@"full data length of note named %@ was %d, subdata length was %d (failed on pass %d)", name, [value length], subdataLen, j);
            }
            [name release];
        }
        
    } else {
        int status = setxattr(fsPath, attrName, data, dataSize, 0, xopts);
        if(status == -1){
            if(error) *error = [self xattrError:errno forPath:path];
            success = NO;
        } else {
            success = YES;
        }
    }
    return success;
}

- (BOOL)setExtendedAttributeNamed:(NSString *)attr toPropertyListValue:(id)plist atPath:(NSString *)path options:(SKNXattrFlags)options error:(NSError **)error;
{
    NSString *errorString;
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:plist 
                                                              format:NSPropertyListBinaryFormat_v1_0 
                                                    errorDescription:&errorString];
    BOOL success;
    if (nil == data) {
        if (error) *error = [NSError errorWithDomain:SKNErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:path, NSFilePathErrorKey, errorString, NSLocalizedDescriptionKey, nil]];
        [errorString release];
        success = NO;
    } else {
        success = [self setExtendedAttributeNamed:attr toValue:data atPath:path options:options error:error];
    }
    return success;
}

- (BOOL)removeExtendedAttribute:(NSString *)attr atPath:(NSString *)path traverseLink:(BOOL)follow error:(NSError **)error;
{
    NSParameterAssert(path != nil);
    const char *fsPath = [path fileSystemRepresentation];
    const char *attrName = [attr UTF8String];
    
    int xopts;
    
    if(follow)
        xopts = 0;
    else
        xopts = XATTR_NOFOLLOW;
    
    ssize_t bufSize;
    ssize_t status;
    status = getxattr(fsPath, attrName, NULL, 0, 0, xopts);
    
    if(status != -1){
        bufSize = status;
        char *namebuf = (char *)NSZoneMalloc(NSDefaultMallocZone(), sizeof(char) * bufSize);
        NSAssert(namebuf != NULL, @"unable to allocate memory");
        status = getxattr(fsPath, attrName, namebuf, bufSize, 0, xopts);
        
        if(status != -1){
            
            // let NSData worry about freeing the buffer
            NSData *attribute = [[NSData alloc] initWithBytesNoCopy:namebuf length:bufSize];
            
            NSPropertyListFormat format;
            NSString *errorString;
            
            // the plist parser logs annoying messages when failing to parse non-plist data, so sniff the header (this is correct for the binary plist that we use for split data)
            static NSData *plistHeaderData = nil;
            if (nil == plistHeaderData) {
                char *h = "bplist00";
                plistHeaderData = [[NSData alloc] initWithBytes:h length:strlen(h)];
            }

            id plist = nil;
            
            if ([attribute length] >= [plistHeaderData length] && [plistHeaderData isEqual:[attribute subdataWithRange:NSMakeRange(0, [plistHeaderData length])]])
                plist = [NSPropertyListSerialization propertyListFromData:attribute mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&errorString];
            
            // even if it's a plist, it may not be a dictionary or have the key we're looking for
            if (plist && [plist respondsToSelector:@selector(objectForKey:)] && [[plist objectForKey:WRAPPER_KEY] boolValue]) {
                
                NSString *uniqueValue = [plist objectForKey:UNIQUE_KEY];
                unsigned int i, numberOfFragments = [[plist objectForKey:FRAGMENTS_KEY] unsignedIntValue];
                NSString *name;
                
                // remove the sub attributes
                for (i = 0; i < numberOfFragments; i++) {
                    name = [NSString stringWithFormat:@"%@-%i", uniqueValue, i];
                    const char *subAttrName = [name UTF8String];
                    status = removexattr(fsPath, subAttrName, xopts);
                    if (status == -1) {
                        NSLog(@"failed to remove subattribute %@ of attribute named %@", name, attr);
                    }
                }
            }
        }
    }
    
    status = removexattr(fsPath, attrName, xopts);
    
    if(status == -1){
        if(error) *error = [self xattrError:errno forPath:path];
        return NO;
    } else 
        return YES;    
}

- (BOOL)removeAllExtendedAttributesAtPath:(NSString *)path traverseLink:(BOOL)follow error:(NSError **)error;
{
    NSArray *allAttributes = [self extendedAttributeNamesAtPath:path traverseLink:follow error:error];
    if  (nil == allAttributes)
        return NO;
    
    const char *fsPath;
    ssize_t status;
    int xopts;
    
    if(follow)
        xopts = 0;
    else
        xopts = XATTR_NOFOLLOW;
    
    NSEnumerator *e = [allAttributes objectEnumerator];
    NSString *attrName;
    while (attrName = [e nextObject]) {
        
        fsPath = [path fileSystemRepresentation];
        status = removexattr(fsPath, [attrName UTF8String], xopts);
        
        // return NO as soon as any single removal fails
        if (status == -1){
            if(error) *error = [self xattrError:errno forPath:path];
            return NO;
        }
    }
    return YES;
}

// guaranteed to return non-nil
- (NSError *)xattrError:(int)err forPath:(NSString *)path;
{
    NSString *errMsg = nil;
    switch (err)
    {
        case ENOTSUP:
            errMsg = SKNLocalizedString(@"File system does not support extended attributes or they are disabled.", @"Error description");
            break;
        case ERANGE:
            errMsg = SKNLocalizedString(@"Buffer too small for attribute names.", @"Error description");
            break;
        case EPERM:
            errMsg = SKNLocalizedString(@"This file system object does not support extended attributes.", @"Error description");
            break;
        case ENOTDIR:
            errMsg = SKNLocalizedString(@"A component of the path is not a directory.", @"Error description");
            break;
        case ENAMETOOLONG:
            errMsg = SKNLocalizedString(@"File name too long.", @"Error description");
            break;
        case EACCES:
            errMsg = SKNLocalizedString(@"Search permission denied for this path.", @"Error description");
            break;
        case ELOOP:
            errMsg = SKNLocalizedString(@"Too many symlinks encountered resolving path.", @"Error description");
            break;
        case EIO:
            errMsg = SKNLocalizedString(@"I/O error occurred.", @"Error description");
            break;
        case EINVAL:
            errMsg = SKNLocalizedString(@"Options not recognized.", @"Error description");
            break;
        case EEXIST:
            errMsg = SKNLocalizedString(@"Options contained XATTR_CREATE but the named attribute exists.", @"Error description");
            break;
        case ENOATTR:
            errMsg = SKNLocalizedString(@"The named attribute does not exist.", @"Error description");
            break;
        case EROFS:
            errMsg = SKNLocalizedString(@"Read-only file system.  Unable to change attributes.", @"Error description");
            break;
        case EFAULT:
            errMsg = SKNLocalizedString(@"Path or name points to an invalid address.", @"Error description");
            break;
        case E2BIG:
            errMsg = SKNLocalizedString(@"The data size of the extended attribute is too large.", @"Error description");
            break;
        case ENOSPC:
            errMsg = SKNLocalizedString(@"No space left on file system.", @"Error description");
            break;
        default:
            errMsg = SKNLocalizedString(@"Unknown error occurred.", @"Error description");
            break;
    }
    return [NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:[NSDictionary dictionaryWithObjectsAndKeys:path, NSFilePathErrorKey, errMsg, NSLocalizedDescriptionKey, nil]];
}

// 
// implementation modified after http://www.cocoadev.com/index.pl?NSDataPlusBzip (removed exceptions)
//

- (NSData *)bzip2:(NSData *)data;
{
	int compression = 5;
    int bzret, buffer_size = 1000000;
	bz_stream stream = { 0 };
	stream.next_in = (char *)[data bytes];
	stream.avail_in = [data length];
	
	NSMutableData *buffer = [[NSMutableData alloc] initWithLength:buffer_size];
	stream.next_out = [buffer mutableBytes];
	stream.avail_out = buffer_size;
	
	NSMutableData *compressed = [NSMutableData dataWithCapacity:[data length]];
	
	BZ2_bzCompressInit(&stream, compression, 0, 0);
    BOOL hadError = NO;
    do {
        bzret = BZ2_bzCompress(&stream, (stream.avail_in) ? BZ_RUN : BZ_FINISH);
        if (bzret != BZ_RUN_OK && bzret != BZ_STREAM_END) {
            hadError = YES;
            compressed = nil;
        } else {        
            [compressed appendBytes:[buffer bytes] length:(buffer_size - stream.avail_out)];
            stream.next_out = [buffer mutableBytes];
            stream.avail_out = buffer_size;
        }
    } while(bzret != BZ_STREAM_END && NO == hadError);
    
    BZ2_bzCompressEnd(&stream);
	[buffer release];
    
	return compressed;
}

- (NSData *)bunzip2:(NSData *)data;
{
	int bzret;
	bz_stream stream = { 0 };
	stream.next_in = (char *)[data bytes];
	stream.avail_in = [data length];
	
	const int buffer_size = 10000;
	NSMutableData *buffer = [[NSMutableData alloc] initWithLength:buffer_size];
	stream.next_out = [buffer mutableBytes];
	stream.avail_out = buffer_size;
	
	NSMutableData *decompressed = [NSMutableData dataWithCapacity:[data length]];
	
	BZ2_bzDecompressInit(&stream, 0, NO);
    BOOL hadError = NO;
    do {
        bzret = BZ2_bzDecompress(&stream);
        if (bzret != BZ_OK && bzret != BZ_STREAM_END) {
            hadError = YES;
            decompressed = nil;
        } else {        
            [decompressed appendBytes:[buffer bytes] length:(buffer_size - stream.avail_out)];
            stream.next_out = [buffer mutableBytes];
            stream.avail_out = buffer_size;
        }
    } while(bzret != BZ_STREAM_END && NO == hadError);
    
    BZ2_bzDecompressEnd(&stream);
    [buffer release];

	return decompressed;
}

@end
