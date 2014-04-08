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
    fprintf(stderr, "%sERROR: %s%s\n", [BOLDRED  UTF8String], [RESET UTF8String], [x UTF8String]);
    [xpkg log:[NSString stringWithFormat:@"ERROR: %@\n", x]];
}

+(void) printWarn:(NSString *)x {
    fprintf(stderr, "%sWARNING: %s%s\n", [BOLDYELLOW UTF8String], [RESET UTF8String], [x UTF8String]);
    [xpkg log:[NSString stringWithFormat:@"WARNING: %@\n", x]];
}

+(void) printInfo:(NSString *)x {
    printf("%s%s%s\n", [BOLDCYAN UTF8String], [x UTF8String], [RESET UTF8String]);
    [xpkg log:[NSString stringWithFormat:@"INFORMATION: %@\n", x]];
}

+(void) log:(NSString *)x {
    NSString* date = [xpkg getTimestamp];

    NSString* pre = @"[ ";

    if (!nil) {
        return;
    }

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
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path printErr:(BOOL)er printOut:(BOOL)ot {

    NSTask* task = [[NSTask alloc] init];

    [task setLaunchPath:command];

    [task setArguments:args];

    if ([path isEqualToString:@""]) {
        path = @"/";
    }

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

    // prints the error of the command to stderr if 'er' is true
    if (er) {
        fprintf(stderr, "%s", [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] UTF8String]);
    }

    if (![[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] isEqualToString:@""]) {
        [xpkg log:[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]];
    }

    if (![[[NSString alloc] initWithData: errdata encoding: NSUTF8StringEncoding] isEqualToString:@""]) {
        [xpkg log:[[NSString alloc] initWithData: errdata encoding: NSUTF8StringEncoding]];
    }

    // prints the standard out of the command to stdout if 'ot' is true
    if (ot) {
        fprintf(stdout, "%s", [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] UTF8String]);
    }

    NSString* rv = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];

    return rv;
}

/*
 * Other Variants of the executeCommand method above, just with some default values in place
 */

/**
 * Uses an NSTask to execute a shell command
 **/
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path printErr:(BOOL)er {
    return [xpkg executeCommand:command withArgs:args andPath:path printErr:er printOut:true];
}

/**
 * Uses an NSTask to execute a shell command
 **/
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path printOut:(BOOL) ot {
    return [xpkg executeCommand:command withArgs:args andPath:path printErr:true printOut:ot];
}

/**
 * Uses an NSTask to execute a shell command
 **/
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path {
    return [xpkg executeCommand:command withArgs:args andPath:path printErr:true printOut:false];
}

