//
//  package.m
//  xpkg
//
//  Created by Jack Maloney on 4/13/14.
//  Copyright (c) 2014 Jack Maloney. All rights reserved.
//

#import "XPPackage.h"
#import "xpkg.h"

@implementation XPPackage

-(instancetype) initWithpath:(NSString*)path {
    self = [super init];
    self.path = path;
    self.package = [xpkg getAttribute:@"Package" atPath:self.package];
    self.name = [xpkg getAttribute:@"Name" atPath:self.path];
    self.url = [xpkg getAttribute:@"URL" atPath:self.path isURL:true];
    self.homepage = [xpkg getAttribute:@"Homepage" atPath:self.path isURL:true];
    self.description = [xpkg getAttribute:@"Description" atPath:self.path];
    self.rmd160 = [xpkg getAttribute:@"RMD160" atPath:self.path];
    self.sha256 = [xpkg getAttribute:@"SHA256" atPath:self.path];
    self.depends = [xpkg getArrayAttribute:@"Depends" atPath:self.path];
    self.recomended = [xpkg getArrayAttribute:@"Recomended" atPath:self.path];
    return self;
}

/**
 *  Returns nil because it is not the corrct init method, use initWithself.path instead
 **/
-(instancetype) init {
    return nil;
}



-(BOOL) install {
    if ([self.path hasPrefix:@"/"] || [self.path hasPrefix:@"./"] || [self.path hasPrefix:@"~/"]) {
        [xpkg print:@"Local Package"];
    }

    NSFileHandle* file = [xpkg getFileAtPath:self.path];
    NSString* filestr = [xpkg getStringFromData:[xpkg getDataFromFile:file]];

    NSArray* filecmps = [filestr componentsSeparatedByString:@"\n"];

    if (!filecmps) {
        return NO;
    }

    [xpkg printInfo:[NSString stringWithFormat:@"Installing %@, Version %@ From: %@", self.name, self.version, self.url]];

    [xpkg clearTmp];

    if (self.url) {
        [xpkg print:@"\tDownloading..."];
        [xpkg downloadFile:self.url place:[xpkg getPathWithPrefix:[NSString stringWithFormat:@"/tmp/%@.tar.gz", self.package]]];
        [xpkg print:@"\tUnpacking..."];
        [xpkg UntarFileAtPath:[xpkg getPathWithPrefix:[NSString stringWithFormat:@"/tmp/%@.tar.gz", self.package]] workingDir:[xpkg getPathWithPrefix:@"/tmp/"]];
    } else {
        [xpkg printError:@"URL Is Invalid, Aborting package install"];
        return NO;
    }

    // BUILD
    NSTimeInterval time;
    int a = [self runMethodScript:@"BUILD" withTime:time];

    if (a != 0) {
        [xpkg printError:@"NON-ZERO BUILD RETURN"];
    }

    // INSTALL
    a = [self runMethodScript:@"INSTALL"];
    return a;
}

-(BOOL) remove {
    if ([self.self.path hasPrefix:@"/"] || [self.self.path hasPrefix:@"./"] || [self.self.path hasPrefix:@"~/"]) {
        [xpkg print:@"Local Package"];
    }

    NSFileHandle* file = [xpkg getFileAtPath:self.path];
    NSString* filestr = [xpkg getStringFromData:[xpkg getDataFromFile:file]];

    NSArray* filecmps = [filestr componentsSeparatedByString:@"\n"];

    if (!filecmps) {
        return NO;
    }

    //TODO Remove packages that depend on this package before removing this package itself

    [xpkg printInfo:[NSString stringWithFormat:@"Removing %@, Version %@ From: %@", self.name, self.version, self.url]];

    NSFileManager* fm = [[NSFileManager alloc] init];
    [fm removeItemAtPath:[xpkg getPathWithPrefix:[NSString stringWithFormat:@"/xpkgs/%@/%@/", self.package, self.version]] error:nil];

    return [self runMethodScript:@"REMOVE"];
}

-(int) runMethodScript:(NSString*)method {
    NSTimeInterval s;
    return [self runMethodScript:method withTime:s];
}

