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
static NSString* REINSTALL = @"reinstall";
static NSString* REMOVE = @"remove";
static NSString* BUILD = @"build";
static NSString* LIST = @"list";
static NSString* SEARCH = @"search";
static NSString* ADD = @"add";
static NSString* DEV = @"dev";
static NSString* DEV_BUILD = @"build";
static NSString* DEV_EXTRACT = @"extract";

static NSString* CONFIG_FILE = @"/opt/osxd/config";
static NSString* CONFIG_PATH = @"/opt/osxd";

@interface share : NSObject
+(NSFileHandle*) getConfigFile;
+(NSString*) getConfigFileString;
+(BOOL) exitIfNotRoot;
+(void) printUsage;
@end
