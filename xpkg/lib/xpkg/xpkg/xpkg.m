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

#import "xpkg.h"

@implementation xpkg

+(void) print:(NSString*) x, ... {
    
    va_list formatArgs;
    va_start(formatArgs, x);
    
    NSString* str = [[NSString alloc] initWithFormat:x arguments: formatArgs];
    printf("%s\n", [str UTF8String]);
    [xpkg log:[NSString stringWithFormat:@"INFO: %@\n", str]];
}

+(void) printSuccess:(NSString*) x, ... {
    
    va_list formatArgs;
    va_start(formatArgs, x);
    
    NSString* str = [[NSString alloc] initWithFormat:x arguments: formatArgs];
    printf("%s✔︎ %s%s\n", [BOLDGREEN UTF8String], [str UTF8String], [RESET UTF8String]);
    [xpkg log:[NSString stringWithFormat:@"Sucsess: %@\n", str]];
}

+(void) printError:(NSString *)x, ... {
    
    va_list formatArgs;
    va_start(formatArgs, x);
    
    NSString* str = [[NSString alloc] initWithFormat:x arguments: formatArgs];
    
    fprintf(stderr, "%sERROR: %s%s\n", [BOLDRED  UTF8String], [RESET UTF8String], [str UTF8String]);
    [xpkg log:[NSString stringWithFormat:@"ERROR: %@\n", str]];
}

+(void) printWarn:(NSString *)x, ... {
    
    va_list formatArgs;
    va_start(formatArgs, x);
    
    NSString* str = [[NSString alloc] initWithFormat:x arguments: formatArgs];
    
    fprintf(stderr, "%sWARNING: %s%s\n", [BOLDYELLOW UTF8String], [RESET UTF8String], [str UTF8String]);
    [xpkg log:[NSString stringWithFormat:@"WARNING: %@\n", str]];
}

/**
 *  A printf function that logs in bold cyan letters, showing something importatn, and is logged as such
 **/
+(void) printInfo:(NSString *)x, ... {
    
    va_list formatArgs;
    va_start(formatArgs, x);
    
    NSString* str = [[NSString alloc] initWithFormat:x arguments: formatArgs];
    
    printf("%s%s%s\n", [BOLDCYAN UTF8String], [str UTF8String], [RESET UTF8String]);
    [xpkg log:[NSString stringWithFormat:@"INFORMATION: %@\n", str]];
}

/**
 *  Logs to the xpkg log
 **/
+(void) log:(NSString *)x, ... {
    
    va_list formatArgs;
    va_start(formatArgs, x);
    
    NSString* str = [[NSString alloc] initWithFormat:x arguments: formatArgs];
    
    NSString* pre = @"[ ";
    
    pre = [pre stringByAppendingString:[xpkg getTimestamp]];
    pre = [pre stringByAppendingString:@" ] "];
    pre = [pre stringByAppendingString:str];
    
    NSData* data = [pre dataUsingEncoding:NSUTF8StringEncoding];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:LOG_FILE];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:data];
    [fileHandle closeFile];
}

/**
 *  Gets a timestamp in the format 'cccc, MMMM dd, YYYY, HH:mm:ss.SSS aa' which turns out like this 'Monday, April 14, 2014, 21:46:53.882 PM'
 **/
+(NSString*) getTimestamp {
    NSDate *myDate = [[NSDate alloc] init];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"cccc, MMMM dd, YYYY, HH:mm:ss.SSS aa"];
    NSString* date = [dateFormat stringFromDate:myDate];
    return date;
}

