//
//  xpkg, Advanced Package Management For Mac OS X
//  Copyright (c) 2014 Jack Maloney. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "XPPackage.h"
#import "xpkg.h"

@implementation XPPackage

-(instancetype) initWithpath:(NSString*)path andRepo:(NSString*)repon {
    self = [self initWithpath:path];
    self.repo_name = repon;
    return self;
}

-(instancetype) initWithpath:(NSString*)path {
    self = [super init];
    self.path = path;
    self.version = [xpkg getAttribute:@"Version" atPath:self.path];
    self.package = [xpkg getAttribute:@"Package" atPath:self.path];
    self.name = [xpkg getAttribute:@"Name" atPath:self.path];
    self.url = [xpkg getAttribute:@"URL" atPath:self.path isURL:true];
    self.homepage = [xpkg getAttribute:@"Homepage" atPath:self.path isURL:true];
    self.description = [xpkg getAttribute:@"Description" atPath:self.path];
    self.rmd160 = [xpkg getAttribute:@"RMD160" atPath:self.path];
    self.sha256 = [xpkg getAttribute:@"SHA256" atPath:self.path];
    self.maintainer = [xpkg getAttribute:@"Maintainer" atPath:self.path];
    self.depends = [xpkg getArrayAttribute:@"Depends" atPath:self.path];
    self.recomended = [xpkg getArrayAttribute:@"Recomended" atPath:self.path];
    return self;
}

-(instancetype) initFromDatabase {
    self = [super init];

    return self;
}

/*
-(instancetype) initWithData:(NSString*)path package:(NSString*)package version:(NSString*)version name:(NSString*)name url:(NSString*)url homepage:(NSString*)homepage description:(NSString*)description rmd:(NSString*)rmd sha:(NSString*)sha maintainer:(NSString*)maintainer depends:(NSArray*)depends recomended:(NSArray*)recomended dependers:(NSArray*)dependers {
    self = [super init];
    self.path = path;
    self.package = package;
    self.version = version;
    self.name = name;
    self.url = url;
    self.homepage = homepage;
    self.description = description;
    self.rmd160 = rmd;
    self.sha256 = sha;
    self.maintainer = maintainer;
    self.depends = depends;
    self.recomended = recomended;
    self.dependers = dependers;
    return self;
}
*/

/**
 *  Returns nil because it is not the corrct init method, use initWithPath instead
 **/
-(instancetype) init {
    return nil;
}



-(BOOL) install {
    if ([self.path hasPrefix:@"/"] || [self.path hasPrefix:@"./"] || [self.path hasPrefix:@"~/"]) {
        [xpkg print:@"Local Package"];
    }

    NSString* filestr = [[NSString alloc] initWithContentsOfFile:self.path encoding:NSUTF8StringEncoding error:nil];

    NSArray* filecmps = [filestr componentsSeparatedByString:@"\n"];

    if (!filecmps) {
        return NO;
    }

    [xpkg printInfo:@"Installing %@, Version %@ From: %@", self.name, self.version, self.url];

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
    [xpkg print:@"\tBuilding..."];
    int a = [self runMethodScript:@"BUILD" withTime:time];

    if (a != 0) {
        [xpkg printError:@"Build Failed"];
        [xpkg log:@"Build of %@ returned exit code %d", self.package, a];
        exit(20);
    }

    // INSTALL
    [xpkg print:@"\tInstalling..."];
    a = [self runMethodScript:@"INSTALL"];
    if (a != 0) {
        [xpkg printError:@"Install Failed"];
        [xpkg log:@"Install of %@ returned exit code %d", self.package, a];
        exit(21);
    }
    
    // TEST
    [xpkg print:@"\tTesting..."];
    a = [self runMethodScript:@"TEST"];
    
    if (a == 0) {
        [xpkg printSucsess:@"Installed %@ Sucsessfully", self.name];
    } else {
        [xpkg printError:@"Package %@ Did Not Test Sucsessfully", self.name];
    }
    
    return a;
}

-(BOOL) remove {
    if ([self.path hasPrefix:@"/"] || [self.path hasPrefix:@"./"] || [self.path hasPrefix:@"~/"]) {
        [xpkg print:@"Local Package"];
    }

    NSString* filestr = [[NSString alloc] initWithContentsOfFile:self.path encoding:NSUTF8StringEncoding error:nil];

    NSArray* filecmps = [filestr componentsSeparatedByString:@"\n"];

    if (!filecmps) {
        return NO;
    }

    //TODO Remove packages that depend on this package before removing this package itself

    [xpkg printInfo:[NSString stringWithFormat:@"Removing %@, Version %@", self.name, self.version]];

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
    if (!script) {
        [xpkg printWarn:@"The %@ method was not found in the package file at %@", method, self.path];
    }
    [script writeToFile:sfile atomically:true encoding:NSUTF8StringEncoding error:nil];
    setenv("XPKG_PKG_DIR", [[xpkg getPathWithPrefix:[NSString stringWithFormat:@"/xpkgs/%@/%@/", self.package, self.version]] UTF8String], 1);
    setenv("XPKG_ROOT_DIR", [[xpkg getPathWithPrefix:[NSString stringWithFormat:@"/xpkgs/%@/%@/", self.package, self.version]] UTF8String], 1);
    [xpkg executeCommand:@"/bin/chmod" withArgs:@[@"+x", [xpkg getPathWithPrefix:@"/tmp/script"]] andPath:[xpkg getPathWithPrefix:@"/"] printErr:true printOut:true returnOut:true];
    [xpkg executeCommand:@"/bin/mkdir" withArgs:@[@"-p", [xpkg getPathWithPrefix:[NSString stringWithFormat:@"/tmp/%@-%@", self.package, self.version]]] andPath:[xpkg getPathWithPrefix:@"/"]];
    [xpkg log:@"Starting log for %@ script", method];
    int d = system("/opt/xpkg/tmp/script >> /opt/xpkg/log/xpkg.log 2>&1");
    time = [start timeIntervalSinceNow];
    time = time - (time * 2);
    return d;
}


-(NSString*) readMethodScript:(NSString*)method {
    NSString* filestr = [[NSString alloc] initWithContentsOfFile:self.path encoding:NSUTF8StringEncoding error:nil];

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
    
    BOOL found = NO;
    
    for (int x = 0; x < [filecmps count]; x++) {
        if ([filecmps[x] hasPrefix:@"@"]) {
            NSArray* f = [filecmps[x] componentsSeparatedByString:@":"];
            if ([[f[0] componentsSeparatedByString:@"@"][1] isEqualToString:method]) {
                found = YES;
                for (int y = x + 1; y < [filecmps count]; y++) {
                    if ([filecmps[y] hasPrefix:@"@"]) {
                        NSArray* f = [filecmps[y] componentsSeparatedByString:@":"];
                        if ([[f[0] componentsSeparatedByString:@"@"][1] isEqualToString:@"END"]) {
                            break;
                        } else {
                            [xpkg printWarn:@"Encountered Attribute Feild inside of a method, Ignoring..."];
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
    
    if (!found) {
        return nil;
    }
    return rv;
}

@end
