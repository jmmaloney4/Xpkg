//
//  xpkg.m
//  xpkg
//
//  Created by Jack Maloney on 3/31/14.
//  Copyright (c) 2014 IV. All rights reserved.
//

#import "xpkg.h"

@implementation xpkg

+(void) print:(NSString*) x {
    printf("%s", [x UTF8String]);
}

+(void) printError:(NSString *)x {
    printf("%sError: %s%s", [BOLDRED UTF8String], [RESET UTF8String], [x UTF8String]);
}

+(BOOL) checkForArgs:(int)argc {
    BOOL rv = NO;
    if (argc < 2) {
        [xpkg print:USAGE];
        exit(1);
        rv = NO;
    } else {
        rv = YES;
        return rv;
    }
    return rv;
}

+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path {
    NSString* rv;
    NSTask* task = [[NSTask alloc] init];
    //NSMutableArray* argss = [args mutableCopy];
    
    //[argss insertObject:@">> /opt/xpkg/log/xpkg.log 2>&1" atIndex:[args count]];
    
    [task setLaunchPath:command];
    [task setArguments:args];
    [task setCurrentDirectoryPath:path];
    
    NSPipe* pipe =[NSPipe pipe];
    [task setStandardOutput:pipe];
    
    [task launch];
    
    NSFileHandle* file = [pipe fileHandleForReading];
    
    NSData* data = [file readDataToEndOfFile];
    
    rv= [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    return rv;
}

+(NSFileHandle*) getFileAtPath:(NSString*) path {
    NSFileHandle* file = [NSFileHandle fileHandleForReadingAtPath:path];
    return file;
}

+(NSData*) getDataFromFile:(NSFileHandle*) file {
    return [file readDataToEndOfFile];
}

+(NSString*) getStringFromData:(NSData*) data {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+(NSString*) getPathWithPrefix:(NSString*)path {
    NSMutableString* rv = [PREFIX mutableCopy];
    [rv appendString:path];
    return rv;
}

+(void) exitIfNotRoot {
    if (getuid() != 0) {
        [xpkg printError:@"Not Root, Exiting...\n"];
        exit(-1);
    }
}

+(BOOL) checkHashes:(NSString*)sha rmd160:(NSString*)rmd atPath:(NSString*)path {
    BOOL rv = NO;
    NSString* shar = [xpkg executeCommand:@"/usr/bin/shasum" withArgs:@[@"-a 256", path] andPath:@"/"];
    NSString* rmdr = [xpkg executeCommand:@"/usr/bin/openssl" withArgs:@[@"rmd160", path] andPath:@"/"];
    
    NSArray* shas = [shar componentsSeparatedByString:@" "];
    NSArray* rmds = [rmdr componentsSeparatedByString:@" "];
    
    for (int i = 0; i < [shar length]; i++) {
        if (shas[i] == sha) {
            for (int i = 0; i < [rmdr length]; i++) {
                if (rmds[i] == rmd) {
                    rv = YES;
                    return rv;
                }
            }
        }
    }
    
    return rv;
}

+(void) updateProgram {
    [xpkg executeCommand:@"/opt/xpkg/bin/git" withArgs:@[@"pull"] andPath:[xpkg getPathWithPrefix:@""]];
    [xpkg executeCommand:@"/usr/bin/xcodebuild" withArgs:@[] andPath:[xpkg getPathWithPrefix:@"/src/xpkg"]];
    [xpkg executeCommand:@"/bin/cp" withArgs:@[[xpkg getPathWithPrefix:@"/src/xpkg/build/Release/xpkg"], [xpkg getPathWithPrefix:@"/core/"]] andPath:[xpkg getPathWithPrefix:@""]];
    [xpkg executeCommand:@"/bin/ln" withArgs:@[@"-fF", [xpkg getPathWithPrefix:@"/core/xpkg"], @"/usr/bin/xpkg"] andPath:[xpkg getPathWithPrefix:@""]];
}

+(void) downloadFile:(NSString*)URL place:(NSString*)path {
    NSData* data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:URL]];
    [data writeToFile:path atomically:YES];
}

+(BOOL) installPackage:(NSString*)path {
    BOOL s = NO;

    NSString* package;
    NSString* name;
    NSString* version;

    NSFileHandle* file = [xpkg getFileAtPath:path];
    NSString* filestr = [xpkg getStringFromData:[xpkg getDataFromFile:file]];
    NSArray* filecmps = [filestr componentsSeparatedByString:@" "];

    if (!filecmps) {
        return NO;
    }

    for (int i = 0; i < [filecmps count]; i++) {
        if ([@"Package:" isEqualToString:filecmps[i]]) {
            package = filecmps[i + 1];
        }
    }
    
    return s;

}

@end