/**
 * Uses an NSTask to execute a shell command
 **/
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path printErr:(BOOL)er printOut:(BOOL)ot returnOut:(BOOL) x {
    
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

/**
 * returns a path with '/opt/xpkg' in front of it
 **/
+(NSString*) getPathWithPrefix:(NSString*)path, ... {
    
    va_list formatArgs;
    va_start(formatArgs, path);
    
    NSString* str = [[NSString alloc] initWithFormat:path arguments: formatArgs];
    
    NSMutableString* rv = [PREFIX mutableCopy];
    [rv appendString:str];
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
    [xpkg addAndCommit];
    [xpkg executeCommand:[xpkg getPathWithPrefix:@"/bin/git"] withArgs:@[@"pull", @"-u", @"origin", @"master"] andPath:[xpkg getPathWithPrefix:@"/"] printErr:false printOut:false];
    [xpkg addAndCommit];
    [xpkg executeCommand:@"/usr/bin/xcodebuild" withArgs:@[@"-workspace", @"xpkg.xcworkspace", @"-scheme", @"xpkg", @"CONFIGURATION_BUILD_DIR=$(pwd)/Build"] andPath:[xpkg getPathWithPrefix:@"/xpkg"] printErr:false printOut:false];
    [xpkg executeCommand:@"/bin/cp" withArgs:@[[xpkg getPathWithPrefix:@"/xpkg/build/Release/xpkg"], [xpkg getPathWithPrefix:@"/core/"]] andPath:[xpkg getPathWithPrefix:@""]];
    [xpkg executeCommand:@"/bin/ln" withArgs:@[@"-fF", [xpkg getPathWithPrefix:@"/core/xpkg"], @"/usr/bin/xpkg"] andPath:[xpkg getPathWithPrefix:@""]];
    [xpkg print:@"\tUpdating Repositories"];
    [xpkg executeCommand:[xpkg getPathWithPrefix:@"/bin/git"] withArgs:@[@"submodule", @"update"] andPath:[xpkg getPathWithPrefix:@"/"]];
}

/**
 *  adds the files in the xpkg git repository and locally commits them
 **/
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
    [xpkg printSuccess:@"Cleared Log At: %@", [xpkg getTimestamp]];
}

/**
 *  gets the specified attribute field from the file at the path
 **/
+(NSString*) getAttribute:(NSString*)attr atPath:(NSString*)path  {
    return [xpkg getAttribute:attr atPath:path isURL:false];
}

/**
 *  gets the specified attribute field from the file at the path
 **/
