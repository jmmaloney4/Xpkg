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
    printf("%s\n", [x UTF8String]);
    [xpkg log:[NSString stringWithFormat:@"INFO: %@\n", x]];
}

+(void) printError:(NSString *)x {
    printf("%sERROR: %s%s\n", [BOLDRED  UTF8String], [RESET UTF8String], [x UTF8String]);
    [xpkg log:[NSString stringWithFormat:@"ERROR: %@\n", x]];
}

+(void) printWarn:(NSString *)x {
    printf("%sWARNING: %s%s\n", [BOLDYELLOW UTF8String], [RESET UTF8String], [x UTF8String]);
    [xpkg log:[NSString stringWithFormat:@"WARNING: %@\n", x]];
}

+(void) log:(NSString *)x {
    NSString* date = [xpkg getTimestamp];

    NSString* pre = @"[ ";

    pre = [pre stringByAppendingString:date];
    pre = [pre stringByAppendingString:@" ] "];
    pre = [pre stringByAppendingString:x];

    NSData* data = [pre dataUsingEncoding:NSUTF8StringEncoding];

    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:LOG_FILE];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:data];
    [fileHandle closeFile];
}

+(NSString*) getTimestamp {
    NSDate *myDate = [[NSDate alloc] init];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"cccc, MMMM dd, YYYY, HH:mm:ss.SSS aa"];
    NSString* date = [dateFormat stringFromDate:myDate];
    return date;
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

/** 
 * Uses an NSTask to execute a shell command
 **/
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path printErr:(BOOL)er printOut:(BOOL) ot {
    NSString* rv;
    NSTask* task = [[NSTask alloc] init];
    
    [task setLaunchPath:command];
    [task setArguments:args];
    [task setCurrentDirectoryPath:path];
    
    NSPipe* pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];

    NSPipe* err = [NSPipe pipe];
    [task setStandardError:err];

    [task launch];
    
    NSFileHandle* file = [pipe fileHandleForReading];
    NSData* data = [file readDataToEndOfFile];

    NSFileHandle* errfile = [err fileHandleForReading];
    NSData* errdata = [errfile readDataToEndOfFile];

    if (![[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] isEqualToString:@""]) {
        [xpkg log:[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]];
    }


    // prints the error of the command to stderr if 'er' is true
    if (er) {
        fprintf(stderr, "%s", [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] UTF8String]);
    }

    if (![[[NSString alloc] initWithData: errdata encoding: NSUTF8StringEncoding] isEqualToString:@""]) {
        [xpkg log:[[NSString alloc] initWithData: errdata encoding: NSUTF8StringEncoding]];
    }

    // prints the standard out of the command to stdout if 'ot' is true
    if (ot) {
        fprintf(stdout, "%s", [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] UTF8String]);
    }

    return rv;
}

/**
 * Other Variants of the executeCommand method above, just with some default values in place
 **/

+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path printErr:(BOOL)er {
    return [xpkg executeCommand:command withArgs:args andPath:path printErr:er printOut:true];
}


+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path printOut:(BOOL) ot {
    return [xpkg executeCommand:command withArgs:args andPath:path printErr:true printOut:ot];
}

+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path {
    return [xpkg executeCommand:command withArgs:args andPath:path printErr:true printOut:false];
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

/**
 * Exits the program if it is not run as root
 **/
+(void) exitIfNotRoot {
    if (getuid() != 0) {
        [xpkg printError:@"Not Root, Exiting...\n"];
        exit(-1);
    }
}

/**
 * Checks the SHA256 and RIPEMD-160 hashes for the tarball downloaded by the program
 **/

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

/**
 * updates Xpkg itself
 **/

+(void) updateProgram {
    [xpkg executeCommand:@"/opt/xpkg/bin/git" withArgs:@[@"pull"] andPath:[xpkg getPathWithPrefix:@""]];
    [xpkg executeCommand:@"/usr/bin/xcodebuild" withArgs:@[] andPath:[xpkg getPathWithPrefix:@"/src/xpkg"]];
    [xpkg executeCommand:@"/bin/cp" withArgs:@[[xpkg getPathWithPrefix:@"/src/xpkg/build/Release/xpkg"], [xpkg getPathWithPrefix:@"/core/"]] andPath:[xpkg getPathWithPrefix:@""]];
    [xpkg executeCommand:@"/bin/ln" withArgs:@[@"-fF", [xpkg getPathWithPrefix:@"/core/xpkg"], @"/usr/bin/xpkg"] andPath:[xpkg getPathWithPrefix:@""]];
}

/**
 * Downloads the fie at URL and saves it at the path provided
 **/
+(void) downloadFile:(NSString*)URL place:(NSString*)path {
    NSData* data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:URL]];
    [data writeToFile:path atomically:YES];
}

