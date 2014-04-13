//
//  xpkg.m
//  xpkg
//
//  Created by Jack Maloney on 3/31/14.
//  Copyright (c) 2014 Jack Maloney. All rights reserved.
//

#import "xpkg.h"
#import "XPPackage.h"
#import "XPRepository.h"

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

    NSString* pre = @"[ ";

    pre = [pre stringByAppendingString:[xpkg getTimestamp]];
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
        [xpkg printUsage];
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
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path printErr:(BOOL)er printOut:(BOOL)ot returnOut:(BOOL) x{

    NSTask* task = [[NSTask alloc] init];

    [task setLaunchPath:command];

    [task setArguments:args];

    if ([path isEqualToString:@""] || [path isEqualToString:nil]) {
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
        fprintf(stderr, "%s", [[[NSString alloc] initWithData: errdata encoding: NSUTF8StringEncoding] UTF8String]);
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
    NSString* rv;

    if (x) {
        rv = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    } else {
        rv = [[NSString alloc] initWithData: errdata encoding: NSUTF8StringEncoding];
    }
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
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path printErr:(BOOL)er printOut:(BOOL)ot {
    return [xpkg executeCommand:command withArgs:args andPath:path printErr:er printOut:ot returnOut:true];
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
    [xpkg printInfo:@"Updating..."];
    [xpkg print:@"\tUpdating Xpkg"];
    [xpkg executeCommand:@"/bin/rm" withArgs:@[@"-r", [xpkg getPathWithPrefix:@"/xpkg/xpkg.xcodeproj/project.xcworkspace/xcuserdata"]] andPath:[xpkg getPathWithPrefix:@"/"]];
    [xpkg addAndCommit];
    [xpkg executeCommand:[xpkg getPathWithPrefix:@"/bin/git"] withArgs:@[@"pull"] andPath:[xpkg getPathWithPrefix:@"/"] printErr:false printOut:false];
    [xpkg addAndCommit];
    [xpkg executeCommand:@"/usr/bin/xcodebuild" withArgs:@[] andPath:[xpkg getPathWithPrefix:@"/xpkg"] printErr:false printOut:false];
    [xpkg executeCommand:@"/bin/cp" withArgs:@[[xpkg getPathWithPrefix:@"/xpkg/build/Release/xpkg"], [xpkg getPathWithPrefix:@"/core/"]] andPath:[xpkg getPathWithPrefix:@""]];
    [xpkg executeCommand:@"/bin/ln" withArgs:@[@"-fF", [xpkg getPathWithPrefix:@"/core/xpkg"], @"/usr/bin/xpkg"] andPath:[xpkg getPathWithPrefix:@""]];
    [xpkg print:@"\tUpdating Repositories"];
    [xpkg executeCommand:[xpkg getPathWithPrefix:@"/bin/git"] withArgs:@[@"submodule", @"update"] andPath:[xpkg getPathWithPrefix:@"/"]];
}

+(void) addAndCommit {
    [xpkg executeCommand:[xpkg getPathWithPrefix:@"/bin/git"] withArgs:@[@"add", @"-A"] andPath:[xpkg getPathWithPrefix:@"/"] printErr:false printOut:false];
    [xpkg executeCommand:[xpkg getPathWithPrefix:@"/bin/git"] withArgs:@[@"commit", @"-m", @"\"xpkg local commit\""] andPath:[xpkg getPathWithPrefix:@"/"] printErr:false printOut:false];
}

/**
 * Downloads the fie at URL and saves it at the path provided
 **/
+(void) downloadFile:(NSString*)URL place:(NSString*)path {
    NSData* data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:URL]];
    [data writeToFile:path atomically:YES];
}

/**
 * clears the Xpkg log file
 **/
+(void) clearLog {
    [xpkg executeCommand:@"/bin/rm" withArgs:@[[xpkg getPathWithPrefix:@"/log/xpkg.log"]] andPath:@"/"];
    [xpkg executeCommand:@"/usr/bin/touch" withArgs:@[[xpkg getPathWithPrefix:@"/log/xpkg.log"]] andPath:@"/"];
    [xpkg printInfo:[NSString stringWithFormat:@"Cleared Log At: %@", [xpkg getTimestamp]]];
}

+(NSString*) getAttribute:(NSString*)attr atPath:(NSString*)path  {
    return [xpkg getAttribute:attr atPath:path isURL:false];
}

