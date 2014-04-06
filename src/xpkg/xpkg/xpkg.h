//
//  xpkg.h
//  xpkg
//
//  Created by Jack Maloney on 3/31/14.
//  Copyright (c) 2014 IV. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* USAGE = @"xpkg [options] command [options] <arguments> \ntype xpkg -h  for more help\n";

static NSString* PREFIX = @"/opt/xpkg";

static NSString* VERSION = @"1.0.0-Beta.2";

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
static NSString* CREATE = @"create";
static NSString* EXTRACT = @"extract";
static NSString* VIEW = @"view";
static NSString* CLEAR_LOG = @"clear-log";

// Colors for terminal output
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


@interface xpkg : NSObject
+(void) print:(NSString*)x;
+(void) printError:(NSString*)x;
+(void) log:(NSString *)x;
+(void) printWarn:(NSString *)x;
+(BOOL) checkForArgs:(int)argc;

+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path;
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path printErr:(BOOL)er printOut:(BOOL)ot;
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path printOut:(BOOL)ot;
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path printErr:(BOOL)er;

+(BOOL) checkHashes:(NSString*)sha rmd160:(NSString*)rmd atPath:(NSString*) path;
+(void) updateProgram;
+(void) downloadFile:(NSString*)URL place:(NSString*)path;
+(void) exitIfNotRoot;
+(BOOL) installPackage:(NSString*)path;
+(NSFileHandle*) getFileAtPath:(NSString*)path;
+(NSString*) getStringFromData:(NSData*) data;
+(NSData*) getDataFromFile:(NSFileHandle*) file;
+(NSString*) getPathWithPrefix:(NSString*)path;
+(NSString*) getTimestamp;
+(void) clearLog;
+(NSString*) getPackageRoot:(NSString*)package andVersion:(NSString*)version;
+(NSArray*) getPackageArrayAttribute:(NSString*)attr atPath:(NSString*)path;
+(NSString*) getPackageAttribute:(NSString*)attr atPath:(NSString*)path;
+(NSString*) getPackageAttribute:(NSString*)attr atPath:(NSString*)path isURL:(BOOL) url;
+(void) printInfo:(NSString *)x;
@end

static NSFileHandle* logFile;
