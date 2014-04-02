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
    printf("%sError:%s%s", [BOLDRED UTF8String], [RESET UTF8String], [x UTF8String]);
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

//TODO add a method to open a file for reading

+(NSString*) parseArg1:(NSString *)arg {
    if ([UPDATE isEqualToString:arg]) {
        [xpkg executeCommand:[xpkg getPathWithPrefix:@"/core/git/1.9.1/git"] withArgs:@[@"pull"] andPath:[xpkg getPathWithPrefix:@""]];
        
        NSString* fileContents = [NSString stringWithContentsOfFile:[xpkg getPathWithPrefix:@"version"] encoding:NSUTF8StringEncoding error:nil];
        NSArray* lines = [fileContents componentsSeparatedByString:@"."];
        NSArray* version = [VERSION componentsSeparatedByString:@"."];
        
        if ([lines count] > 2) {
            if (lines[0] == version[0]) {
                if (lines[1] == version[1]) {
                    if(lines[2] == version[2]) {
                        
                    } else {
                        [xpkg rebuildProgram];
                    }
                } else {
                    [xpkg rebuildProgram];
                }
            } else {
                [xpkg rebuildProgram];
            }
        }
        
        return UPDATE;
    } else if ([ADD isEqualToString:arg]) {
        return ADD;
    } else if ([INSTALL isEqualToString:arg]) {
        return INSTALL;
    } else {
        [xpkg printError:@"Arguments are invalid"];
        return nil;
    }
}

+(NSString*) getPathWithPrefix:(NSString*)path {
    NSMutableString* rv = [PREFIX mutableCopy];
    [rv appendString:path];
    return rv;
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

+(void) rebuildProgram {
    [xpkg executeCommand:@"/usr/bin/xcodebuild" withArgs:@[@">> /opt/xpkg/log/xpkg.log 2>&1"] andPath:[xpkg getPathWithPrefix:@"/src/xpkg"]];
    [xpkg executeCommand:@"/bin/mv" withArgs:@[[xpkg getPathWithPrefix:@"/core/xpkg"], [xpkg getPathWithPrefix:@"/core/xpkg-versions/xpkg"]] andPath:[xpkg getPathWithPrefix:@"/core/"]];
    [xpkg executeCommand:@"/bin/cp" withArgs:@[[xpkg getPathWithPrefix:@"/src/xpkg/build/Release/xpkg"], [xpkg getPathWithPrefix:@"/core/xpkg"]] andPath:[xpkg getPathWithPrefix:@""]
     ];
}

@end