/**
 * installs a package from the package file at path
 **/
+(BOOL) installPackage:(NSString*)path {
    BOOL s = NO;

    NSString* package;
    NSString* name;
    NSString* version;
    NSString* SHA256;
    NSString* RMD160;
    NSString* description;

    NSFileHandle* file = [xpkg getFileAtPath:path];
    NSString* filestr = [xpkg getStringFromData:[xpkg getDataFromFile:file]];

    NSArray* filecmps = [filestr componentsSeparatedByString:@"\n"];

    NSMutableArray* parsedArrays;

    if (!filecmps) {
        return NO;
    }

    for (int x = 0; x < [filecmps count]; x++) {
        if ([filecmps[x] hasPrefix:@"@"]) {
            //parse attribute
            NSArray* f = [filecmps[x] componentsSeparatedByString:@":"];

            if ([[f[0] componentsSeparatedByString:@"@"][1] isEqualToString:@"Package"]) {
                package = f[1];
                if ([package hasPrefix:@" "]) {
                    package = [package substringWithRange:NSMakeRange(1, [package length]-1)];
                }
            } else if ([[f[0] componentsSeparatedByString:@"@"][1] isEqualToString:@"Version"]) {
                version = f[1];
                if ([version hasPrefix:@" "]) {
                    version = [version substringWithRange:NSMakeRange(1, [version length]-1)];
                }
            } else if ([[f[0] componentsSeparatedByString:@"@"][1] isEqualToString:@"Name"]) {
                name = f[1];
                if ([name hasPrefix:@" "]) {
                    name = [name substringWithRange:NSMakeRange(1, [name length]-1)];
                    [xpkg print:name];
                }
            } else if ([[f[0] componentsSeparatedByString:@"@"][1] isEqualToString:@"SHA256"]) {
                SHA256 = f[1];
                if ([SHA256 hasPrefix:@" "]) {
                    SHA256 = [SHA256 substringWithRange:NSMakeRange(1, [SHA256 length]-1)];
                    [xpkg print:SHA256];
                }
            } else if ([[f[0] componentsSeparatedByString:@"@"][1] isEqualToString:@"RMD160"]) {
                RMD160 = f[1];
                if ([RMD160 hasPrefix:@" "]) {
                    RMD160 = [RMD160 substringWithRange:NSMakeRange(1, [RMD160 length]-1)];
                    [xpkg print:RMD160];
                }
            } else if ([[f[0] componentsSeparatedByString:@"@"][1] isEqualToString:@"Description"]) {
                description = f[1];
                if ([description hasPrefix:@" "]) {
                    description = [description substringWithRange:NSMakeRange(1, [description length]-1)];
                    [xpkg print:description];
                }
            }
        } else if ([filecmps[x] hasPrefix:@"&"]) {
            //parse method
        } else if ([filecmps[x] hasPrefix:@"#"]) {
            //comment, ignore
        }
    }
    return s;
}

/**
 * clears the Xpkg log file
 **/
+(void) clearLog {
    [xpkg executeCommand:@"/bin/rm" withArgs:@[@"/opt/xpkg/log/xpkg.log"] andPath:@"/"];
    [xpkg executeCommand:@"/usr/bin/touch" withArgs:@[@"/opt/xpkg/log/xpkg.log"] andPath:@"/"];
    [xpkg print:[NSString stringWithFormat:@"Cleared Log At: %@", [xpkg getTimestamp]]];
}

@end

