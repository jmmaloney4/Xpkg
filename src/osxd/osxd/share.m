//
//  share.m
//  osxd
//
//  Created by Jack Maloney on 3/30/14.
//  Copyright (c) 2014 IV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "share.h"

@implementation share
+(NSFileHandle*) getConfigFile {
    NSFileHandle * config = [NSFileHandle fileHandleForReadingAtPath:CONFIG_FILE];
    if (!config) {
        NSTask *mkconf = [[NSTask alloc] init];
        [mkconf setLaunchPath:@"/bin/mkdir"];
        [mkconf setArguments:[NSArray arrayWithObjects: @"/opt/",CONFIG_PATH, nil]];
        [mkconf launch];
        NSTask *mkcnf = [[NSTask alloc] init];
        [mkcnf setLaunchPath:@"/usr/bin/touch"];
        [mkcnf setArguments:[NSArray arrayWithObjects: CONFIG_FILE, nil]];
        [mkcnf launch];
    }
    config = [NSFileHandle fileHandleForReadingAtPath:CONFIG_FILE];
    return config;
}
+(NSString*) getStringForFileAtPath:(NSString*) path {
    NSFileHandle* file = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *data = [file readDataToEndOfFile];
    NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    return string;
}
+(NSString*) getConfigFileString {
    return [share getStringForFileAtPath:CONFIG_PATH];
}

+(BOOL) exitIfNotRoot {
    if (getuid() == 0) {
        return YES;
    } else {
        [share print:"Must Be Root\n"];
        exit(1);
        return NO;
    }
}

+(void) printUsage {
    [share print:[USAGE UTF8String]];
}

+(void) print:(const char *) x {
    printf("%s", x);
}

+(void) printError:(const char *) x {
    printf("%sERROR: %s%s", [BOLDRED UTF8String], [RESET UTF8String], x);
}

+(NSString*) getInfoFileForPath:(NSString*) path {
    NSMutableString* infoFilePath = [[NSMutableString alloc] init];
    [infoFilePath appendString:path];
    [infoFilePath appendString:@"/OSXD/info"];
    return infoFilePath;
}

+(NSString*) createPackage:(NSString*)path {
    BOOL isBinary = false;
    NSString* infoFile = [share getStringForFileAtPath:[share getInfoFileForPath:path]];
    
    if (!infoFile) {
        if ([infoFile hasPrefix:SRC]) {
            isBinary = false;
        } else if ([infoFile hasPrefix:BIN]) {
            isBinary = true;
        }  else {
            const char * x;
            x = "Unidentifiable Package Type, file at %s/OSXD/info is either non existent or cannot be parsed\n", path;
            [share printError:x];
        }
    }  else {
        const char * x;
        x = "Unidentifiable Package Type, file at %s/OSXD/info is non existent\n", path;
        [share printError:x];
    }
    
    
    // tar NSTask
    NSTask* tar = [[NSTask alloc]init];
    [tar setLaunchPath:@"/usr/bin/tar"];
    
    // Output File Path
    NSMutableString* out = [[NSMutableString alloc] initWithUTF8String:[path UTF8String]];
    if ([out hasSuffix:@"/"]) {
        // removes the last character from the range
        NSRange range = {[out length], 1};
        [out deleteCharactersInRange:range];
    }
    
    // Get Type of Package to be created
    if (isBinary) {
        // Binary
        [out appendString:@".xbp"];
    } else {
        // Source
        [out appendString:@".xsp"];
    }
    
    NSPipe* pipe = [NSPipe pipe];
    [tar setStandardOutput: pipe];
    
    [tar setArguments:@[@"-cj", @"--format", @"ustar", path]];
    [tar launch];
    
    NSFileHandle* file = [pipe fileHandleForReading];
    NSData* data = [file readDataToEndOfFile];
    file = [NSFileHandle fileHandleForWritingAtPath:out];
    [file writeData:data];
    [file closeFile];
    return out;
}

@end