+(NSString*) getAttribute:(NSString*)attr atPath:(NSString*)path isURL:(BOOL) url{
    NSString* rv;
    
    NSString* filestr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
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

/**
 *  gets the specified attribute field, but returns an array of values that were comma seperated in that field, from the file at the path
 **/
+(NSArray*) getArrayAttribute:(NSString*)attr atPath:(NSString*)path {
    NSArray* rv;
    
    NSString* filestr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
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

/**
 *  Gets the package attribute from the file at path
 **/
+(NSString*) getPackage:(NSString*)path {
    return [xpkg getAttribute:@"Package" atPath:path];
}

/**
 *  Gets the version attribute from the file at path
 **/
+(NSString*) getPackageVersion:(NSString*)path {
    return [xpkg getAttribute:@"Version" atPath:path];
}

/**
 *  Gets the name attribute from the file at path
 **/
+(NSString*) getPackageName:(NSString*)path {
    return [xpkg getAttribute:@"Name" atPath:path];
}

/**
 *  Gets the url attribute from the file at path
 **/
+(NSString*) getPackageURL:(NSString*)path {
    return [xpkg getAttribute:@"URL" atPath:path isURL:true];
}

/**
 *  Gets the homepage attribute from the file at path
 **/
+(NSString*) getPackageHomepage:(NSString*)path {
    return [xpkg getAttribute:@"Homepage" atPath:path isURL:true];
}

/**
 *  Gets the sha256 attribute from the file at path
 **/
+(NSString*) getPackageSHA256:(NSString*)path {
    return [xpkg getAttribute:@"SHA256" atPath:path];
}

/**
 *  Gets the rmd160 attribute from the file at path
 **/
+(NSString*) getPackageRMD160:(NSString*)path {
    return [xpkg getAttribute:@"RMD160" atPath:path];
}

/**
 *  Gets the description attribute from the file at path
 **/
+(NSString*) getPackageDescription:(NSString*)path {
    return [xpkg getAttribute:@"Description" atPath:path];
}

/**
 *  Gets the maintainer attribute from the file at path
 **/
+(NSString*) getPackageMaintainer:(NSString*)path {
    return [xpkg getAttribute:@"Maintainer" atPath:path];
}

/**
 *  Gets the dependancies attribute from the file at path
 **/
+(NSArray*) getPackageDepends:(NSString*)path {
    return [xpkg getArrayAttribute:@"Depends" atPath:path];
}

/**
 *  Gets the recomended attribute from the file at path
 **/
+(NSArray*) getPackageRecomended:(NSString*)path {
    return [xpkg getArrayAttribute:@"Recomended" atPath:path];
}

/**
 *  Untars the file at path, in the working directory
 **/
+(void) UntarFileAtPath:(NSString*)path workingDir:(NSString*)wdir {
    [xpkg executeCommand:@"/usr/bin/tar" withArgs:@[@"-xvf", path] andPath:wdir printErr:false printOut:false];
}

/**
 *  Clears the /opt/xpkg/tmp folder
 **/
+(void) clearTmp {
    [xpkg executeCommand:@"/bin/rm" withArgs:@[@"-r", [xpkg getPathWithPrefix:@"/tmp/"]] andPath:@"/"];
    [xpkg executeCommand:@"/bin/mkdir" withArgs:@[[xpkg getPathWithPrefix:@"/tmp"]] andPath:@"/"];
}

/**
 *  Gets whether the machine is 64-bit or not, at runtime
 **/
+(BOOL) is64Bit {
    if (__LP64__) {
        return true;
    } else {
        return false;
    }
}

/**
 *  Prints a giant XPKG
 **/
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

/**
 *  Adds the repository at url to xpkg's list of repositories
 **/
+(void) addRepository:(NSString*) url {
    XPRepository* repo = [[XPRepository alloc] initWithURL:url];
    [repo add];
}

/**
 *  Removes the repository at path
 **/
+(void) rmRepository:(NSString*) path {
    XPRepository* repo = [[XPRepository alloc] initWithURL:path];
    [repo remove];
}

/**
 *  parses the repo file at path
 **/
+(NSArray*) parseRepoFile:(NSString*)path {
    NSString* name = [xpkg getAttribute:@"Name" atPath:path isURL:false];
    NSString* maintainer = [xpkg getAttribute:@"Maintainer" atPath:path isURL:false];
    NSString* description = [xpkg getAttribute:@"Description" atPath:path isURL:false];
    
    NSArray* rv = @[name, maintainer, description];
    return rv;
}

/**
 *  Prints Xpkg's usage
 **/
+(void) printUsage {
    printf("%s", [[NSString stringWithFormat:@"%@Xpkg Usage:\n%@%@", BOLDMAGENTA, RESET, USAGE] UTF8String]);
}

/**
 *  Returns the version of clang being used
 **/
+(NSString*) getClangVersion {
    return [NSString stringWithFormat:@"%d.%d", __clang_major__, __clang_minor__];
}

/**
 *  Installs the package from the package file at path
 **/
+(XPPackage*) installPackage:(NSString *)path {
    BOOL rv = NO;
    XPPackage* pkg = [[XPPackage alloc] initWithpath:path];
    
    if (pkg) {
        rv = [pkg install];
    }
    
    return pkg;
}

/**
 * Removes the package from the package file at path
 **/
+(XPPackage*) removePackage:(NSString *)path {
    BOOL rv = NO;
    
    XPPackage* pkg = [[XPPackage alloc] initWithpath:path];
    
    if (pkg) {
        rv = [pkg remove];
    }
    
    return pkg;
}

+(BOOL) fileIsIgnoredInRepo:(NSString*) str {
    NSArray* ignored_files = @[@"REPO", @".git", @"README", @"README.md", @"LICENCE", @"LICENSE"];
    for (int a = 0; a < ignored_files.count; a++) {
        if ([str isEqualToString:ignored_files[a]]) {
            return true;
        }
    }
    
    return false;
}

+(void) showLog {
    NSString* str = [[NSString alloc] initWithFormat:@"less %@log/xpkg.log", [xpkg getPathWithPrefix:@"/"]];
    system([str UTF8String]);
}

+(NSString*) SystemInfo {
    NSString* str = [NSString string];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"\tClang:\t\t\t%@", [xpkg getClangVersion]]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"\n\tMac OS X:\t\t%@", [xpkg getOSVersion]]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"\n\tRAM:\t\t\t%ld Bytes", [xpkg getPhysicalMem]]];
    str = [str stringByAppendingString:[NSString stringWithFormat:@"\n\tProcessor Cores:\t%lu", (unsigned long)[xpkg getCores]]];
    
    // Checks For Apple Machine
    if (__APPLE__) {
        str = [str stringByAppendingString:@"\n\tSystem Is Apple"];
    } else {
        str = [str stringByAppendingString:@"\n\tSystem Is Not Apple"];
    }
    
    // Checks if System is 64 bit
    if (__LP64__) {
        str = [str stringByAppendingString:@"\n\tSystem Is 64 bit"];
    } else {
        str = [str stringByAppendingString:@"\n\tSystem Is 32 bit"];
    }
    
    // str = [str stringByAppendingString:[NSString stringWithFormat:@"\n"]];
    return str;
}

+(NSString*) getOSVersion {
    NSProcessInfo* pInfo = [NSProcessInfo processInfo];
    NSString* version = [pInfo operatingSystemVersionString];
    return version;
}

+(long) getPhysicalMem {
    NSProcessInfo* pInfo = [NSProcessInfo processInfo];
    long mem = [pInfo physicalMemory];
    return mem;
}

+(NSUInteger) getCores {
    NSProcessInfo* pInfo = [NSProcessInfo processInfo];
    NSUInteger cores = [pInfo processorCount];
    return cores;
}

@end