-(int) runMethodScript:(NSString*)method withTime:(NSTimeInterval)time {
    NSString* sfile;
    NSString* script;
    NSDate* start = [NSDate date];
    sfile = [xpkg getPathWithPrefix:@"/tmp/script"];
    script = [self readMethodScript:method];
    [script writeToFile:sfile atomically:true encoding:NSUTF8StringEncoding error:nil];
    setenv("XPKG_PKG_DIR", [[xpkg getPathWithPrefix:[NSString stringWithFormat:@"/xpkgs/%@/%@/", self.package, self.version]] UTF8String], 1);
    setenv("XPKG_ROOT_DIR", [[xpkg getPathWithPrefix:[NSString stringWithFormat:@"/xpkgs/%@/%@/", self.package, self.version]] UTF8String], 1);
    [xpkg executeCommand:@"/bin/chmod" withArgs:@[@"+x", [xpkg getPathWithPrefix:@"/tmp/script"]] andPath:[xpkg getPathWithPrefix:@"/"] printErr:true printOut:true returnOut:true];
    [xpkg executeCommand:@"/bin/mkdir" withArgs:@[@"-p", [xpkg getPathWithPrefix:[NSString stringWithFormat:@"/tmp/%@-%@", self.package, self.version]]] andPath:[xpkg getPathWithPrefix:@"/"]];
    [xpkg log:[NSString stringWithFormat:@"Starting log for %@ script", method]];
    int d = system("/opt/xpkg/tmp/script >> /opt/xpkg/log/xpkg.log 2>&1");
    time = [start timeIntervalSinceNow];
    time = time - (time * 2);
    return d;
}


-(NSString*) readMethodScript:(NSString*)method {
    NSFileHandle* file = [xpkg getFileAtPath:self.path];
    NSString* filestr = [xpkg getStringFromData:[xpkg getDataFromFile:file]];

    NSArray* filecmps = [filestr componentsSeparatedByString:@"\n"];

    NSString* rv = @"";

    rv = [rv stringByAppendingString:@"#!/bin/bash"];
    NSString* x = @"";
    x = [NSString stringWithFormat:@"XPKG_ROOT_DIR=%@", [xpkg getPathWithPrefix:@"/"]];
    rv = [rv stringByAppendingString:[NSString stringWithFormat:@"\n%@", x]];
    x = [NSString stringWithFormat:@"XPKG_PKG_DIR=%@%@/%@", [xpkg getPathWithPrefix:@"/xpkgs/"], self.package, self.version];
    rv = [rv stringByAppendingString:[NSString stringWithFormat:@"\n%@", x]];
    x = [NSString stringWithFormat:@"cd %@%@-%@", [xpkg getPathWithPrefix:@"/tmp/"], self.package, self.version];
    rv = [rv stringByAppendingString:[NSString stringWithFormat:@"\n%@", x]];

    if (!filecmps) {
        return nil;
    }

    for (int x = 0; x < [filecmps count]; x++) {
        if ([filecmps[x] hasPrefix:@"@"]) {
            NSArray* f = [filecmps[x] componentsSeparatedByString:@":"];
            if ([[f[0] componentsSeparatedByString:@"@"][1] isEqualToString:method]) {
                for (int y = x + 1; y < [filecmps count]; y++) {
                    if ([filecmps[y] hasPrefix:@"@"]) {
                        NSArray* f = [filecmps[y] componentsSeparatedByString:@":"];
                        if ([[f[0] componentsSeparatedByString:@"@"][1] isEqualToString:@"END"]) {
                            break;
                        } else {
                            [xpkg printWarn:@"Encountered Attribute Field inside of a method, Ignoring..."];
                        }
                    } else {
                        NSString* str = [NSString stringWithFormat:@"\n%s", [filecmps[y] UTF8String]];
                        str = [str stringByAppendingString:@" >> /opt/xpkg/log/xpkg.log 2>&1"];
                        rv = [rv stringByAppendingString:str];
                    }
                }
            }
        }
    }
    return rv;
}

@end
