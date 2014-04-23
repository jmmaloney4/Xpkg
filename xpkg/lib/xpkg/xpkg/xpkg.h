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
#import "XPPackage.h"
#import "XPRepository.h"


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

/**
 * an ease of use print method that also logs to the xpkg log file
 **/
+(void) print:(NSString*) x, ...;

/**
 * an ease of use print method that also logs to the xpkg log file, prints a sucssess
 **/
+(void) printSuccess:(NSString*) x, ...;

/**
 * an ease of use print method that also logs to the xpkg log file, prints a warning
 **/
+(void) printWarn:(NSString *)x, ...;

/**
 * an ease of use print method that also logs to the xpkg log file, prints an error
 **/
+(void) printError:(NSString *)x, ...;

/**
 * an ease of use print method that also logs to the xpkg log file, prints important information
 **/
+(void) printInfo:(NSString *)x, ...;

/**
 *  Logs to the xpkg log
 **/
+(void) log:(NSString *)x, ...;

/**
 *  Gets a timestamp in the format 'cccc, MMMM dd, YYYY, HH:mm:ss.SSS aa' which turns out like this 'Monday, April 14, 2014, 21:46:53.882 PM'
 **/
+(NSString*) getTimestamp;

/**
 * Uses an NSTask to execute a shell command
 **/
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path printErr:(BOOL)er printOut:(BOOL)ot returnOut:(BOOL) x;

/**
 * Uses an NSTask to execute a shell command
 **/
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path printErr:(BOOL)er;

/**
 * Uses an NSTask to execute a shell command
 **/
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path printOut:(BOOL) ot;

/**
 * Uses an NSTask to execute a shell command
 **/
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path printErr:(BOOL)er printOut:(BOOL)ot;

/**
 * Uses an NSTask to execute a shell command
 **/
+(NSString*)executeCommand:(NSString*)command withArgs:(NSArray*)args andPath:(NSString*)path;

/**
 * returns a path with the xpkg path prefix in front of it
 **/
+(NSString*) getPathWithPrefix:(NSString*)path;

/**
 * Exits the program if it is not run as root
 **/
+(void) exitIfNotRoot;

/**
 * updates xpkg itself, and the repositories added to xpkg
 **/
+(void) updateProgram;

/**
 *  adds the files in the xpkg git repository and locally commits them
 **/
+(void) addAndCommit;

/**
 * Downloads the fie at URL and saves it at the path provided
 **/
+(void) downloadFile:(NSString*)URL place:(NSString*)path;

/**
 * clears the Xpkg log file
 **/
+(void) clearLog;

/**
 *  Shows the user the log file
 **/
+(void) showLog;

/**
 *  gets the specified attribute field from the file at the path
 **/
+(NSString*) getAttribute:(NSString*)attr atPath:(NSString*)path;

/**
 *  gets the specified attribute field, but returns an array of values that were comma seperated in 
 *  that field, from the file at the path
 **/
+(NSArray*) getArrayAttribute:(NSString*)attr atPath:(NSString*)path;

/**
 *  Gets the package attribute from the file at path
 **/
+(NSString*) getPackage:(NSString*)path;

/**
 *  Gets the version attribute from the file at path
 **/
+(NSString*) getPackageVersion:(NSString*)path;

/**
 *  Gets the name attribute from the file at path
 **/
+(NSString*) getPackageName:(NSString*)path;

/**
 *  Gets the url attribute from the file at path
 **/
+(NSString*) getPackageURL:(NSString*)path;

/**
 *  Gets the homepage attribute from the file at path
 **/
+(NSString*) getPackageHomepage:(NSString*)path;

/**
 *  Gets the sha256 attribute from the file at path
 **/
+(NSString*) getPackageSHA256:(NSString*)path;

/**
 *  Gets the rmd160 attribute from the file at path
 **/
+(NSString*) getPackageRMD160:(NSString*)path;

/**
 *  Gets the description attribute from the file at path
 **/
+(NSString*) getPackageDescription:(NSString*)path;

/**
 *  Gets the maintainer attribute from the file at path
 **/
+(NSString*) getPackageMaintainer:(NSString*)path;

/**
 *  Gets the dependancies attribute from the file at path
 **/
+(NSArray*) getPackageDepends:(NSString*)path;
/**
 *  Gets the recomended attribute from the file at path
 **/
+(NSArray*) getPackageRecomended:(NSString*)path;

/**
 *  Untars the file at path, in the working directory
 **/
+(void) UntarFileAtPath:(NSString*)path workingDir:(NSString*)wdir;

/**
 *  Clears the /opt/xpkg/tmp folder
 **/
+(void) clearTmp;

/**
 *  Prints a giant XPKG, more for looks than anything else
 **/
+(void) printXpkg;

/**
 *  Adds the repository at url to xpkg's list of repositories
 **/
+(void) addRepository:(NSString*) url;

/**
 *  Removes the repository at path
 **/
+(void) rmRepository:(NSString*) path;

/**
 *  parses the repo file at path, and returns an array containing [name, maintainer, description]
 **/
+(NSArray*) parseRepoFile:(NSString*)path;

/**
 *  Prints Xpkg's usage
 **/
+(void) printUsage;

/**
 *  Installs the package from the package file at path
 **/
+(XPPackage*) installPackage:(NSString*) path;

/**
 * Removes the package from the package file at path
 **/
+(XPPackage*) removePackage:(NSString *)path;

/**
 * returns YES if the file is an ignored file in a package repository (not a package file), and NO if it is a package file
 **/
+(BOOL) fileIsIgnoredInRepo:(NSString*) str;

/**
 *  returns information about the current system, mostly for debugging purposes
 **/
+(NSString*) SystemInfo;

@end