/*
 * a few utility methods
 */
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
    [xpkg executeCommand:@"/usr/bin/xcodebuild" withArgs:@[] andPath:[xpkg getPathWithPrefix:@"/src/xpkg"] printErr:false printOut:false];
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
    NSString* sha256;
    NSString* rmd160;
    NSString* description;
    NSString* url;
    NSString* homepage;
    NSString* maintainer;
    NSArray* depends;
    NSArray* recomended;

    NSFileHandle* file = [xpkg getFileAtPath:path];
    NSString* filestr = [xpkg getStringFromData:[xpkg getDataFromFile:file]];

    NSArray* filecmps = [filestr componentsSeparatedByString:@"\n"];

    if (!filecmps) {
        return NO;
    }

    package = [xpkg getPackage:path];
    version = [xpkg getPackageVersion:path];
    name = [xpkg getPackageName:path];
    sha256 = [xpkg getPackageSHA256:path];
    rmd160 = [xpkg getPackageRMD160:path];
    description = [xpkg getPackageDescription:path];
    url = [xpkg getPackageURL:path];
    homepage = [xpkg getPackageHomepage:path];
    maintainer = [xpkg getPackageMaintainer:path];
    depends = [xpkg getPackageDepends:path];
    recomended = [xpkg getPackageRecomended:path];

    [xpkg printInfo:[NSString stringWithFormat:@"Installing %@, Version %@ From: %@", name, version, url]];

    [xpkg clearTmp];

    if (url) {
        [xpkg print:@"\tDownloading..."];
        [xpkg downloadFile:url place:[xpkg getPathWithPrefix:[NSString stringWithFormat:@"/tmp/%@.tar.gz", package]]];
        [xpkg print:@"\tUnpacking..."];
        [xpkg UntarFileAtPath:[xpkg getPathWithPrefix:[NSString stringWithFormat:@"/tmp/%@.tar.gz", package]] workingDir:[xpkg getPathWithPrefix:@"/tmp/"]];
    }

    for (int x = 0; x < [filecmps count]; x++) {

        if ([filecmps[x] hasPrefix:@"&"]) {
            if ([[filecmps[x] componentsSeparatedByString:@" "][0] isEqualToString:@"&build"]) {
                [xpkg print:@"\tBuilding..."];
                double start = CFAbsoluteTimeGetCurrent();
                for (int d = 0; ![filecmps[x] isEqualToString:@"}"]; d++) {
                    x++;
                    if ([filecmps[x] hasPrefix:@"$"] || [filecmps[x] hasPrefix:@"\t$"]) {
                        // SHELL COMMAND
                        NSArray* parts = [filecmps[x] componentsSeparatedByString:@" "];
                        NSString* command = parts[1];
                        NSMutableArray* mp = [parts mutableCopy];
                        [mp removeObjectAtIndex:0];
                        [mp removeObjectAtIndex:0];
                        parts = mp;
                        if ([command hasPrefix:@"./"]) {
                            command = [NSString stringWithFormat:@"/opt/xpkg/tmp/bash-4.3/%@", command];
                        }

                        [xpkg print:[NSString stringWithFormat:@"Executing command %@", command]];
                        if (command) {
                            [xpkg executeCommand:command withArgs:parts andPath:@"/opt/xpkg/tmp/bash-4.3/" printErr:false printOut:false];
                            [xpkg print:@"Done."];
                        } else {
                            [xpkg printError:[NSString stringWithFormat:@"Unable to launch command %@", command]];
                        }
                    } else if ([filecmps[x] hasPrefix:@"%"] || [filecmps[x] hasPrefix:@"\t%"]) {
                        // SPECIAL COMMAND

                    }
                }
                double end = CFAbsoluteTimeGetCurrent();
                [xpkg print:[NSString stringWithFormat:@"Built in %f ms", (end - start) * 1000]];
            } else if ([[filecmps[x] componentsSeparatedByString:@" "][0] isEqualToString:@"&install"]) {

                //INSTALL METHOD

            } else if ([[filecmps[x] componentsSeparatedByString:@" "][0] isEqualToString:@"&remove"]) {
                [xpkg print:@"\nREMOVE METHOD\n"];
            }
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
    [xpkg printInfo:[NSString stringWithFormat:@"Cleared Log At: %@", [xpkg getTimestamp]]];
}

+(NSString*) getPackageRoot:(NSString*)package andVersion:(NSString*)version {
    return [xpkg getPathWithPrefix:[NSString stringWithFormat:@"/xpkgs/%@/%@", package, version]];
}

+(NSString*) getPackageAttribute:(NSString*)attr atPath:(NSString*)path  {
    return [xpkg getPackageAttribute:attr atPath:path isURL:false];
}

+(NSString*) getPackageAttribute:(NSString*)attr atPath:(NSString*)path isURL:(BOOL) url{
    NSString* rv;

    NSFileHandle* file = [xpkg getFileAtPath:path];
    NSString* filestr = [xpkg getStringFromData:[xpkg getDataFromFile:file]];

    NSArray* filecmps = [filestr componentsSeparatedByString:@"\n"];

    if (!filecmps) {
        return NO;
    }

    for (int x = 0; x < [filecmps count]; x++) {
        if ([filecmps[x] hasPrefix:@"@"]) {
            NSArray* f = [filecmps[x] componentsSeparatedByString:@":"];
            if ([[f[0] componentsSeparatedByString:@"@"][1] isEqualToString:attr]) {
                rv = f[1];
                if (url) {
                    rv = [rv stringByAppendingString:@":"];
                    rv = [rv stringByAppendingString:f[2]];
                }
                if ([rv hasPrefix:@" "]) {
                    rv = [rv substringWithRange:NSMakeRange(1, [rv length]-1)];
                }
            }
        }
    }
    return rv;
}

+(NSArray*) getPackageArrayAttribute:(NSString*)attr atPath:(NSString*)path {
    NSArray* rv;

    NSFileHandle* file = [xpkg getFileAtPath:path];
    NSString* filestr = [xpkg getStringFromData:[xpkg getDataFromFile:file]];

    NSArray* filecmps = [filestr componentsSeparatedByString:@"\n"];

    if (!filecmps) {
        return NO;
    }

    for (int x = 0; x < [filecmps count]; x++) {
        if ([filecmps[x] hasPrefix:@"@"]) {
            NSArray* f = [filecmps[x] componentsSeparatedByString:@":"];
            NSString* str = f[1];
            rv = [str componentsSeparatedByString:@","];
            NSMutableArray* md = [rv mutableCopy];
            for (int a = 0; a < [md count]; a++) {
                if ([md[a] hasPrefix:@" "]) {
                    md[a] = [md[a] substringWithRange:NSMakeRange(1, [md[a] length] - 1)];
                }
            }
            rv = md;
        }
    }
    return rv;
}

+(NSString*) getPackage:(NSString*)path {
    return [xpkg getPackageAttribute:@"Package" atPath:path];
}

+(NSString*) getPackageVersion:(NSString*)path {
    return [xpkg getPackageAttribute:@"Version" atPath:path];
}

+(NSString*) getPackageName:(NSString*)path {
    return [xpkg getPackageAttribute:@"Name" atPath:path];
}

+(NSString*) getPackageURL:(NSString*)path {
    return [xpkg getPackageAttribute:@"URL" atPath:path isURL:true];
}

+(NSString*) getPackageHomepage:(NSString*)path {
    return [xpkg getPackageAttribute:@"Homepage" atPath:path isURL:true];
}

+(NSString*) getPackageSHA256:(NSString*)path {
    return [xpkg getPackageAttribute:@"SHA256" atPath:path];
}

+(NSString*) getPackageRMD160:(NSString*)path {
    return [xpkg getPackageAttribute:@"RMD160" atPath:path];
}

+(NSString*) getPackageDescription:(NSString*)path {
    return [xpkg getPackageAttribute:@"Description" atPath:path];
}

+(NSString*) getPackageMaintainer:(NSString*)path {
    return [xpkg getPackageAttribute:@"Maintainer" atPath:path];
}

+(NSArray*) getPackageDepends:(NSString*)path {
    return [xpkg getPackageArrayAttribute:@"Depends" atPath:path];
}

+(NSArray*) getPackageRecomended:(NSString*)path {
    return [xpkg getPackageArrayAttribute:@"Recomended" atPath:path];
}

+(void) UntarFileAtPath:(NSString*)path workingDir:(NSString*)wdir {
    [xpkg executeCommand:@"/usr/bin/tar" withArgs:@[@"-xvf", path] andPath:wdir printErr:false printOut:false];
}

+(void) clearTmp {
    [xpkg executeCommand:@"/bin/rm" withArgs:@[@"-r", [xpkg getPathWithPrefix:@"/tmp/"]] andPath:@"/"];
    [xpkg executeCommand:@"/bin/mkdir" withArgs:@[[xpkg getPathWithPrefix:@"/tmp"]] andPath:@"/"];
}

+(BOOL) is64Bit {
    if (__LP64__) {
        return true;
    } else {
        return false;
    }
}

+(void) printXpkg {
    printf("%s", [[NSString stringWithFormat:@"%@\n\\⎺⎺\\       /⎺⎺/ |⎺⎺⎺⎺⎺⎺⎺⎺| |⎺⎺|  /⎺⎺/ |⎺⎺⎺⎺⎺⎺⎺|      \n%@", BOLDMAGENTA, RESET] UTF8String]);
    printf("%s", [[NSString stringWithFormat:@"%@ \\  \\     /  /  |   |⎺⎺| | |  | /  /  | |⎺⎺⎺| |        \n%@", BOLDMAGENTA, RESET] UTF8String]);
    printf("%s", [[NSString stringWithFormat:@"%@  \\  \\   /  /   |   |__| | |  |/  /   | |___| |        \n%@", BOLDMAGENTA, RESET] UTF8String]);
    printf("%s", [[NSString stringWithFormat:@"%@   \\  \\ /  /    |  ______| |     /    |  _____|        \n%@", BOLDMAGENTA, RESET] UTF8String]);
    printf("%s", [[NSString stringWithFormat:@"%@   /  / \\  \\    |  |       |     \\    |  |            \n%@", BOLDMAGENTA, RESET] UTF8String]);
    printf("%s", [[NSString stringWithFormat:@"%@  /  /   \\  \\   |  |       |  |\\  \\   |  |           \n%@", BOLDMAGENTA, RESET] UTF8String]);
    printf("%s", [[NSString stringWithFormat:@"%@ /  /     \\  \\  |  |       |  | \\  \\  |  |_/⎺/       \n%@", BOLDMAGENTA, RESET] UTF8String]);
    printf("%s", [[NSString stringWithFormat:@"%@/__/       \\__\\ |__|       |__|  \\__\\ |_____/  %@Advanced Package Managment for Mac OS X\n\n%@", BOLDMAGENTA, BOLDGREEN, RESET] UTF8String]);
}

+(void) addRepository:(NSString*) url {
    NSFileManager* filem = [[NSFileManager alloc] init];

    [filem createDirectoryAtPath:[xpkg getPathWithPrefix:@"/core/repos"] withIntermediateDirectories:true attributes:nil error:nil];
    [xpkg executeCommand:@"/opt/xpkg/bin/git" withArgs:@[@"submodule", @"add", url] andPath:@"/opt/xpkg/core/repos"];

}

+(void) parseRepoFile:(NSString*)path {
    
}


@end

