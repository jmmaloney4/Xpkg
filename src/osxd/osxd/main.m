//
//  main.m
//  osxd
//
//  Created by Jack Maloney on 3/30/14.
//  Copyright (c) 2014 IV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "share.h"


static NSString* VERSION = @"0.1.0";

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        if (argc < 2) {
            [share printUsage];
            exit(1);
        }
        
        
        
        if ([INSTALL isEqualToString:[NSString stringWithUTF8String:argv[1]]]) {
            [share exitIfNotRoot];
            if (argc < 3) {
                printf("%s\n", [@"install command requires at least one argument" UTF8String]);
                exit(1);
            } else {
                // NSString* confstr = [share getConfigFileString];
            
            }
        } else if ([ADD isEqualToString:[NSString stringWithUTF8String:argv[1]]]) {
            
            
        } else if ([REINSTALL isEqualToString:[NSString stringWithUTF8String:argv[1]]]) {
            [share exitIfNotRoot];
            
        } else if ([REMOVE isEqualToString:[NSString stringWithUTF8String:argv[1]]]) {
            [share exitIfNotRoot];
            
        } else if ([CREATE isEqualToString:[NSString stringWithUTF8String:argv[1]]]) {
            if (argc < 3) {
                [share print:@"create command requires at least one argument"];
                exit(-1);
            }
            NSString* path = [[NSString alloc] initWithUTF8String:argv[2]];
            [share createPackage:path];
        } else if ([BUILD isEqualToString:[NSString stringWithUTF8String:argv[1]]]) {
            [share exitIfNotRoot];
            
        } else if ([@"-h" isEqualToString:[NSString stringWithUTF8String:argv[1]]] || [@"--help" isEqualToString:[NSString stringWithUTF8String:argv[1]]]) {
            //TODO print help
        } else if ([@"-v" isEqualToString:[NSString stringWithUTF8String:argv[1]]] ||
                   [@"--version" isEqualToString:[NSString stringWithUTF8String:argv[1]]]) {
            // Prints Version
            printf("osxd version: %s", [VERSION UTF8String]);
        } else {
            printf("Error %s is not a valid argument\n\n", argv[1]);
            [share printUsage];
        }
    }
    exit(0);
    return 0;
}
