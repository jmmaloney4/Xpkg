//
//  xpkg.h
//  xpkg
//
//  Created by Jack Maloney on 3/31/14.
//  Copyright (c) 2014 Jack Maloney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XPManager.h"

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

static NSString* USAGE = @"xpkg [options] command [options] <arguments> \ntype xpkg -h  for more help\n";

static NSString* PREFIX = @"/opt/xpkg";

static NSString* VERSION = @"1.0.0-Beta.4";

static NSString* HELP_TEXT = @"";

static NSString* LOG_FILE = @"/opt/xpkg/log/xpkg.log";

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

+(BOOL) checkHashes:(NSString*)sha rmd160:(NSString*)rmd atPath:(NSString*) path;

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
