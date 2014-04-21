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

#import <Foundation/Foundation.h>
#import "XPManager.h"

/*
 * Colors For Colorized Terminal Output
 */
static NSString* RESET = @"\033[0m";
static NSString* RED = @"\033[31m";                 /* Red */
static NSString* GREEN = @"\033[32m";               /* Green */
static NSString* BLUE = @"\033[34m";                /* Blue */
static NSString* MAGENTA  = @"\033[35m";            /* Magenta */
static NSString* CYAN = @"\033[36m";                /* Cyan */
static NSString* BOLDRED = @"\033[1m\033[31m";      /* Bold Red */
static NSString* BOLDGREEN = @"\033[1m\033[32m";    /* Bold Green */
static NSString* BOLDYELLOW = @"\033[1m\033[33m";   /* Bold Yellow */
static NSString* BOLDCYAN = @"\033[1m\033[36m";     /* Bold Cyan */
static NSString* BOLDMAGENTA = @"\033[1m\033[35m";  /* Bold Magenta */
static NSString* BOLDBLUE = @"\033[1m\033[34m";     /* Bold Blue */

/*
 * The Usage Statement For Xpkg
 */
static NSString* USAGE = @"xpkg [options] command [options] <arguments> \ntype xpkg -h  for more help\n";

/*
 * Path Prefix For Xpkg
 */
static NSString* PREFIX = @"/opt/xpkg";

/*
 * Xpkg Version
 */
static NSString* VERSION = @"1.0.0-Beta.5";

/*
 * Path to the Log File
 */
static NSString* LOG_FILE = @"/opt/xpkg/log/xpkg.log";

/*
 * A few attempts to localize command names (etc.)
 */
static NSString* VERSION_ARG = @"-V";
static NSString* INSTALL = @"install";
static NSString* UPDATE = @"update";
static NSString* UPGRADE = @"upgrade";
static NSString* REINSTALL = @"reinstall";
static NSString* REMOVE = @"remove";
static NSString* BUILD = @"build";
static NSString* LIST = @"list";
static NSString* SEARCH = @"search";
static NSString* ADD = @"add";
static NSString* RM_REPO = @"rm-repo";
static NSString* EXTRACT = @"extract";
static NSString* VIEW = @"view";
static NSString* CLEAR_LOG = @"clear-log";
static NSString* SYS_INFO = @"sys";

@interface xpkg : NSObject

@property XPManager* manager;

/*
 * Print methods for ease of use
 */
+(void) print:(NSString*) x, ...;
+(void) printError:(NSString *)x, ...;
+(void) printWarn:(NSString *)x, ...;
+(void) printInfo:(NSString *)x, ...;
+(void) log:(NSString *)x, ...;

/**
 *  Executes a shell command using an NSTask
 **/
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path printErr:(BOOL)er printOut:(BOOL)ot returnOut:(BOOL) x ;
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path;
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path printErr:(BOOL)er printOut:(BOOL)ot;
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path printOut:(BOOL)ot;
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path printErr:(BOOL)er;


// +(BOOL) checkHashes:(NSString*)sha rmd160:(NSString*)rmd atPath:(NSString*) path;

/**
 *  updates Xpkg
 **/
+(void) updateProgram;
/**
 *  Downloads a file
 **/
+(void) downloadFile:(NSString*)URL place:(NSString*)path;
+(void) exitIfNotRoot;
+(BOOL) installPackage:(NSString*)path;
+(BOOL) removePackage:(NSString*)path;
+(NSString*) getPathWithPrefix:(NSString*)path;
+(NSString*) getTimestamp;
+(void) clearLog;
+(NSArray*) getArrayAttribute:(NSString*)attr atPath:(NSString*)path;
+(NSString*) getAttribute:(NSString*)attr atPath:(NSString*)path;
+(NSString*) getAttribute:(NSString*)attr atPath:(NSString*)path isURL:(BOOL) url;
+(void) UntarFileAtPath:(NSString*)path workingDir:(NSString*)wdir;
+(void) clearTmp;
+(BOOL) is64Bit;
+(void) printXpkg;
+(void) addRepository:(NSString*) url;
+(void) rmRepository:(NSString*) path;
+(NSArray*) parseRepoFile:(NSString*)path;
+(void) printUsage;
+(NSString*) getClangVersion;
+(void) addAndCommit;
+(BOOL) fileIsIgnoredInRepo:(NSString*) str;

@end

static NSFileHandle* logFile;