+(NSString*) getAttribute:(NSString*)attr atPath:(NSString*)path isURL:(BOOL) url{
    NSString* rv;

    NSFileHandle* file = [xpkg getFileAtPath:path];
    NSString* filestr = [xpkg getStringFromData:[xpkg getDataFromFile:file]];

    NSArray* filecmps = [filestr componentsSeparatedByString:@"\n"];

    if (!filecmps) {
        return nil;
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

+(NSArray*) getArrayAttribute:(NSString*)attr atPath:(NSString*)path {
    NSArray* rv;

    NSFileHandle* file = [xpkg getFileAtPath:path];
    NSString* filestr = [xpkg getStringFromData:[xpkg getDataFromFile:file]];

    NSArray* filecmps = [filestr componentsSeparatedByString:@"\n"];

    if (!filecmps) {
        return nil;
    }

    for (int x = 0; x < [filecmps count]; x++) {
        if ([filecmps[x] hasPrefix:@"@"]) {
            NSArray* f = [filecmps[x] componentsSeparatedByString:@":"];
            if ([[f[0] componentsSeparatedByString:@"@"][0] isEqualToString:attr]) {
                if (f.count == 0 || f.count == 1) {
                    return nil;
                }
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
    }
    return rv;
}

+(NSString*) getPackage:(NSString*)path {
    return [xpkg getAttribute:@"Package" atPath:path];
}

+(NSString*) getPackageVersion:(NSString*)path {
    return [xpkg getAttribute:@"Version" atPath:path];
}

+(NSString*) getPackageName:(NSString*)path {
    return [xpkg getAttribute:@"Name" atPath:path];
}

+(NSString*) getPackageURL:(NSString*)path {
    return [xpkg getAttribute:@"URL" atPath:path isURL:true];
}

+(NSString*) getPackageHomepage:(NSString*)path {
    return [xpkg getAttribute:@"Homepage" atPath:path isURL:true];
}

+(NSString*) getPackageSHA256:(NSString*)path {
    return [xpkg getAttribute:@"SHA256" atPath:path];
}

+(NSString*) getPackageRMD160:(NSString*)path {
    return [xpkg getAttribute:@"RMD160" atPath:path];
}

+(NSString*) getPackageDescription:(NSString*)path {
    return [xpkg getAttribute:@"Description" atPath:path];
}

+(NSString*) getPackageMaintainer:(NSString*)path {
    return [xpkg getAttribute:@"Maintainer" atPath:path];
}

+(NSArray*) getPackageDepends:(NSString*)path {
    return [xpkg getArrayAttribute:@"Depends" atPath:path];
}

+(NSArray*) getPackageRecomended:(NSString*)path {
    return [xpkg getArrayAttribute:@"Recomended" atPath:path];
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
    printf("%s", [[NSString stringWithFormat:@"%@\n\\⎺⎺\\       /⎺⎺/ |⎺⎺⎺⎺⎺⎺⎺⎺| |⎺⎺|  /⎺⎺/ |⎺⎺⎺⎺⎺⎺⎺⎺⎺|  \n%@", BOLDMAGENTA, RESET] UTF8String]);
    printf("%s", [[NSString stringWithFormat:@"%@ \\  \\     /  /  |  |⎺⎺⎺| | |  | /  /  |  |⎺⎺⎺⎺⎺⎺|    \n%@", BOLDMAGENTA, RESET] UTF8String]);
    printf("%s", [[NSString stringWithFormat:@"%@  \\  \\   /  /   |  |___| | |  |/  /   |  |           \n%@", BOLDMAGENTA, RESET] UTF8String]);
    printf("%s", [[NSString stringWithFormat:@"%@   \\  \\ /  /    |  ______| |     /    |  |           \n%@", BOLDMAGENTA, RESET] UTF8String]);
    printf("%s", [[NSString stringWithFormat:@"%@   /  / \\  \\    |  |       |     \\    |  |  |⎺⎺⎺|   \n%@", BOLDMAGENTA, RESET] UTF8String]);
    printf("%s", [[NSString stringWithFormat:@"%@  /  /   \\  \\   |  |       |  |\\  \\   |  |   ⎺| |  \n%@", BOLDMAGENTA, RESET] UTF8String]);
    printf("%s", [[NSString stringWithFormat:@"%@ /  /     \\  \\  |  |       |  | \\  \\  |   ⎺⎺⎺⎺  |  \n%@", BOLDMAGENTA, RESET] UTF8String]);
    printf("%s", [[NSString stringWithFormat:@"%@/__/       \\__\\ |__|       |__|  \\__\\ |_________|  %@Advanced Package Managment for Mac OS X\n\n%@", BOLDMAGENTA, BOLDGREEN, RESET] UTF8String]);
}

+(void) addRepository:(NSString*) url {
    XPRepository* repo = [[XPRepository alloc] initWithURL:url];
    [repo add];
}

+(void) rmRepository:(NSString*) path {
    //XPRepository* repo = [];
    //[repo add];
}

+(NSArray*) parseRepoFile:(NSString*)path {
    NSString* name = [xpkg getAttribute:@"Name" atPath:path isURL:false];
    NSString* maintainer = [xpkg getAttribute:@"Maintainer" atPath:path isURL:false];
    NSString* description = [xpkg getAttribute:@"Description" atPath:path isURL:false];
    
    NSArray* rv = @[name, maintainer, description];
    return rv;
}

+(void) printUsage {
    printf("%s", [[NSString stringWithFormat:@"%@Xpkg Usage:\n%@%@", BOLDMAGENTA, RESET, USAGE] UTF8String]);
}

+(NSString*) getClangVersion {
    return [NSString stringWithFormat:@"%d.%d", __clang_major__, __clang_minor__];
}

+(BOOL) installPackage:(NSString *)path {
    BOOL rv = NO;

    XPPackage* pkg = [[XPPackage alloc] initWithpath:path];

    if (!pkg) {
        rv = [pkg install];
    }

    return rv;
}

+(BOOL) removePackage:(NSString *)path {
    BOOL rv = NO;

    XPPackage* pkg = [[XPPackage alloc] initWithpath:path];

    if (!pkg) {
        rv = [pkg remove];
    }

    return rv;
}



@end

