#import <Foundation/Foundation.h>
#import "NSFileManager_ExtendedAttributes.h"

#define SKIM_NOTES_KEY @"net_sourceforge_skim-app_notes"
#define SKIM_RTF_NOTES_KEY @"net_sourceforge_skim-app_rtf_notes"
#define SKIM_TEXT_NOTES_KEY @"net_sourceforge_skim-app_text_notes"

static char *usageStr = "Usage:\n skimnotes set PDF_FILE [SKIM_FILE|-]\n skimnotes get [-format skim|text|rtf] PDF_FILE [SKIM_FILE|RTF_FILE|TEXT_FILE|-]\n skimnotes remove PDF_FILE\n skimnotes help";
static char *versionStr = "SkimNotes command-line client, version 1.0.";

enum {
    SKNActionGet,
    SKNActionSet,
    SKNActionRemove
};

enum {
    SKNFormatAuto,
    SKNFormatSkim,
    SKNFormatText,
    SKNFormatRTF
};

static inline NSString *SKNNormalizedPath(NSString *path, NSString *basePath) {
    if ([path isEqualToString:@"-"] == NO) {
        unichar ch = [path length] ? [path characterAtIndex:0] : 0;
        if (basePath && ch != '/' && ch != '~')
            path = [basePath stringByAppendingPathComponent:path];
        path = [path stringByStandardizingPath];
    }
    return path;
}

static inline void SKNWriteUsageAndVersion() {
    fprintf (stderr, "%s\n%s\n", usageStr, versionStr);
}

