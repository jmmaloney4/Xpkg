//
//  main.m
//  osxd
//
//  Created by Jack Maloney on 3/30/14.
//  Copyright (c) 2014 IV. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* USAGE = @"osxd [options] command [options] <arguments>\n";
static NSString* INSTALL = @"install";
static NSString* REINSTALL = @"reinstall";
static NSString* REMOVE = @"remove";
static NSString* BUILD = @"build";
static NSString* LIST = @"list";
static NSString* SEARCH = @"search";
static NSString* DEV = @"dev";
static NSString* DEV_BUILD = @"build";
static NSString* DEV_EXTRACT = @"extract";

static NSString* CONFIG_FILE = @"/opt/osxd/config";
static NSString* CONFIG_PATH = @"/opt/osxd";

void print(NSString* x) {
    printf("%s", [x UTF8String]);
}

void printUsage() {
    print(USAGE);
}

NSFileHandle* getConfigFile() {
    NSFileHandle * config = [NSFileHandle fileHandleForReadingAtPath:CONFIG_FILE];
    if (!config) {
        NSTask *mkconf = [[NSTask alloc] init];
        [mkconf setLaunchPath:@"/bin/mkdir"];
        [mkconf setArguments:[NSArray arrayWithObjects: @"/opt/",CONFIG_PATH, nil]];
        [mkconf launch];
        NSTask *mkcnf = [[NSTask alloc] init];
        [mkcnf setLaunchPath:@"/usr/bin/touch"];
        [mkcnf setArguments:[NSArray arrayWithObjects: CONFIG_FILE, nil]];
        [mkcnf launch];
    }
    config = [NSFileHandle fileHandleForReadingAtPath:CONFIG_FILE];
    return config;
}

NSString* getConfigFileString() {
    NSData *data = [getConfigFile() readDataToEndOfFile];
    NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    return string;
}

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        if (argc < 2) {
            printUsage();
            exit(1);
        }
        
        if (getuid() != 0) {
            
        }
        
        if ([INSTALL isEqualToString:[NSString stringWithUTF8String:argv[1]]]) {
            if (argc < 3) {
                printf("%s\n", [@"install command requires at least one argument" UTF8String]);
            } else {
                NSString* confstr = getConfigFileString();
            }
        } else if ([REINSTALL isEqualToString:[NSString stringWithUTF8String:argv[1]]]) {
            
        } else if ([REMOVE isEqualToString:[NSString stringWithUTF8String:argv[1]]]) {
            
        } else if ([BUILD isEqualToString:[NSString stringWithUTF8String:argv[1]]]) {
            
        } else if ([LIST isEqualToString:[NSString stringWithUTF8String:argv[1]]]) {
        
        }
    }
    exit(0);
    return 0;
}
