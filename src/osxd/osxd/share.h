//
//  share.h
//  osxd
//
//  Created by Jack Maloney on 3/30/14.
//  Copyright (c) 2014 IV. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* USAGE = @"osxd [options] command [options] <arguments> \ntype osxd -h  for more help\n";

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

static NSString* CONFIG_FILE = @"/opt/osxd/config";
static NSString* CONFIG_PATH = @"/opt/osxd";

static NSString* SRC = @"SRC";
static NSString* BIN = @"BIN";

// Colors for terminal output
static NSString* RESET = @"\033[0m";
static NSString* RED = @"\033[31m";      /* Red */
static NSString* GREEN = @"\033[32m";      /* Green */
static NSString* BLUE = @"\033[34m";      /* Blue */
static NSString* MAGENTA  = @"\033[35m";      /* Magenta */
static NSString* CYAN = @"\033[36m";      /* Cyan */
static NSString* BOLDRED = @"\033[1m\033[31m";      /* Bold Red */
static NSString* BOLDGREEN = @"\033[1m\033[32m";      /* Bold Green */

@interface share : NSObject
+(NSFileHandle*) getConfigFile;
+(NSString*) getConfigFileString;
+(BOOL) exitIfNotRoot;
+(void) print:(NSString*) x;
+(void) printUsage;
+(NSString*) createPackage:(NSString*)path;
+(NSString*) getInfoFileForPath:(NSString*) path;
@end