int main (int argc, const char * argv[]) {
	int action = 0;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
 
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    
    if (argc < 3) {
        if (argc == 2 && ([[args objectAtIndex:1] caseInsensitiveCompare:@"-h"] == NSOrderedSame || [[args objectAtIndex:1] caseInsensitiveCompare:@"-help"] == NSOrderedSame || [[args objectAtIndex:1] caseInsensitiveCompare:@"help"] == NSOrderedSame)) {
            SKNWriteUsageAndVersion();
            exit (0);
        } else {
            SKNWriteUsageAndVersion();
            exit (1);
        }
    } 
    
    NSString *actionString = [args objectAtIndex:1];
    if ([actionString caseInsensitiveCompare:@"get"] == NSOrderedSame) {
        action = SKNActionGet;
    } else if ([actionString caseInsensitiveCompare:@"set"] == NSOrderedSame) {
        action = SKNActionSet;
    } else if ([actionString caseInsensitiveCompare:@"remove"] == NSOrderedSame) {
        action = SKNActionRemove;
    } else {
        SKNWriteUsageAndVersion();
        exit (1);
    }
    
    NSString *formatString = nil;
    int format = SKNFormatAuto;
    int offset = 2;
    
    if ([[args objectAtIndex:2] isEqualToString:@"-format"]) {
        if (argc < 5) {
            SKNWriteUsageAndVersion();
            exit (1);
        }
        offset = 4;
        formatString = [args objectAtIndex:3];
        if ([formatString caseInsensitiveCompare:@"skim"] == NSOrderedSame)
            format = SKNFormatSkim;
        if ([formatString caseInsensitiveCompare:@"text"] == NSOrderedSame || [formatString caseInsensitiveCompare:@"txt"] == NSOrderedSame)
            format = SKNFormatText;
        if ([formatString caseInsensitiveCompare:@"rtf"] == NSOrderedSame)
            format = SKNFormatRTF;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL success = NO;
    NSString *currentDir = [fm currentDirectoryPath];
    NSString *pdfPath = SKNNormalizedPath([args objectAtIndex:offset], currentDir);
    NSString *notesPath = argc < offset + 2 ? nil : SKNNormalizedPath([args objectAtIndex:offset + 1], currentDir);
    BOOL isDir = NO;
    NSError *error = nil;
    
    if (action != SKNActionRemove && notesPath == nil) {
        notesPath = [[pdfPath stringByDeletingPathExtension] stringByAppendingPathExtension:format == SKNFormatText ? @"txt" : format == SKNFormatRTF ? @"rtf" : @"skim"];
    }
    
    if ([[pdfPath pathExtension] caseInsensitiveCompare:@"pdf"] == NSOrderedSame && 
        ([fm fileExistsAtPath:pdfPath isDirectory:&isDir] == NO || isDir))
        pdfPath = [pdfPath stringByAppendingPathExtension:@"pdf"];
    
    if ([fm fileExistsAtPath:pdfPath isDirectory:&isDir] == NO || isDir) {
        error = [NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"PDF file does not exist", @"Error description"), NSLocalizedDescriptionKey, nil]];
    } else if (action == SKNActionGet) {
        NSData *data = nil;
        if (format == SKNFormatAuto) {
            NSString *extension = [notesPath pathExtension];
            if ([extension caseInsensitiveCompare:@"rtf"] == NSOrderedSame)
                format = SKNFormatRTF;
            else if ([[notesPath pathExtension] caseInsensitiveCompare:@"txt"] == NSOrderedSame || [[notesPath pathExtension] caseInsensitiveCompare:@"text"] == NSOrderedSame)
                format = SKNFormatText;
            else
                format = SKNFormatSkim;
        }
        if (format == SKNFormatSkim) {
            data = [fm extendedAttributeNamed:SKIM_NOTES_KEY atPath:pdfPath traverseLink:YES error:&error];
            if (data == nil && [error code] == ENOATTR)
                data = [NSData data];
        } else if (format == SKNFormatText) {
            NSString *string = [fm propertyListFromExtendedAttributeNamed:SKIM_TEXT_NOTES_KEY atPath:pdfPath traverseLink:YES error:&error];
            data = [string dataUsingEncoding:NSUTF8StringEncoding];
            if (string == nil && [error code] == ENOATTR)
                data = [NSData data];
        } else if (format == SKNFormatRTF) {
            data = [fm extendedAttributeNamed:SKIM_RTF_NOTES_KEY atPath:pdfPath traverseLink:YES error:&error];
            if (data == nil && [error code] == ENOATTR)
                data = [NSData data];
        }
        if (data) {
            if ([notesPath isEqualToString:@"-"]) {
                if ([data length])
                    [(NSFileHandle *)[NSFileHandle fileHandleWithStandardOutput] writeData:data];
                success = YES;
            } else {
                if ([data length]) {
                    success = [data writeToFile:notesPath options:NSAtomicWrite error:&error];
                } else if ([fm fileExistsAtPath:notesPath isDirectory:&isDir] && isDir == NO) {
                    success = [fm removeFileAtPath:notesPath handler:nil];
                    if (success = NO)
                        error = [NSError errorWithDomain:NSPOSIXErrorDomain code:EACCES userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Unable to remove file", @"Error description"), NSLocalizedDescriptionKey, nil]];
                } else {
                    success = YES;
                }
            }
        }
    } else if (action == SKNActionSet && notesPath && ([notesPath isEqualToString:@"-"] || ([fm fileExistsAtPath:notesPath isDirectory:&isDir] && isDir == NO))) {
        NSData *data = nil;
        if ([notesPath isEqualToString:@"-"])
            data = [[NSFileHandle fileHandleWithStandardInput] readDataToEndOfFile];
        else
            data = [NSData dataWithContentsOfFile:notesPath];
        if (data) {
            success = [fm removeExtendedAttribute:SKIM_NOTES_KEY atPath:pdfPath traverseLink:YES error:&error] || [error code] == ENOATTR;
            if (success && [data length])
                success = [fm setExtendedAttributeNamed:SKIM_NOTES_KEY toValue:data atPath:pdfPath options:0 error:&error];
        }
    } else if (action == SKNActionRemove) {
        BOOL success1 = [fm removeExtendedAttribute:SKIM_NOTES_KEY atPath:pdfPath traverseLink:YES error:&error];
        if (success1 == NO && [error code] == ENOATTR)
            success1 = YES;
        BOOL success2 = [fm removeExtendedAttribute:SKIM_RTF_NOTES_KEY atPath:pdfPath traverseLink:YES error:&error];
        if (success2 == NO && [error code] == ENOATTR)
            success2 = YES;
        BOOL success3 = [fm removeExtendedAttribute:SKIM_TEXT_NOTES_KEY atPath:pdfPath traverseLink:YES error:&error];
        if (success3 == NO && [error code] == ENOATTR)
            success3 = YES;
        success = success1 && success2 && success3;
    }
    
    if (success == NO && error)
        [(NSFileHandle *)[NSFileHandle fileHandleWithStandardError] writeData:[[error localizedDescription] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [pool release];
    
    return success ? 0 : 1;
}